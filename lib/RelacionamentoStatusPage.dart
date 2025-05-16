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
      backgroundColor: const Color(0xFFFFE6F0),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA0B0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '$relationshipDays dias juntos',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      userImage != null ? FileImage(userImage!) : null,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 32,
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 45,
                  backgroundImage:
                      partnerImage != null ? FileImage(partnerImage!) : null,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Cursive',
                  ),
                ),
                const SizedBox(width: 32),
                Text(
                  partnerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Cursive',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_album, size: 32),
                    onPressed: () {
                      // ação futura
                    },
                  ),
                  FloatingActionButton(
                    backgroundColor: const Color(0xFFFF5C75),
                    onPressed: () {
                      // ação futura
                    },
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 32),
                    onPressed: () {
                      // ação futura
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
