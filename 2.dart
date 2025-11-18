import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicionário Inglês',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DictionaryPage(),
    );
  }
}

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _controller = TextEditingController();
  String? definition;
  bool loading = false;
  String? errorMessage;

  Future<void> fetchDefinition(String word) async {
    setState(() {
      loading = true;
      errorMessage = null;
      definition = null;
    });

    final url = Uri.parse(
      "https://api.dictionaryapi.dev/api/v2/entries/en/$word",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Pega a primeira definição
        final firstDefinition =
            data[0]["meanings"][0]["definitions"][0]["definition"];

        setState(() {
          definition = firstDefinition;
        });
      } else {
        setState(() {
          errorMessage = "Definição não encontrada para '$word'.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao buscar definição.";
      });
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dicionário Inglês")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Digite uma palavra em inglês",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  fetchDefinition(_controller.text.trim());
                }
              },
              child: const Text("Buscar definição"),
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (definition != null)
              Text(
                "Definição:\n$definition",
                style: const TextStyle(fontSize: 18),
              ),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
