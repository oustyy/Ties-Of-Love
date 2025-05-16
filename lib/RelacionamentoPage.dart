import 'package:flutter/material.dart';
import 'package:flutter_application_1/RelacionamentoStatusPage.dart';
import 'dart:io';

class RelacionamentoPage extends StatelessWidget {
  final String userImageUrl;
  final String partnerImageUrl;

  RelacionamentoPage({
    required this.userImageUrl,
    required this.partnerImageUrl,
  });

  final TextEditingController tempoController = TextEditingController();
  final TextEditingController historiaController = TextEditingController();
  final TextEditingController apelidoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE6F0),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            // Imagem do usuário
            CircleAvatar(
              radius: 50,
              backgroundImage: userImageUrl.isNotEmpty
                  ? NetworkImage(userImageUrl)
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(height: 12),
            // Icone da aliança
            Icon(
              Icons.favorite, // Pode trocar por um ícone de aliança se quiser adicionar
              color: Colors.pink[300],
              size: 32,
            ),
            SizedBox(height: 12),
            // Imagem do parceiro(a)
            CircleAvatar(
              radius: 50,
              backgroundImage: partnerImageUrl.isNotEmpty
                  ? NetworkImage(partnerImageUrl)
                  : AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            SizedBox(height: 24),
            // Perguntas
            Text(
              'Tempo de Relacionamento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: tempoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Como vocês se conheceram?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: historiaController,
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Apelido carinhoso que usam entre si',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextField(
              controller: apelidoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            SizedBox(height: 32),
            // Botão Confirmar
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                MaterialPageRoute(
                  builder: (context) => RelacionamentoStatusPage(
                    userImage: userImageUrl.isNotEmpty ? File(userImageUrl) : null,
                    userName: 'Você',
                    partnerImage: partnerImageUrl.isNotEmpty ? null : null, // ou algum path se quiser
                    partnerName: 'Parceria',
                    relationshipDays: int.tryParse(tempoController.text) ?? 0,
                  ),
                ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[300],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Confirmar',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
