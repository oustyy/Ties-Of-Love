import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/AguardandoConfirmacaoPage.dart';
import 'dart:typed_data';

class UserCodePage extends StatefulWidget {
  final String userCode;

  const UserCodePage({super.key, required this.userCode});

  @override
  State<UserCodePage> createState() => _UserCodePageState();
}

class _UserCodePageState extends State<UserCodePage> {
  bool _obscureUserCode = true;
  bool _obscurePartnerCode = true;

  final TextEditingController _partnerCodeController = TextEditingController();

  Future<void> _verifyPartnerCode() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/verificar-codigo-parceiro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_code': widget.userCode,
          'partner_code': _partnerCodeController.text.trim(),
        }),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Erro ao conectar ao servidor: ${response.statusCode}');
      }

      if (response.body.isEmpty) {
        throw Exception('Resposta do servidor está vazia');
      }

      final responseData = jsonDecode(response.body);
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Resposta do servidor não é um JSON válido');
      }

      if (responseData['success'] == true) {
        _showConfirmDialog(responseData['foto_url'] as String? ?? '');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Erro ao verificar código')),
        );
      }
    } catch (e) {
      print('Erro ao verificar código do parceiro: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar código: $e')),
      );
    }
  }

  void _showConfirmDialog(String partnerFotoBase64) {
    ImageProvider partnerImage;
    if (partnerFotoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(partnerFotoBase64);
        partnerImage = MemoryImage(bytes);
      } catch (e) {
        print('Erro ao decodificar base64: $e');
        partnerImage = const AssetImage('assets/images/default_avatar.png');
      }
    } else {
      partnerImage = const AssetImage('assets/images/default_avatar.png');
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFE6F0),
        title: const Text(
          'Confirma seu parceiro(a)?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40, backgroundImage: partnerImage),
            const SizedBox(height: 12),
            Text('Código: ${_partnerCodeController.text}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.pink),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AguardandoConfirmacaoPage(
                    userCode: widget.userCode,
                    partnerCode: _partnerCodeController.text.trim(),
                  ),
                ),
              );
            },
            child: const Text('Sim', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xFFFFC9C9),
              child: Center(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Código de Usuário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: TextEditingController(text: widget.userCode),
                        obscureText: _obscureUserCode,
                        readOnly: true,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureUserCode
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureUserCode = !_obscureUserCode;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Código do(a) parceiro(a)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _partnerCodeController,
                        obscureText: _obscurePartnerCode,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePartnerCode
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePartnerCode = !_obscurePartnerCode;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          if (_partnerCodeController.text.isNotEmpty) {
                            _verifyPartnerCode();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor, insira o código do parceiro')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5C75),
                          minimumSize: const Size(double.infinity, 50),
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
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFFF5C75),
                        ),
                        label: const Text(
                          'Voltar',
                          style: TextStyle(
                            color: Color(0xFFFF5C75),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}