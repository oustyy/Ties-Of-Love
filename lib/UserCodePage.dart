import 'package:flutter/material.dart';
import 'package:flutter_application_1/RelacionamentoPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';

class UserCodePage extends StatefulWidget {
  final String userCode;
  final String email;
  final String password;

  const UserCodePage({
    super.key,
    required this.userCode,
    required this.email,
    required this.password,
  });

  @override
  _UserCodePageState createState() => _UserCodePageState();
}

class _UserCodePageState extends State<UserCodePage> {
  final TextEditingController _partnerCodeController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;
  bool _isCodeVisible = true; // Controla se o código está visível
  final client = http.Client();

  Future<void> _verifyAndLinkPartner() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando...';
    });

    try {
      final response = await client
          .post(
            Uri.parse('${Config.baseUrl}/solicitar-vinculo'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_code': widget.userCode,
              'partner_code': _partnerCodeController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response from /solicitar-vinculo: ${response.statusCode} - ${response.body}');

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          _statusMessage = responseData['message'];
        });

        if (responseData['status'] == 'vinculado') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RelacionamentoPage(
                userImageUrl: '',
                userName: '',
                partnerImageUrl: '',
                partnerName: '',
                relationshipDays: 0,
                userCode: widget.userCode,
                partnerCode: _partnerCodeController.text.trim(),
              ),
            ),
          );
        } else if (responseData['status'] == 'pendente') {
          await Future.delayed(const Duration(seconds: 5));
          await _checkVinculationStatus();
        }
      } else {
        setState(() {
          _statusMessage = responseData['message'] ?? 'Erro ao vincular';
        });
      }
    } catch (e, stackTrace) {
      print("Erro ao vincular: $e\nStackTrace: $stackTrace");
      setState(() {
        _statusMessage = 'Erro de conexão com o servidor: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkVinculationStatus() async {
    try {
      final response = await client
          .post(
            Uri.parse('${Config.baseUrl}/verificar-codigo-parceiro'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_code': widget.userCode,
              'partner_code': '',
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response from /verificar-codigo-parceiro: ${response.statusCode} - ${response.body}');

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        if (responseData['nome'] != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RelacionamentoPage(
                userImageUrl: '',
                userName: '',
                partnerImageUrl: responseData['foto_url'] ?? '',
                partnerName: responseData['nome'] ?? '',
                relationshipDays: 0,
                userCode: widget.userCode,
                partnerCode: _partnerCodeController.text.trim(),
              ),
            ),
          );
        } else {
          setState(() {
            _statusMessage = 'Ainda aguardando confirmação do parceiro...';
          });
          await Future.delayed(const Duration(seconds: 5));
          await _checkVinculationStatus();
        }
      }
    } catch (e, stackTrace) {
      print("Erro ao verificar status: $e\nStackTrace: $stackTrace");
      setState(() {
        _statusMessage = 'Erro de conexão com o servidor: $e';
      });
    }
  }

  void _toggleCodeVisibility() {
    setState(() {
      _isCodeVisible = !_isCodeVisible;
    });
  }

  void _copyCodeToClipboard() {
    FlutterClipboard.copy(widget.userCode).then((value) {
      Fluttertoast.showToast(
        msg: "Código copiado para a área de transferência!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Seu código:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isCodeVisible ? widget.userCode : '•••••••',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF5C75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                        _isCodeVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: _toggleCodeVisibility,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.grey,
                      ),
                      onPressed: _copyCodeToClipboard,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _partnerCodeController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.pink),
                  hintText: 'Código do parceiro',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndLinkPartner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C75),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Vincular',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _partnerCodeController.dispose();
    client.close();
    super.dispose();
  }
}