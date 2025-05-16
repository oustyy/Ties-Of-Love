import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_application_1/RelacionamentoPage.dart';

class UserCodePage extends StatefulWidget {
  const UserCodePage({super.key});

  @override
  State<UserCodePage> createState() => _UserCodePageState();
}

class _UserCodePageState extends State<UserCodePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _obscureText = true;
  final TextEditingController _userCodeController = TextEditingController();
  final TextEditingController _partnerCodeController = TextEditingController();

  // Função para escolher imagem
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Função para mostrar pop-up de confirmação
  void _showConfirmDialog() {
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
            CircleAvatar(
              radius: 40,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
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
              Navigator.pop(context); // fecha o dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RelacionamentoPage(
                    userImageUrl: _imageFile != null ? _imageFile!.path : '',
                    partnerImageUrl: 'https://via.placeholder.com/150', // simulado
                  ),
                ),
              );
            },
            child: const Text(
              'Sim',
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0), // Fundo rosa claro
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: const Color(0xFFFFA0B0), // Rosa escuro
            child: const Center(
              child: Text(
                'Ties of Love',
                style: TextStyle(
                  fontFamily: 'DancingScript',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Conteúdo
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Foto
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 32,
                                  color: Colors.pink,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Campo Código de Usuário
                      const Text(
                        'Código de Usuário',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _userCodeController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
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
                      // Campo Código do Parceiro
                      const Text(
                        'Código do(a) parceiro(a)',
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
                      // Botão Confirmar
                      ElevatedButton(
                        onPressed: () {
                          if (_partnerCodeController.text.isNotEmpty) {
                            _showConfirmDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5C75), // Rosa escuro
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
                      // Botão Voltar
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