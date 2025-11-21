import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

class ClimaCarouselView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> ciudadesGuardadas;
  // Cambiamos la firma de la función para que coincida con la nueva
  final Function(Map<String, dynamic>, {bool force}) actualizaClima;

  // Nuevo: Parámetros del índice que se manejan en main.dart
  final int initialIndex;
  final Function(int) onPageChanged;

  const ClimaCarouselView({
    Key? key,
    required this.ciudadesGuardadas,
    required this.actualizaClima,
    // Nuevo: Requerimos el índice y el callback
    required this.initialIndex,
    required this.onPageChanged,
  }) : super(key: key);
  @override
  State<ClimaCarouselView> createState() => _ClimaCarouselViewState();
}

class _ClimaCarouselViewState extends State<ClimaCarouselView> {
  // Comentado: Ya no se usa _currentIndex aquí, el padre lo maneja.
  // int _currentIndex = 0;

  // Comentado: Ya no se usa PageController como estado (final). Lo crearemos en el build.
  // final PageController _pageController = PageController();

  // Estado local para almacenar las ciudades (para usarlas en onPressed)
  List<Map<String, dynamic>> _currentCiudades = [];

  // Comentado: Ya no necesitamos dispose para PageController porque se recreará.
  /*
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  */

  // Mapa de íconos del clima (sin cambios)
  IconData _obtenerIconoClima(int simbolo) {
    switch (simbolo) {
      case 0:
        return WeatherIcons.na;
      case 1:
        return WeatherIcons.day_sunny;
      case 2:
        return WeatherIcons.day_sunny_overcast;
      case 3:
        return WeatherIcons.day_cloudy;
      case 4:
        return WeatherIcons.cloud;
      case 5:
        return WeatherIcons.rain;
      case 6:
        return WeatherIcons.sleet;
      case 7:
        return WeatherIcons.snow;
      case 8:
        return WeatherIcons.showers;
      case 9:
        return WeatherIcons.day_snow_wind;
      case 10:
        return WeatherIcons.day_sleet_storm;
      case 11:
        return WeatherIcons.day_fog;
      case 12:
        return WeatherIcons.fog;
      case 13:
        return WeatherIcons.rain_mix;
      case 14:
        return WeatherIcons.thunderstorm;
      case 15:
        return WeatherIcons.sprinkle;
      case 16:
        return WeatherIcons.sandstorm;
      case 101:
        return WeatherIcons.night_clear;
      case 102:
        return WeatherIcons.night_alt_cloudy_gusts;
      case 103:
        return WeatherIcons.night_partly_cloudy;
      case 104:
        return WeatherIcons.night_cloudy;
      case 105:
        return WeatherIcons.night_rain;
      case 106:
        return WeatherIcons.night_sleet;
      case 107:
        return WeatherIcons.night_snow;
      case 108:
        return WeatherIcons.night_showers;
      case 109:
        return WeatherIcons.night_snow_wind;
      case 110:
        return WeatherIcons.night_sleet_storm;
      case 111:
        return WeatherIcons.night_fog;
      case 112:
        return WeatherIcons.fog;
      case 113:
        return WeatherIcons.rain_mix;
      case 114:
        return WeatherIcons.thunderstorm;
      case 115:
        return WeatherIcons.sprinkle;
      case 116:
        return WeatherIcons.sandstorm;
      default:
        return WeatherIcons.na;
    }
  }

  String _obtenerDescripcionClima(int simbolo) {
    switch (simbolo) {
      case 0:
        return 'Sin datos';
      case 1:
        return 'Despejado';
      case 2:
        return 'Mayormente despejado';
      case 3:
        return 'Parcialmente Nublado';
      case 4:
        return 'Nublado';
      case 5:
        return 'Lluvia';
      case 6:
        return 'Aguanieve';
      case 7:
        return 'Nieve';
      case 8:
        return 'Chubascos';
      case 9:
        return 'Chubascos de nieve';
      case 10:
        return 'Chubascos de aguanieve';
      case 11:
        return 'Niebla ligera';
      case 12:
        return 'Niebla densa';
      case 13:
        return 'Lluvia engelante';
      case 14:
        return 'Tormenta eléctrica';
      case 15:
        return 'Llovizna';
      case 16:
        return 'Tormenta de arena';
      case 101:
        return 'Despejado (noche)';
      case 102:
        return 'Mayormente despejado (noche)';
      case 103:
        return 'Parcialmente nublado (noche)';
      case 104:
        return 'Nublado (noche)';
      case 105:
        return 'Lluvia (noche)';
      case 106:
        return 'Aguanieve (noche)';
      case 107:
        return 'Nieve (noche)';
      case 108:
        return 'Chubascos (noche)';
      case 109:
        return 'Chubascos de nieve (noche)';
      case 110:
        return 'Chubascos de aguanieve (noche)';
      case 111:
        return 'Niebla ligera (noche)';
      case 112:
        return 'Niebla densa (noche)';
      case 113:
        return 'Lluvia engelante (noche)';
      case 114:
        return 'Tormenta eléctrica (noche)';
      case 115:
        return 'Llovizna (noche)';
      case 16:
        return 'Tormenta de arena (noche)';
      default:
        return 'Desconocido';
    }
  }

