import 'package:flutter/material.dart';
import 'package:flutter_application_1/RelacionamentoStatusPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';

class RelacionamentoPage extends StatefulWidget {
  final String userImageUrl;
  final String userName;
  final String partnerImageUrl;
  final String partnerName;
  final int relationshipDays;
  final String userCode;
  final String partnerCode;

  const RelacionamentoPage({
    required this.userImageUrl,
    required this.userName,
    required this.partnerImageUrl,
    required this.partnerName,
    required this.relationshipDays,
    required this.userCode,
    required this.partnerCode,
    super.key,
  });

  @override
  _RelacionamentoPageState createState() => _RelacionamentoPageState();
}

class _RelacionamentoPageState extends State<RelacionamentoPage> {
  DateTime? dataInicioRelacionamento;
  final TextEditingController mensagemController = TextEditingController();
  String? _fotoBase64;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      if (bytes != null) {
        final base64Image = base64Encode(bytes);
        setState(() {
          _fotoBase64 = base64Image;
        });
      }
    }
  }

  Future<void> _saveRelationshipData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/atualizar-relacionamento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_code': widget.userCode,
          'partner_code': widget.partnerCode,
          'data_inicio': dataInicioRelacionamento?.toIso8601String(),
          'mensagem': mensagemController.text.trim(),
          'foto_base64': _fotoBase64 ?? '',
        }),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        int diasRelacionamento = 0;
        if (dataInicioRelacionamento != null) {
          final hoje = DateTime.now();
          diasRelacionamento = hoje.difference(dataInicioRelacionamento!).inDays;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RelacionamentoStatusPage(
              userFotoUrl: widget.userImageUrl,
              userName: widget.userName,
              partnerFotoUrl: widget.partnerImageUrl,
              partnerName: widget.partnerName,
              relationshipDays: diasRelacionamento,
              userCode: widget.userCode,
              partnerCode: widget.partnerCode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Erro ao salvar informações')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFCAC2),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 30),
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
            const Text(
              'Deixe uma mensagem',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mensagemController,
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
            const Text(
              'Adicionar uma foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _fotoBase64 != null
                      ? DecorationImage(
                          image: MemoryImage(base64Decode(_fotoBase64!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _fotoBase64 == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Selecionar foto',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRelationshipData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C75),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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