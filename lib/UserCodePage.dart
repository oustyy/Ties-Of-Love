import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

import 'package:flutter_application_1/RelacionamentoPage.dart';

class UserCodePage extends StatefulWidget {
  const UserCodePage({super.key});

  @override
  State<UserCodePage> createState() => _UserCodePageState();
}

class _UserCodePageState extends State<UserCodePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _obscureUserCode = true;
  bool _obscurePartnerCode = true;

  final TextEditingController _userCodeController = TextEditingController();
  final TextEditingController _partnerCodeController = TextEditingController();

  final String _partnerCodePredefinido = "AMOR123";
  final String _partnerImagePath = 'assets/images/partner_avatar.png';

  @override
  void initState() {
    super.initState();
    _userCodeController.text = _generateUserCode();
  }

  String _generateUserCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();
    return String.fromCharCodes(
      List.generate(7, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showConfirmDialog() {
    ImageProvider partnerImage = const AssetImage(
      'assets/images/default_avatar.png',
    );

    if (_partnerCodeController.text.trim() == _partnerCodePredefinido) {
      partnerImage = AssetImage(_partnerImagePath);
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                      builder:
                          (context) => RelacionamentoPage(
                            userImageUrl: _imageFile?.path ?? '',
                            partnerImageUrl:
                                _partnerCodeController.text ==
                                        _partnerCodePredefinido
                                    ? _partnerImagePath
                                    : '',
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
          // Topo arredondado
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                          child:
                              _imageFile == null
                                  ? const Icon(
                                    Icons.add_a_photo,
                                    size: 32,
                                    color: Colors.pink,
                                  )
                                  : null,
                        ),
                      ),
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
                        controller: _userCodeController,
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
                            _showConfirmDialog();
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
