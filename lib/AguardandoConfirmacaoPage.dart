import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/RelacionamentoPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AguardandoConfirmacaoPage extends StatefulWidget {
  final String userCode;
  final String partnerCode;
  final String userName;
  final String partnerName;
  final String userImageUrl;
  final String partnerImageUrl;

  const AguardandoConfirmacaoPage({
    required this.userCode,
    required this.partnerCode,
    required this.userName,
    required this.partnerName,
    required this.userImageUrl,
    required this.partnerImageUrl,
    super.key,
  });

  @override
  _AguardandoConfirmacaoPageState createState() => _AguardandoConfirmacaoPageState();
}

class _AguardandoConfirmacaoPageState extends State<AguardandoConfirmacaoPage> {
  bool _isLoading = false;
  String _statusMessage = 'Aguardando confirmação do parceiro...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkVinculoStatus();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _checkVinculoStatus();
      }
    });
  }

  Future<void> _checkVinculoStatus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/solicitar-vinculo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_code': widget.userCode,
          'partner_code': widget.partnerCode,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        setState(() {
          _statusMessage = responseData['message'];
        });

        if (responseData['status'] == 'vinculado') {
          _timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RelacionamentoPage(
                userImageUrl: widget.userImageUrl,
                userName: widget.userName,
                partnerImageUrl: widget.partnerImageUrl,
                partnerName: widget.partnerName,
                relationshipDays: 0,
                userCode: widget.userCode,
                partnerCode: widget.partnerCode,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _statusMessage = responseData['message'] ?? 'Erro ao verificar vínculo';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro de conexão com o servidor';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 80,
                color: Color(0xFFFF5C75),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(
                  color: Color(0xFFFF5C75),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkVinculoStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5C75),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  'Verificar agora',
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
      ),
    );
  }
}