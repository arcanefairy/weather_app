import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Color solidBlue = const Color(0xFF496BCA);

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  static Future<String?> _getCustomText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('custom_text') ?? 'Menú';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: solidBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      
      body: body,

      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: solidBlue,
              ),
              child: FutureBuilder<String?>(
                future: _getCustomText(),
                builder: (context, snapshot) {
                  final drawerText = snapshot.data ?? 'Menú';
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                      
                      const Icon(Icons.menu, color: Colors.white, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        drawerText, 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ],
                  );
                },
              ),
            ),

            _buildDrawerItem(context, Icons.sunny, 'Inicio', '/'),
            _buildDrawerItem(context, Icons.location_city, 'Agregar Ciudades', '/agregar_ciudades'),
            _buildDrawerItem(context, Icons.info_outline, 'Créditos', '/creditos'),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: Colors.white24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title, 
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)
      ),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
      hoverColor: Colors.white.withOpacity(0.05),
    );
  }
}