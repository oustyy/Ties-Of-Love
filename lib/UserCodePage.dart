import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/AguardandoConfirmacaoPage.dart';
import 'package:flutter_application_1/RelacionamentoPage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart'; // Certifique-se de que está importado

class UserCodePage extends StatefulWidget {
  final String userCode;
  final String email;
  final String password;

  const UserCodePage({
    required this.userCode,
    required this.email,
    required this.password,
    super.key,
  });

  @override
  _UserCodePageState createState() => _UserCodePageState();
}

class _UserCodePageState extends State<UserCodePage> {
  final TextEditingController _partnerCodeController = TextEditingController();
  String? _partnerFotoUrl;
  String? _partnerName;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _userFotoUrl;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'senha': widget.password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _userFotoUrl = responseData['foto_url'] as String? ?? '';
            _userName = responseData['nome'] as String? ?? 'Usuário';
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar dados do usuário: $e");
    }
  }

  Future<void> _verifyPartnerCode() async {
    final partnerCode = _partnerCodeController.text.trim();

    if (partnerCode.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira o código do parceiro';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/verificar-codigo-parceiro'), // Use Config.baseUrl
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_code': widget.userCode,
          'partner_code': partnerCode,
        }),
      );

      print("Response from /verificar-codigo-parceiro: ${response.body}");
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        setState(() {
          _partnerFotoUrl = responseData['foto_url'] as String? ?? '';
          _partnerName = responseData['nome'] as String? ?? 'Parceria';
        });

        final vinculoResponse = await http.post(
          Uri.parse('${Config.baseUrl}/solicitar-vinculo'), // Use Config.baseUrl
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_code': widget.userCode,
            'partner_code': partnerCode,
          }),
        );

        final vinculoData = jsonDecode(vinculoResponse.body);

        if (vinculoData['success'] == true) {
          if (vinculoData['status'] == 'vinculado') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RelacionamentoPage(
                  userImageUrl: _userFotoUrl ?? '',
                  userName: _userName ?? 'Usuário',
                  partnerImageUrl: _partnerFotoUrl ?? '',
                  partnerName: _partnerName ?? 'Parceria',
                  relationshipDays: 0,
                ),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AguardandoConfirmacaoPage(
                  userCode: widget.userCode,
                  partnerCode: partnerCode,
                  userName: _userName ?? 'Usuário',
                  partnerName: _partnerName ?? 'Parceria',
                  userImageUrl: _userFotoUrl ?? '',
                  partnerImageUrl: _partnerFotoUrl ?? '',
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = vinculoData['message'] ?? 'Erro ao solicitar vínculo';
          });
        }
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Código do parceiro inválido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão com o servidor';
      });
      print("Erro ao verificar/vincular parceiro: $e");
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                color: const Color(0xFFFFCAC2),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    'Seu código',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.userCode,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5C75),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFFFF5C75)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: widget.userCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Insira o código do parceiro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _partnerCodeController,
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
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyPartnerCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5C75),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    super.dispose();
  }
}