import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'settings_controller.dart';
import 'app_scaffold.dart';

class AgregarCiudadesPage extends StatefulWidget {
  const AgregarCiudadesPage({super.key});
  @override
  State<AgregarCiudadesPage> createState() => _AgregarCiudadesPageState();
}

class _AgregarCiudadesPageState extends State<AgregarCiudadesPage> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();
  List ciudadData = [];
  double dLat = 29.0948207;
  double dLon = -110.9692202;
  double selectedLat = 29.0948207;
  double selectedLon = -110.9692202;
  int? selectedIndex;
  Future<List<Map<String, dynamic>>> ciudadesGuardadas = Future<List<Map<String, dynamic>>>.value([]);
  @override
  void initState() {
    super.initState();
    ciudadesGuardadas = _ciudadesGuardadas();
  }
  

  @override
    Widget build(BuildContext context) {
    return AppScaffold(
      title: "Agregar Ciudades",
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: [
              Text(
                "Aquí puedes agregar nuevas ciudades",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Text("Ciudad"),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ingresa el nombre de la ciudad',
                ),
              ),
              // Agregar botón para buscar y agregar ciudad
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Buscar Ciudad"),
                onPressed: () async {
                  final ciudad = _cityController.text;
                  if (ciudad.isNotEmpty) {
                    // Lógica para buscar y agregar la ciudad
                    final resultados = await _buscarCiudad(ciudad);
                    if (!mounted) return;
                    setState(() {
                      ciudadData = resultados;

                    });
                    debugPrint(ciudadData.toString());
                  }
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height:200,
                child: ListView.builder(
                  itemCount: ciudadData.length,
                  itemBuilder: (context, index) {
                    final ciudadInfo = ciudadData[index];
                    return ListTile(
                      title: Text(ciudadInfo['display_name']),
                      subtitle: Text('Lat: ${ciudadInfo['lat']}, Lon: ${ciudadInfo['lon']}'),
                      selected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          _cityController.text = ciudadInfo['display_name'];
                          selectedLat = double.parse(ciudadInfo['lat']);
                          selectedLon = double.parse(ciudadInfo['lon']);
                          _mapController.move(LatLng(selectedLat, selectedLon), 10);
                        });
                      },
                    );
                  },

                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: ciudadesGuardadas,
                  builder:(context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } 
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final data = snapshot.data ?? const <Map<String, dynamic>>[];
                    if (data.isEmpty) {
                      return const Center(child: Text('No hay ciudades guardadas.'));
                    }
                    // Lista de ciudades guardadas
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final ciudad = data[index];
                        return ListTile(
                          title: Text(ciudad['nombre'].toString()),
                          subtitle: Text('Lat: ${ciudad['latitud']}, Lon: ${ciudad
                          ['longitud']}'),
                          // --- BOTÓN DE ELIMINAR CIUDAD ---
                          // Botón de eliminar a la derecha
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline), // Icono de basura
                            color: Colors.red[700], // Color rojo para el icono
                            tooltip: 'Eliminar ciudad',
                            onPressed: () async {
                              // Mostrar el popup de confirmación de que el usuario desea eliminar la ciudad
                              final bool? confirmar = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text(
                                        '¿Estás seguro de que deseas eliminar ${ciudad['nombre']}?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Eliminar',
                                            style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Si el usuario confirma, eliminamos la ciudad
                              if (confirmar == true) {
                                _eliminarCiudad(ciudad);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ciudad eliminada: ${ciudad['nombre']}')),
                                );
                                // Refrescamos la lista en la UI
                                setState(() {
                                  ciudadesGuardadas = _ciudadesGuardadas();
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                )
              ),
              
              
              SizedBox(height: 20),
              //Aquí va el botón para agregar la ciudad seleccionada
              SizedBox(
                child: ElevatedButton(
                  child: const Text("Agregar ciudad"),
                  onPressed: () {
                    _agregarCiudad(_cityController.text, selectedLat, selectedLon);
                    _cityController.clear(); // Limpiamos el texto
                  },
                )
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                // Agregar mapa con flutter_map con control de zoom.
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(selectedLat, selectedLon),
                    initialZoom: 10,
                    maxZoom: 18,
                    minZoom: 3,

                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.weather_app',
                      subdomains: ['a', 'b', 'c'],
                    ),
                  ],
                ),

              ),
            ]
          ),
          Divider(color: Colors.grey.shade300),
        ],
      ),
        )
      ),
    );
  }

  
  Future<List> _buscarCiudad(String nombreCiudad) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$nombreCiudad&format=json&addressdetails=1';
    debugPrint('URL de búsqueda: $url');
    
    try {
      // Agregamos el header 'User-Agent' para cumplir la política de Nominatim
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'com.example.weather_app', 
        },
      );
      

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data;
        }
      } else {
        debugPrint('Error de Nominatim: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('--- ERROR DE RED ---');
      debugPrint('Error en la petición HTTP: $e');
      debugPrint('--- FIN ERROR DE RED ---');
    }
    
    return [];
  }
  
  void _agregarCiudad(String nombre, double lat , double lon) async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> listaCiudadesGuardadas = prefs.getStringList('ciudades') ?? [];
    String ciudadString = json.encode({
      'nombre': nombre,
      'latitud': lat,
      'longitud': lon,
    });
    listaCiudadesGuardadas.add(ciudadString);
    await prefs.setStringList('ciudades', listaCiudadesGuardadas);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ciudad agregada: $nombre')),
    );
    //Forzamos la reconstrucción
    setState(() {
      ciudadesGuardadas = _ciudadesGuardadas();
    });
  }

  // --- FUNCIÓN PARA ELIMINAR UNA CIUDAD ---
  void _eliminarCiudad(Map<String, dynamic> ciudadAEliminar) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaCiudadesGuardadas = prefs.getStringList('ciudades') ?? [];

    // Convertir strings a mapas
    List<Map<String, dynamic>> ciudades = listaCiudadesGuardadas
        .map((c) => json.decode(c) as Map<String, dynamic>)
        .toList();

    // Eliminar la ciudad (usando el nombre como identificador único)
    ciudades.removeWhere((c) => c['nombre'] == ciudadAEliminar['nombre']);

    // Convertir mapas de nuevo a strings
    List<String> nuevaListaString = ciudades.map((c) => json.encode(c)).toList();

    // Guardar la lista actualizada
    await prefs.setStringList('ciudades', nuevaListaString);
  }

  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    return ciudadesString.map((ciudadStr) => json.decode(ciudadStr) as Map<String, 
    dynamic>).toList();
  }

}