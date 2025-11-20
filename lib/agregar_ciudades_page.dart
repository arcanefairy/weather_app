import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF121212),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                _buildGlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.search, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "BUSCAR NUEVA CIUDAD",
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      
                      TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(12),
                             borderSide: const BorderSide(color: Colors.white),
                          ),
                          hintText: 'Nombre de la ciudad',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.white.withOpacity(0.2))
                            ),
                          ),
                          child: const Text("BUSCAR"),
                          onPressed: () async {
                            final ciudad = _cityController.text;
                            if (ciudad.isNotEmpty) {
                              FocusScope.of(context).unfocus(); 
                              final resultados = await _buscarCiudad(ciudad);
                              if (!mounted) return;
                              setState(() {
                                ciudadData = resultados;
                                selectedIndex = null; 
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),              
                if (ciudadData.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Resultados:",
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150, 
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: ciudadData.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10),
                      itemBuilder: (context, index) {
                        final ciudadInfo = ciudadData[index];
                        final isSelected = selectedIndex == index;
                        return ListTile(
                          title: Text(
                            ciudadInfo['display_name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            'Lat: ${ciudadInfo['lat']}, Lon: ${ciudadInfo['lon']}',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                          ),
                          selected: isSelected,
                          selectedTileColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              selectedLat = double.parse(ciudadInfo['lat']);
                              selectedLon = double.parse(ciudadInfo['lon']);
                              _mapController.move(LatLng(selectedLat, selectedLon), 10);
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                if (selectedIndex != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("AGREGAR CIUDAD", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        final nombreCiudad = ciudadData[selectedIndex!]['display_name'].toString().split(',')[0];
                        _agregarCiudad(nombreCiudad, selectedLat, selectedLon);
                        
                        setState(() {
                          ciudadData = []; 
                          selectedIndex = null;
                          _cityController.clear();
                        });
                      },
                    ),
                  ),
                
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        FlutterMap(
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
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(selectedLat, selectedLon),
                                  width: 80,
                                  height: 80,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                const Row(
                  children: [
                    Icon(Icons.bookmark, color: Colors.white70),
                    SizedBox(width: 10),
                    Text(
                      "CIUDADES GUARDADAS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: ciudadesGuardadas,
                  builder:(context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } 
                    final data = snapshot.data ?? const <Map<String, dynamic>>[];
                    if (data.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: const Text(
                          'No tienes ciudades guardadas aún.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final ciudad = data[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildGlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.location_city, color: Colors.white),
                              title: Text(
                                ciudad['nombre'].toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${double.parse(ciudad['latitud'].toString()).toStringAsFixed(2)}, ${double.parse(ciudad['longitud'].toString()).toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                              ),

                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmarEliminacion(ciudad),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }

  Future<void> _confirmarEliminacion(Map<String, dynamic> ciudad) async {
    final bool? confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: const Text('Confirmar eliminación', style: TextStyle(color: Colors.white)),
          content: Text(
            '¿Estás seguro de que deseas eliminar ${ciudad['nombre']}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      _eliminarCiudad(ciudad);
    }
  }
  
  Future<List> _buscarCiudad(String nombreCiudad) async {
    final url = 'https://nominatim.openstreetmap.org/search?q=$nombreCiudad&format=json&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'com.example.weather_app'});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error: $e');
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
    setState(() {
      ciudadesGuardadas = _ciudadesGuardadas();
    });
  }

  void _eliminarCiudad(Map<String, dynamic> ciudadAEliminar) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaCiudadesGuardadas = prefs.getStringList('ciudades') ?? [];
    List<Map<String, dynamic>> ciudades = listaCiudadesGuardadas
        .map((c) => json.decode(c) as Map<String, dynamic>)
        .toList();
    ciudades.removeWhere((c) => c['nombre'] == ciudadAEliminar['nombre']);
    List<String> nuevaListaString = ciudades.map((c) => json.encode(c)).toList();
    await prefs.setStringList('ciudades', nuevaListaString);
    
    if (!mounted) return;
    setState(() {
      ciudadesGuardadas = _ciudadesGuardadas();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ciudad eliminada'), backgroundColor: Colors.redAccent),
    );
  }

  Future<List<Map<String, dynamic>>> _ciudadesGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final ciudadesString = prefs.getStringList('ciudades') ?? [];
    return ciudadesString.map((ciudadStr) => json.decode(ciudadStr) as Map<String, dynamic>).toList();
  }
}