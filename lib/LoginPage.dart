import 'package:flutter/material.dart';
import 'package:flutter_application_1/UserCodePage.dart';
import 'package:flutter_application_1/RelacionamentoPage.dart';
import 'package:flutter_application_1/CriarContaPage.dart';
import 'package:flutter_application_1/RelacionamentoStatusPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/config.dart';

class TiesOfLoveApp extends StatelessWidget {
  const TiesOfLoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginIKSr() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'senha': password,
        }),
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        final userCode = responseData['codigo_usuario'] as String? ?? '';
        final statusVinculo = responseData['status_vinculo'] as String? ?? 'livre';
        final userFotoUrl = responseData['foto_url'] as String? ?? '';
        final userName = responseData['nome'] as String? ?? 'Usuário';
        final partnerCode = responseData['codigo_parceiro'] as String? ?? '';
        final hasRelationship = responseData['has_relationship'] as bool? ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bem-vindo(a), $userName! Login realizado com sucesso')),
        );

        String partnerFotoUrl = '';
        String partnerName = '';

        // Fetch partner details if the user is vinculado
        if (statusVinculo == 'vinculado') {
          final partnerResponse = await http.post(
            Uri.parse('${Config.baseUrl}/verificar-codigo-parceiro'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_code': userCode,
              'partner_code': '',
            }),
          );

          if (partnerResponse.statusCode == 200) {
            final partnerData = jsonDecode(partnerResponse.body);
            if (partnerData['success'] == true) {
              partnerFotoUrl = partnerData['foto_url'] as String? ?? '';
              partnerName = partnerData['nome'] as String? ?? 'Parceria';
            } else {
              print("Erro ao buscar parceiro: ${partnerData['message']}");
            }
          } else {
            print("Erro na requisição do parceiro: ${partnerResponse.statusCode}");
          }
        }

        if (statusVinculo == 'vinculado' && hasRelationship) {
          // Usuário já vinculado e com relacionamento configurado, vai direto para RelacionamentoStatusPage
          final relResponse = await http.post(
            Uri.parse('${Config.baseUrl}/obter-relacionamento'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_code': userCode,
              'partner_code': partnerCode,
            }),
          );

          if (relResponse.statusCode == 200) {
            final relData = jsonDecode(relResponse.body);
            if (relData['success'] == true) {
              final dataInicio = relData['data_inicio'] != null ? DateTime.parse(relData['data_inicio']) : null;
              final relationshipDays = dataInicio != null ? DateTime.now().difference(dataInicio).inDays : 0;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RelacionamentoStatusPage(
                    userFotoUrl: userFotoUrl,
                    userName: userName,
                    partnerFotoUrl: partnerFotoUrl, // Partner's profile photo
                    partnerName: partnerName, // Partner's actual name
                    relationshipDays: relationshipDays,
                    userCode: userCode,
                    partnerCode: partnerCode,
                  ),
                ),
              );
            }
          }
        } else {
          // Usuário novo ou não vinculado, segue o fluxo normal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UserCodePage(
                userCode: userCode,
                email: email,
                password: password,
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Erro ao fazer login')),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão com o servidor')),
      );
    }
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
              color: const Color(0xFFFFCAC2),
              child: Center(),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.pink,
                        ),
                        hintText: 'E-mail',
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
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.pink,
                        ),
                        hintText: 'Senha',
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
                      onPressed: _loginIKSr,
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
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CriarContaPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Criar conta',
                        style: TextStyle(
                          color: Color(0xFFFF5C75),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}