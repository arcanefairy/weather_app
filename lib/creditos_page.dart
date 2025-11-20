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
class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Créditos",
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF496BCA), Color(0xFF173B9D)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [                
                const Icon(Icons.cloud_circle_outlined, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "Weather App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Text(
                  "Versión 1.0.0",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                
                const SizedBox(height: 40), 

                _buildSectionCard(
                  title: "CÓDIGO BASE & ASESORÍA",
                  icon: Icons.school_rounded,
                  content: [
                    "Agradecimiento especial al",
                    "Profesor Federico Miguel Cirett Galan",
                    "por el código base y guía en el desarrollo."
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Equipo de Desarrollo",
                  icon: Icons.groups_rounded,
                  content: [
                    "Adriana León Camacho",
                    "Elda Berenice Matus Valencia",
                    "Alex Eduardo Soto Quiñonez"
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: "Librerías",
                  icon: Icons.layers_rounded, 
                  contentWidgets: [
                    _buildTechItem("Flutter Map", "Mapas y selección de ciudades\n(docs.fleaflet.dev)"),
                    const SizedBox(height: 12),
                    _buildTechItem("MeteoAPI", "Datos meteorológicos\n(meteomatics.com)"),
                    const SizedBox(height: 12),
                    _buildTechItem("Weather Icons", "Iconografía del clima"),
                  ],
                ),                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    List<String>? content,
    List<Widget>? contentWidgets,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),      
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                
                if (content != null)
                  ...content.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14, 
                        height: 1.4,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  )),
                                  
                if (contentWidgets != null)
                  ...contentWidgets,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.left,
          style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.3),
        ),
      ],
    );
  }
}