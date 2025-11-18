import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const CardGameApp());
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CardGameScreen(),
    );
  }
}

class CardGameScreen extends StatefulWidget {
  @override
  State<CardGameScreen> createState() => _CardGameScreenState();
}

class _CardGameScreenState extends State<CardGameScreen>
    with SingleTickerProviderStateMixin {
  String leftCardImg = "";
  String rightCardImg = "";
  int playerWins = 0;
  int cpuWins = 0;
  String resultText = "";

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final Map<String, int> cardValues = {
    "ACE": 14,
    "KING": 13,
    "QUEEN": 12,
    "JACK": 11,
    "10": 10,
    "9": 9,
    "8": 8,
    "7": 7,
    "6": 6,
    "5": 5,
    "4": 4,
    "3": 3,
    "2": 2,
  };

  @override
  void initState() {
    super.initState();
    drawCards();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> drawCards() async {
    final url = Uri.parse(
      "https://deckofcardsapi.com/api/deck/new/draw/?count=2",
    );
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final card1 = data["cards"][0];
    final card2 = data["cards"][1];

    _controller.reset();
    setState(() {
      leftCardImg = card1["image"];
      rightCardImg = card2["image"];
    });

    _controller.forward();

    _compareCards(card1["value"], card2["value"]);
  }

  void _compareCards(String cpuValue, String playerValue) {
    final cpu = cardValues[cpuValue]!;
    final player = cardValues[playerValue]!;

    String msg;

    if (player > cpu) {
      playerWins++;
      msg = "Você venceu!";
    } else if (cpu > player) {
      cpuWins++;
      msg = "CPU venceu!";
    } else {
      msg = "Empate!";
    }

    setState(() {
      resultText = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Título estilizado
              Text(
                "Jogo de Cartas",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.95),
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // Placar bonito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _scoreCard("Você", playerWins, Colors.greenAccent),
                  _scoreCard("CPU", cpuWins, Colors.redAccent),
                ],
              ),

              const SizedBox(height: 35),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _cardWidget(leftCardImg, "CPU"),
                    _cardWidget(rightCardImg, "Você"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                resultText,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: drawCards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  "Nova Partida",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ===== WIDGETS ESTILIZADOS =====

  Widget _scoreCard(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$score",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardWidget(String img, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 20, color: Colors.white)),
        const SizedBox(height: 10),
        Container(
          width: 150,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: img.isEmpty
                ? Container(
                    color: Colors.white.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : Image.network(img, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
