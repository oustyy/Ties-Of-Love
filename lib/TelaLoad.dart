import 'package:flutter/material.dart';
import 'LoginPage.dart';

class TelaLoad extends StatelessWidget {
  const TelaLoad({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCAC2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Topo: Título + Logo
              Column(
                children: [
                  const Text(
                    'Ties Of Love',
                    style: TextStyle(
                      fontFamily: 'Playball',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF5C75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo.jpg',
                    height: 130,
                    width: 120,
                  ),
                ],
              ),

              // Meio: Imagem ilustrativa
              Expanded(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 450,
                      maxHeight: 600,
                    ),
                    child: Image.asset(
                      'assets/images/coracao.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Rodapé: Frase + Botão
              Column(
                children: [
                  const Text(
                    '“Onde seu amor floresce”',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C75),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Iniciar',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}