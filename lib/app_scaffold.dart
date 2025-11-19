import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_scaffold.dart';



class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

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
      appBar: AppBar(title: Text(title)),
      body: body,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 78, 11, 102),
            ),
              child: FutureBuilder<String?>(
                future: _getCustomText(),
              builder: (context, snapshot) {
                final drawerText = snapshot.data ?? 'Menú';
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu, color: Colors.white, size: 40),
                    SizedBox(height: 8),
                    Text(drawerText, style: TextStyle(color: Colors.white, fontSize: 20)),
                    SizedBox(height: 8),
                    
                  ],
                );
              },
            ),
            ),
            ListTile(
              leading: const Icon(Icons.sunny),
              title: const Text('Inicio'),
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Agregar Ciudades'),
              onTap: () {
                context.go('/agregar_ciudades');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Créditos'),
              onTap: () {
                context.go('/creditos');
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}