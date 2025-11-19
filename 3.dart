import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TrunfoPage(),
    );
  }
}

class TrunfoPage extends StatefulWidget {
  const TrunfoPage({super.key});

  @override
  State<TrunfoPage> createState() => _TrunfoPageState();
}

class _TrunfoPageState extends State<TrunfoPage> {
  Map<String, dynamic>? jogador;
  Map<String, dynamic>? inimigo;

  int vitJ = 0;
  int vitI = 0;

  String atributoEscolhido = "";
  List<String> atributos = ["ataque", "defesa", "velocidade"];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    carregarRodada();
  }

  // ----------- API -------------
  Future<Map<String, dynamic>> carregarDigimon() async {
    final id = Random().nextInt(1400);
    final url = "https://digi-api.com/api/v1/digimon/$id";

    final r = await http.get(Uri.parse(url));

    if (r.statusCode != 200) {
      return await carregarDigimon();
    }

    final d = json.decode(r.body);

    return {
      "name": d["name"],
      "image": d["images"][0]["href"],

      // Stats gerados para ser estilo trunfo
      "ataque": Random().nextInt(100),
      "defesa": Random().nextInt(100),
      "velocidade": Random().nextInt(100),
    };
  }

  Future<void> carregarRodada() async {
    setState(() => loading = true);

    jogador = await carregarDigimon();
    inimigo = await carregarDigimon();

    atributoEscolhido = atributos[Random().nextInt(atributos.length)];

    setState(() => loading = false);
  }

  // ----------- JOGAR -------------
  void jogar() {
    final v1 = jogador![atributoEscolhido];
    final v2 = inimigo![atributoEscolhido];

    if (v1 > v2) vitJ++;
    if (v2 > v1) vitI++;

    carregarRodada();
  }

  // ----------- COMPONENTES UI -------------
  Widget statBar(String nome, int valor, bool destaque) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          style: TextStyle(
            color: destaque ? Colors.cyanAccent : Colors.white,
            fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Container(
          height: 8,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: (valor / 100) * 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: destaque
                      ? [Colors.cyanAccent, Colors.blue]
                      : [Colors.white54, Colors.white24],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget carta(Map<String, dynamic> d, bool isPlayer) {
    return Column(
      children: [
        // -------- RÓTULO ("VOCÊ" ou "INIMIGO") --------
        Text(
          isPlayer ? "VOCÊ" : "INIMIGO",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isPlayer ? Colors.cyanAccent : Colors.redAccent,
          ),
        ),

        const SizedBox(height: 10),

        // -------- CARTA EM SI --------
        Container(
          width: 180,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF111111), Color(0xFF1b1b1b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            // BORDA DIFERENCIADA
            border: Border.all(
              color: isPlayer ? Colors.cyanAccent : Colors.redAccent,
              width: 2.5,
            ),

            // SOMBRA ESPECIAL
            boxShadow: [
              BoxShadow(
                color: (isPlayer ? Colors.cyanAccent : Colors.redAccent)
                    .withOpacity(0.6),
                blurRadius: 16,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  d["image"],
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                d["name"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isPlayer ? Colors.cyanAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),

              statBar("Ataque", d["ataque"], atributoEscolhido == "ataque"),
              statBar("Defesa", d["defesa"], atributoEscolhido == "defesa"),
              statBar(
                "Velocidade",
                d["velocidade"],
                atributoEscolhido == "velocidade",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------- TELA PRINCIPAL -------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Trunfo — Digimon"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 15),

                // Atributo sorteado
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                  ),
                  child: Text(
                    "Atributo sorteado:  ${atributoEscolhido.toUpperCase()}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CARTAS LADO A LADO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    carta(inimigo!, false), // esquerda = inimigo
                    carta(jogador!, true), // direita = jogador
                  ],
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: jogar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shadowColor: Colors.cyan,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "JOGAR!",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Vitórias Jogador: $vitJ",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "Vitórias Inimigo: $vitI",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
    );
  }
}
