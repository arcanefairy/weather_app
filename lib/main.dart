import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'app_scaffold.dart';
import 'theme_provider.dart';
import 'agregar_ciudades_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'clima_carousel_view.dart';
import 'creditos_page.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final GoRouter router = GoRouter(routes:  [
      GoRoute(path: '/', builder: (context, state) => const MyHomePage(title:'Inicio')),
      GoRoute(path: '/agregar_ciudades', builder: (context, state) => AgregarCiudadesPage()),
      GoRoute(path: '/creditos', builder: (context, state) => const CreditosPage()),

    ]);
    return MaterialApp.router( title: 'Weather App',
      routerConfig: router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = Future<List<Map<String, dynamic>>>.value([]);
// Cargamos url, user y pass desde el archivo .env
  static String get apiTokenUrl => dotenv.env['meteomatics_api_url'] ?? 'https://login.meteomatics.com/api/v1/token';
  static String get username => dotenv.env['meteomatics_user'] ?? '';
  static String get password => dotenv.env['meteomatics_pwd'] ?? '';
  Map<String, dynamic> city = {};
  String apiToken = '';
  int? selectedIndex;

  // Nuevo: Estado para mantener el índice actual del carrusel y persistirlo.
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('API URL: $apiTokenUrl');
    debugPrint('Username: $username');
    // imprime la contraseña de forma segura sin mostrarla completa
    debugPrint('Password: ${'*' * password.length}');
    obtenToken();
    // Reemplazamos _cargarYActualizarPrimeraCiudad por esta nueva función
    // que carga el índice guardado antes de actualizar el Future.
    _cargarCiudadesYIndice();
  }

  // Nuevo: Carga ciudades y el índice guardado de persistencia
  Future<void> _cargarCiudadesYIndice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('last_city_index');
    final ciudades = await _ciudadesGuardadas();

    setState(() {
      ciudadesGuardadas = Future.value(ciudades);
      // Validamos y establecemos el índice guardado
      if (ciudades.isNotEmpty && savedIndex != null && savedIndex >= 0 && savedIndex < ciudades.length) {
        _currentIndex = savedIndex;
      } else {
        _currentIndex = 0;
      }
    });
  }

  // Comentado: Esta función ya no se usa, la reemplaza _cargarCiudadesYIndice
  /*
  Future<void> _cargarYActualizarPrimeraCiudad() async {
    final ciudades = await _ciudadesGuardadas();
    setState(() {
      ciudadesGuardadas = Future.value(ciudades);
    });

    if (ciudades.isNotEmpty) {
      city = ciudades[0];
      debugPrint('Primera ciudad cargada: ${city['nombre']}');
      // Esperamos un poco para asegurarnos de que el token esté disponible
      await Future.delayed(const Duration(seconds: 1));
      await _actualizaClima(city);
    } else {
      debugPrint('No hay ciudades guardadas para actualizar el clima');
    }
  }
  */

  // Nuevo: Callback para que el carrusel nos informe el índice, lo actualice y persista.
  void _updateCurrentIndex(int index) async {
    // Si el índice realmente cambió
    if (_currentIndex != index) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_city_index', index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    return ciudadesString.map((ciudad) => json.decode(ciudad) as Map<String, dynamic>).toList();
  }

  void obtenToken() async {
    // Lógica para obtener el token de la API usando apiTokenUrl, username y password
    // y luego asignarlo a la variable apiToken
    // Si ya tenemos el token, no hacemos nada
    if (apiToken.isNotEmpty) return;
    // Aquí iría la lógica real para obtener el token
    String url = apiTokenUrl;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$username:$password'))}',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        apiToken = data['access_token'];
      });
      debugPrint('Token obtenido: $apiToken');
    } else {
      debugPrint('Error al obtener el token: ${response.statusCode}');
    }
  }

  // Agregamos el parámetro opcional {bool force = false}
  Future<void> _actualizaClima(Map<String, dynamic> ciudad, {bool force = false}) async {
    debugPrint('Actualizando clima para ${ciudad['nombre']}. Forzado: $force');

    if (apiToken.isEmpty) {
      debugPrint('No se puede actualizar el clima sin un token válido.');
      return;
    }

    bool actualizar = false;
    String nombreCiudad = ciudad['nombre'] ?? 'Desconocida';
    double latitud = ciudad['latitud'] ?? 0.0;
    double longitud = ciudad['longitud'] ?? 0.0;
    debugPrint('Ciudad: $nombreCiudad, Latitud: $latitud, Longitud: $longitud');
    String ultimaActualizacion = '';

    // Nueva lógica para decidir si actualizar
    if (force) {
      // Si el botón de refrescar fue presionado, forzamos la actualización
      actualizar = true;
      debugPrint('Actualización FORZADA por el usuario.');
    } else if (ciudad['ultima_actualizacion'] == null) {
      // Si es la primera vez (no hay fecha), actualizamos
      actualizar = true;
      debugPrint('Actualizando porque no hay fecha guardada.');
    } else {
      // Si no es forzado y hay fecha, revisamos si han pasado 60 min
      ultimaActualizacion = ciudad['ultima_actualizacion'];
      DateTime ultimaActualizacionDT = DateTime.parse(ultimaActualizacion);
      DateTime ahoraZ = DateTime.now().toUtc();
      Duration diferencia = ahoraZ.difference(ultimaActualizacionDT);

      if (diferencia.inMinutes >= 60) {
        actualizar = true;
        debugPrint('Actualizando porque han pasado ${diferencia.inMinutes} minutos.');
      } else {
        debugPrint('NO se actualiza, solo han pasado ${diferencia.inMinutes} minutos.');
      }
    }

    String hora_actualZ = DateTime.now().toUtc().toIso8601String();

    // Si es necesario actualizar, hacemos la llamada a la API
    if (actualizar) {
      String url = 'https://api.meteomatics.com/$hora_actualZ/t_2m:C,wind_speed_10m:ms,weather_symbol_1h:idx/$latitud,$longitud/json?access_token=$apiToken';
      debugPrint('URL de la API: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final climaData = json.decode(response.body);
        final data = climaData['data'];
        // Obtenemos los datos del clima
        final t2m = data[0]['coordinates'][0]['dates'][0]['value'];
        final windSpeed = data[1]['coordinates'][0]['dates'][0]['value'];
        final weatherSymbol = data[2]['coordinates'][0]['dates'][0]['value'];
        ultimaActualizacion = data[0]['coordinates'][0]['dates'][0]['date'];
        debugPrint('Clima para $nombreCiudad - Temperatura: $t2m, Viento: $windSpeed, Símbolo: $weatherSymbol');
        // Aquí actualizaríamos la ciudad con los nuevos datos
        ciudad['temperatura'] = t2m;
        ciudad['velocidad_viento'] = windSpeed;
        ciudad['simbolo_clima'] = weatherSymbol;
        ciudad['ultima_actualizacion'] = ultimaActualizacion;

        // Guardamos los cambios en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final ciudadesActualizadas = await ciudadesGuardadas;
        final ciudadesString = ciudadesActualizadas.map((c) {
          if (c['nombre'] == ciudad['nombre']) {
            return json.encode(ciudad);
          }
          return json.encode(c);
        }).toList();
        await prefs.setStringList('ciudades', ciudadesString);

        setState(() {
          // Esto fuerza la actualización del FutureBuilder en el carrusel
          ciudadesGuardadas = Future.value(ciudadesActualizadas.map((c) {
            if (c['nombre'] == ciudad['nombre']) {
              return ciudad;
            }
            return c;
          }).toList());
        });

        debugPrint('$nombreCiudad Temperatura: $t2m °C, Viento: $windSpeed m/s');
        if(mounted) {
          // El setState dentro de la actualización del Future ya reconstruye el widget,
          // no necesitamos este setState extra si ya actualizamos ciudadesGuardadas.
          // setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Clima actualizado: $t2m °C')),
          );
        }

      } else {
        debugPrint('Error al obtener el clima: ${response.statusCode}');
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.title,
      body: ClimaCarouselView(
        // Nuevo: Usamos una Key para forzar a Flutter a reutilizar el State del carrusel,
        // lo que evita que el PageController se reinicie a 0.
        key: const ValueKey('ClimaCarouselViewKey'),
        ciudadesGuardadas: ciudadesGuardadas,
        actualizaClima: _actualizaClima,
        // Nuevo: Pasamos el índice actual y la función para actualizarlo.
        initialIndex: _currentIndex,
        onPageChanged: _updateCurrentIndex,
      ),
    );
  }
}