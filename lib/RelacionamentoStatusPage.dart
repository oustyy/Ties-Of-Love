import 'dart:io';
import 'package:flutter/material.dart';

class RelacionamentoStatusPage extends StatelessWidget {
  final File? userImage;
  final String userName;
  final File? partnerImage;
  final String partnerName;
  final int relationshipDays;

  const RelacionamentoStatusPage({
    super.key,
    this.userImage,
    required this.userName,
    this.partnerImage,
    required this.partnerName,
    required this.relationshipDays,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0), // Fundo rosa claro
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Dias juntos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA0B0), // Rosa escuro
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '$relationshipDays dias juntos',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Avatares e coração
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      userImage != null ? FileImage(userImage!) : null,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFFF5C75),
                  size: 32,
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      partnerImage != null ? FileImage(partnerImage!) : null,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Nomes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'DancingScript',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 32),
                Text(
                  partnerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'DancingScript',
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Barra inferior personalizada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA0B0), // Rosa escuro
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.photo_album,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Ação futura
                      },
                    ),
                    FloatingActionButton(
                      backgroundColor: const Color(0xFFFF5C75), // Rosa escuro
                      onPressed: () {
                        // Ação futura
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Ação futura
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}