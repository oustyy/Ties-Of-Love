import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config.dart';

class RelacionamentoStatusPage extends StatefulWidget {
  final String userFotoUrl;
  final String userName;
  final String partnerFotoUrl;
  final String partnerName;
  final int relationshipDays;
  final String userCode;
  final String partnerCode;

  const RelacionamentoStatusPage({
    super.key,
    required this.userFotoUrl,
    required this.userName,
    required this.partnerFotoUrl,
    required this.partnerName,
    required this.relationshipDays,
    required this.userCode,
    required this.partnerCode,
  });

  @override
  State<RelacionamentoStatusPage> createState() => _RelacionamentoStatusPageState();
}

class _RelacionamentoStatusPageState extends State<RelacionamentoStatusPage>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;
  double abaHeight = 0.0;
  int? hoveredCardIndex;
  String? partnerMessage;
  String? partnerPhotoBase64;
  String? partnerDataInicio;
  Timer? _updateTimer;
  Timer? _refreshTimer;
  bool _showTimer = false;
  int _remainingSeconds = 300; // 5 minutes in seconds
  int _completedTaskSets = 0; // Counter for completed sets of 4 tasks
  String _currentPetImage = 'assets/images/pet1.png'; // Initial pet image

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> allTasks = [
    {"emoji": "🍽️", "title": "Jantar romântico", "progress": 0, "goal": 1},
    {"emoji": "💋", "title": "Beije o cônjuge", "progress": 0, "goal": 5},
    {"emoji": "🎁", "title": "Presente surpresa", "progress": 0, "goal": 1},
    {"emoji": "🌹", "title": "Mandar mensagem fofa", "progress": 0, "goal": 1},
    {"emoji": "🎶", "title": "Ouvir música juntos", "progress": 0, "goal": 1},
    {"emoji": "📝", "title": "Escrever uma carta", "progress": 0, "goal": 1},
    {"emoji": "📸", "title": "Tirar uma foto juntos", "progress": 0, "goal": 1},
    {"emoji": "🍿", "title": "Assistir um filme", "progress": 0, "goal": 1},
    {"emoji": "🎉", "title": "Planejar um encontro", "progress": 0, "goal": 1},
    {"emoji": "🌟", "title": "Planeje um encontro", "progress": 0, "goal": 1},
    {"emoji": "💃", "title": "Dança a dois", "progress": 0, "goal": 1},
    {"emoji": "📷", "title": "Tire uma selfie engraçada", "progress": 0, "goal": 3},
    {"emoji": "🎵", "title": "Façam uma playlist juntos", "progress": 0, "goal": 1},
    {"emoji": "🎲", "title": "Jogue um jogo em dupla", "progress": 0, "goal": 1},
    {"emoji": "🍳", "title": "Cozinhe algo novo juntos", "progress": 0, "goal": 1},
    {"emoji": "🎨", "title": "Faça um desenho do outro", "progress": 0, "goal": 1},
    {"emoji": "🥐", "title": "Prepare um café da manhã especial", "progress": 0, "goal": 1},
    {"emoji": "🎬", "title": "Assista a um filme clássico juntos", "progress": 0, "goal": 1},
    {"emoji": "🏃‍♂️", "title": "Corra uma pequena distância juntos", "progress": 0, "goal": 1},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fetchPartnerData();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchPartnerData();
      }
    });
    _loadInitialTasks();
  }

  void _loadInitialTasks() {
    setState(() {
      tasks = _generateNewTasks();
    });
  }

  Future<void> _fetchPartnerData() async {
    try {
      print('Fetching data for userCode: ${widget.userCode}, partnerCode: ${widget.partnerCode}');
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/obter-relacionamento'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_code': widget.userCode,
          'partner_code': widget.partnerCode,
        }),
      );

      print('Response from /obter-relacionamento: ${response.body}');
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        setState(() {
          partnerMessage = responseData['mensagem'] as String? ?? '';
          partnerPhotoBase64 = responseData['foto_base64'] as String? ?? '';
          partnerDataInicio = responseData['data_inicio'] as String?;
          print('Updated partnerMessage: $partnerMessage, partnerPhotoBase64: $partnerPhotoBase64');
        });
      }
    } catch (e) {
      print('Erro ao buscar dados do parceiro: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _updateTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _toggleFAB() {
    setState(() {
      if (!isOpen) {
        _controller.forward();
        abaHeight = MediaQuery.of(context).size.height * 0.6;
      } else {
        _controller.reverse();
        abaHeight = 0.0;
      }
      isOpen = !isOpen;
    });
  }

  List<Map<String, dynamic>> _generateNewTasks() {
    List<Map<String, dynamic>> shuffledTasks = List.from(allTasks);
    shuffledTasks.shuffle();
    return shuffledTasks.take(4).map((task) {
      return {
        "emoji": task["emoji"],
        "title": task["title"],
        "progress": 0,
        "goal": task["goal"],
      };
    }).toList();
  }

  void _startRefreshTimer() {
    setState(() {
      _showTimer = true;
      _remainingSeconds = 300; // 5 minutes
    });

    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _refreshTimer?.cancel();
          _showTimer = false;
          tasks = _generateNewTasks();
        }
      });
    });
  }

  void _updatePetImage() {
    setState(() {
      if (_completedTaskSets == 0) {
        _currentPetImage = 'assets/images/pet1.png';
      } else if (_completedTaskSets == 1) {
        _currentPetImage = 'assets/images/pet2.png';
      } else if (_completedTaskSets >= 2) {
        _currentPetImage = 'assets/images/pet3.png';
      }
      print('Current pet image set to: $_currentPetImage'); // Debug print
    });
  }

  Color _getBackgroundColor(String emoji) {
    switch (emoji) {
      case "🍽️":
      case "🍳":
      case "🥐":
        return Colors.brown.shade100;
      case "💋":
      case "🌹":
        return Colors.red.shade100;
      case "🎁":
        return Colors.blue.shade100;
      case "🎶":
      case "🎵":
        return Colors.purple.shade100;
      case "📝":
        return Colors.yellow.shade100;
      case "📸":
      case "📷":
        return Colors.grey.shade100;
      case "🍿":
      case "🎬":
        return Colors.orange.shade100;
      case "🎉":
      case "🌟":
        return Colors.green.shade100;
      case "💃":
        return Colors.pink.shade100;
      case "🎲":
        return Colors.teal.shade100;
      case "🎨":
        return Colors.indigo.shade100;
      case "🏃‍♂️":
        return Colors.amber.shade100;
      default:
        return Colors.white;
    }
  }

  Widget _buildUserAvatar(String fotoUrl, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: fotoUrl.isNotEmpty ? MemoryImage(base64Decode(fotoUrl)) : null,
          backgroundColor: Colors.white,
          child: fotoUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    final completed = task["progress"] >= task["goal"];
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? 220.0 : screenWidth * 0.5;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.5, 0),
        end: const Offset(0, 0),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * index, 0.6 + 0.1 * index, curve: Curves.easeIn),
        ),
        child: MouseRegion(
          onEnter: (_) => setState(() => hoveredCardIndex = index),
          onExit: (_) => setState(() => hoveredCardIndex = null),
          child: GestureDetector(
            onTapDown: (_) => setState(() => hoveredCardIndex = index),
            onTapUp: (_) => setState(() => hoveredCardIndex = null),
            onTapCancel: () => setState(() => hoveredCardIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(hoveredCardIndex == index ? 1.05 : 1.0),
              margin: const EdgeInsets.only(right: 16),
              width: cardWidth,
              height: cardWidth * 1.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getBackgroundColor(task["emoji"]),
                    Colors.purple.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: hoveredCardIndex == index ? 10 : 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              task["emoji"],
                              style: const TextStyle(fontSize: 24),
                            ),
                            Text(
                              task["emoji"],
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          task["title"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: task["progress"] / task["goal"],
                          backgroundColor: Colors.white.withOpacity(0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${task["progress"]}/${task["goal"]}",
                              style: TextStyle(
                                fontSize: 16,
                                color: completed ? Colors.green : Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                completed ? Icons.check_circle : Icons.add_circle_outline,
                                size: 24,
                              ),
                              color: completed ? Colors.green : Colors.pink,
                              onPressed: () {
                                setState(() {
                                  if (task["progress"] < task["goal"]) {
                                    task["progress"]++;
                                    if (task["progress"] >= task["goal"]) {
                                      Future.delayed(const Duration(milliseconds: 300), () {
                                        setState(() {
                                          tasks.removeAt(index);
                                          if (tasks.isEmpty) {
                                            _completedTaskSets++;
                                            _updatePetImage();
                                            _startRefreshTimer();
                                          }
                                        });
                                      });
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: Text(
                        task["emoji"],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Transform.rotate(
                      angle: -pi / 2,
                      child: Text(
                        task["emoji"],
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE6F0),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                Visibility(
                  visible: !isOpen,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA0B0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          partnerDataInicio != null
                              ? '${widget.relationshipDays} dias juntos'
                              : 'Aguardando data de início',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUserAvatar(widget.userFotoUrl, widget.userName),
                          const SizedBox(width: 16),
                          const Icon(Icons.favorite, color: Color(0xFFFF5C75), size: 32),
                          const SizedBox(width: 16),
                          _buildUserAvatar(widget.partnerFotoUrl, widget.partnerName),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: partnerMessage != null && partnerMessage!.isNotEmpty
                              ? Text(
                                  partnerMessage!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : const Text(
                                  'No message from partner yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (partnerPhotoBase64 != null && partnerPhotoBase64!.isNotEmpty)
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: MemoryImage(base64Decode(partnerPhotoBase64!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOpen)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage(_currentPetImage),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _currentPetImage.contains('pet') ? null : const Icon(Icons.error, size: 50, color: Colors.red), // Fallback
                  ),
                const Spacer(),
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: abaHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD6E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_showTimer)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Novas tarefas em: ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) => _buildTaskCard(tasks[index], index),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _toggleFAB,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF5C75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}