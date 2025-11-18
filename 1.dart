import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  List<dynamic> _suggestions = [];
  String _temperature = '';
  String _humidity = '';
  String _windSpeed = '';
  String _cityName = '';
  String _errorMessage = '';

  // 🔍 Buscar sugestões de cidades
  Future<void> fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final url =
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=6&language=pt&format=json';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _suggestions = data['results'] ?? [];
      });
    }
  }

  // 🌦 Buscar clima pela latitude e longitude
  Future<void> fetchWeather(double lat, double lon, String name) async {
    final url =
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final weather = json.decode(response.body);

        setState(() {
          _cityName = name;
          _temperature = "${weather['current_weather']['temperature']} °C";
          _windSpeed = "${weather['current_weather']['windspeed']} km/h";
          _humidity = "Não disponível";
          _errorMessage = '';
        });
      } else {
        setState(() => _errorMessage = "Erro ao obter o clima.");
      }
    } catch (e) {
      setState(() => _errorMessage = "Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Previsão do Tempo"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Campo de texto estilizado
            TextField(
              controller: _cityController,
              onChanged: fetchCitySuggestions,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: "Digite o nome da cidade",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🔽 Lista de sugestões
            if (_suggestions.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final city = _suggestions[index];
                      return ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text("${city['name']} - ${city['country']}"),
                        subtitle: Text(
                          "Lat: ${city['latitude']} | Lon: ${city['longitude']}",
                        ),
                        onTap: () {
                          _cityController.text = city['name'];
                          setState(() => _suggestions = []);
                          fetchWeather(
                            city['latitude'],
                            city['longitude'],
                            city['name'],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // 🌤 Card bonito com informações do clima
            if (_temperature.isNotEmpty)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        _cityName,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      Icon(Icons.wb_sunny, size: 60, color: Colors.orange),

                      SizedBox(height: 10),

                      Text(
                        "🌡 Temperatura: $_temperature",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "💧 Umidade: $_humidity",
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "💨 Vento: $_windSpeed",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
