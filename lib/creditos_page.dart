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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CRÉDITOS",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 20),
              Text(
                "Desarrollado por Adriana León Camacho, Elda Berenice Matus Valencia y Alex Eduardo Soto Quiñonez",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10),
              Text(
                "Iconos de clima proporcionados por Weather Icons",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10),
              Text(
                "Datos meteorológicos proporcionados por MeteoAPI (https://www.meteomatics.com/en/)",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10),
              Text(
                "Mapa para selección de ciudades proporcionado por Flutter Map (https://docs.fleaflet.dev/)",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}