import 'package:flutter/material.dart';
import 'package:flutter_application_1/RelacionamentoStatusPage.dart';

class RelacionamentoPage extends StatefulWidget {
  final String userImageUrl;
  final String userName;
  final String partnerImageUrl;
  final String partnerName;
  final int relationshipDays;

  const RelacionamentoPage({
    required this.userImageUrl,
    required this.userName,
    required this.partnerImageUrl,
    required this.partnerName,
    required this.relationshipDays,
    super.key,
  });

  @override
  _RelacionamentoPageState createState() => _RelacionamentoPageState();
}

class _RelacionamentoPageState extends State<RelacionamentoPage> {
  DateTime? dataInicioRelacionamento;

  final TextEditingController tempoController = TextEditingController();
  final TextEditingController historiaController = TextEditingController();
  final TextEditingController apelidoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0), // Fundo rosa claro
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCAC2), // Rosa escuro
        
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Data de início do relacionamento
            const Text(
              'Data de Início do Relacionamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    dataInicioRelacionamento = pickedDate;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  dataInicioRelacionamento != null
                      ? '${dataInicioRelacionamento!.day}/${dataInicioRelacionamento!.month}/${dataInicioRelacionamento!.year}'
                      : 'Selecionar data',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // História do casal
            const Text(
              'Como vocês se conheceram?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: historiaController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Apelido carinhoso
            const Text(
              'Apelido carinhoso que usam entre si',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: apelidoController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 20,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Botão Confirmar
            ElevatedButton(
              onPressed: () {
                int diasRelacionamento = 0;
                if (dataInicioRelacionamento != null) {
                  final hoje = DateTime.now();
                  diasRelacionamento =
                      hoje.difference(dataInicioRelacionamento!).inDays;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RelacionamentoStatusPage(
                      userFotoUrl: widget.userImageUrl,
                      userName: widget.userName,
                      partnerFotoUrl: widget.partnerImageUrl,
                      partnerName: widget.partnerName,
                      relationshipDays: diasRelacionamento,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C75), // Rosa escuro
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}