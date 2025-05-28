import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_application_1/RelacionamentoPage.dart';

class AguardandoConfirmacaoPage extends StatefulWidget {
  final String userCode;
  final String partnerCode;

  const AguardandoConfirmacaoPage({
    super.key,
    required this.userCode,
    required this.partnerCode,
  });

  @override
  _AguardandoConfirmacaoPageState createState() => _AguardandoConfirmacaoPageState();
}

class _AguardandoConfirmacaoPageState extends State<AguardandoConfirmacaoPage> {
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
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
        if (responseData['status'] == 'vinculado') {
          _timer?.cancel();
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RelacionamentoPage(
                userImageUrl: '',
                partnerImageUrl: '',
              ),
            ),
          );
        }
      } catch (e) {
        print('Erro ao verificar status de vínculo: $e');
      }
    });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5C75)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aguardando confirmação do seu parceiro...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
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
    );
  }
}