  String _formatearHora(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Desconocido';
    try {
      final fecha = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(fecha.toLocal());
    } catch (e) {
      return 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: widget.ciudadesGuardadas,
      builder: (context, snapshot) {
        // (Loading, Error, y Empty states se mantienen igual)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF496BCA), const Color(0xFF173B9D)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF496BCA), const Color(0xFF173B9D)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text('Error al cargar ciudades: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        final ciudades = snapshot.data ?? [];
        _currentCiudades = ciudades; // Sincronizamos la lista de ciudades resuelta

        if (ciudades.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF496BCA), const Color(0xFF173B9D)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    color: Colors.white,
                    size: 60,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'No hay ciudades guardadas',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        }

        // Mostrar el Carousel de ciudades
        return _buildCarousel(ciudades);
      },
    );
  }

  Widget _buildCarousel(List<Map<String, dynamic>> ciudades) {

    // Nuevo: Creamos el PageController justo antes de usarlo.
    // Esto fuerza la inicialización en la posición correcta con cada build.
    final PageController localController = PageController(
        initialPage: widget.initialIndex < ciudades.length ? widget.initialIndex : 0
    );

    // Envolvemos todo en una Columna con MainAxisAlignment.center
    // para centrar nuestro carrusel (que ahora es más pequeño)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Damos una altura fija al carrusel
        SizedBox(
          height: 600, // <-- ¡AJUSTA ESTA ALTURA COMO PREFIERAS!
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. El PageView que contiene las tarjetas
              PageView.builder(
                // Usamos el controlador local que acabamos de crear
                controller: localController,
                itemCount: ciudades.length,
                itemBuilder: (context, index) {
                  final ciudad = ciudades[index];
                  // Usamos GestureDetector para replicar el 'onTap'
                  return GestureDetector(
                    // Al tocar la tarjeta, actualiza normal (force: false)
                    onTap: () => widget.actualizaClima(ciudad, force: false),
                    child: _buildCiudadCard(ciudad),
                  );
                },
                // Actualizamos el índice en el padre cuando el usuario desliza
                onPageChanged: (index) {
                  widget.onPageChanged(index);
                },
              ),

              // 2. Botón de Refrescar (ya existía)
              Positioned(
                top: 10, // Ajustamos la posición
                right: 15,
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {
                    // Nuevo: Leemos la posición actual del controlador local para saber qué ciudad actualizar
                    final int currentIndex = localController.page?.round() ?? 0;

                    if (currentIndex < _currentCiudades.length) {
                      // Al presionar el botón, FORZAMOS la actualización de la ciudad en esa posición
                      widget.actualizaClima(_currentCiudades[currentIndex], force: true);
                    }
                  },
                ),
              ),

              // 3. Botón Izquierdo (Atrás)
              Positioned(
                left: 15,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white70, size: 30),
                  onPressed: () {
                    localController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),

              // 4. Botón Derecho (Adelante)
              Positioned(
                right: 15,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 30),
                  onPressed: () {
                    localController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCiudadCard(Map<String, dynamic> ciudad) {
    final temperatura = ciudad['temperatura'] ?? 0.0;
    final simoboloClima = ciudad['simbolo_clima'] ?? 0;
    final velocidadViento = ciudad['velocidad_viento'] ?? 0.0;
    final nombre = ciudad['nombre'] ?? 'Desconocido';
    final ultimaActualizacion = ciudad['ultima_actualizacion'] ?? '';

    // Agregué un Padding para que la tarjeta no esté pegada
    // a los bordes del PageView.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF496BCA), const Color(0xFF173B9D)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [

                const Spacer(flex: 2), // <-- Spacer de la vez pasada

                // Nombre de la ciudad
                Text(
                  nombre,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                  textAlign: TextAlign.center, // Centrar nombre
                ),
                const SizedBox(height: 30), // <-- Spacer de la vez pasada
                // Icono del clima
                Icon(
                  _obtenerIconoClima(simoboloClima),
                  color: Colors.white,
                  size: 120,
                ),
                const SizedBox(height: 10),
                // Temperatura
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start, //Alinear
                  children: [
                    Text(
                      '${temperatura.toStringAsFixed(1)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w200),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12), //Ajustar
                      child: Text(
                        '°C',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Descripción del clima
                Text(
                  _obtenerDescripcionClima(simoboloClima),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 25), // Más espacio
                // Puse los items de info en una Fila (Row)
                // para que aparezcan uno al lado del otro.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoItem(
                        Icons.air,
                        '${velocidadViento.toStringAsFixed(1)} m/s',
                        'Viento',
                      ),
                      _buildInfoItem(
                        Icons.access_time,
                        _formatearHora(ultimaActualizacion),
                        'Última actualización',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Spacer(flex: 1), // <-- Spacer de la vez pasada
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }
}