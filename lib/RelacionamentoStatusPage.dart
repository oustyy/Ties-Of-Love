import 'dart:io';
import 'package:flutter/material.dart';

class RelacionamentoStatusPage extends StatefulWidget {
  final File? userImage;
  final String userName;
  final File? partnerImage;
  final String partnerName;
  final int relationshipDays;

  const RelacionamentoStatusPage({
    super.key,
    this.userImage,
    required this.userName,
    this.partnerImage,
    required this.partnerName,
    required this.relationshipDays,
  });

  @override
  State<RelacionamentoStatusPage> createState() =>
      _RelacionamentoStatusPageState();
}

class _RelacionamentoStatusPageState extends State<RelacionamentoStatusPage>
    with SingleTickerProviderStateMixin {
  bool isOpen = false;
  late AnimationController _controller;
  double abaHeight = 0.0;

  List<Map<String, dynamic>> tasks = [
    {"emoji": "🍽", "title": "Jantar romântico", "progress": 0, "goal": 1},
    {"emoji": "💋", "title": "Beije o cônjuge", "progress": 3, "goal": 5},
    {"emoji": "🎁", "title": "Presente surpresa", "progress": 0, "goal": 1},
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  void animateFAB() {
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

  Widget _taskCard(Map<String, dynamic> task, int index) {
    final completed = task["progress"] >= task["goal"];

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(task["emoji"], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task["title"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: task["progress"] / task["goal"],
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.pink,
                    onPressed: () {
                      setState(() {
                        if (task["progress"] > 0) task["progress"]--;
                      });
                    },
                  ),
                  Text(
                    "${task["progress"]}/${task["goal"]}",
                    style: TextStyle(
                      color: completed ? Colors.green : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        completed ? Icons.check_circle : Icons.add_circle_outline),
                    color: completed ? Colors.green : Colors.pink,
                    onPressed: () {
                      setState(() {
                        if (task["progress"] < task["goal"]) {
                          task["progress"]++;
                          // se completou, remove e adiciona nova
                          if (task["progress"] >= task["goal"]) {
                            Future.delayed(const Duration(milliseconds: 300), () {
                              setState(() {
                                tasks.removeAt(index);
                                if (tasks.length < 3) {
                                  tasks.add(_generateNewTask());
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
      ),
    );
  }

  Map<String, dynamic> _generateNewTask() {
    // simular vinda de backend
    List<Map<String, dynamic>> novas = [
      {"emoji": "🌹", "title": "Mandar mensagem fofa", "progress": 0, "goal": 1},
      {"emoji": "🎶", "title": "Ouvir música juntos", "progress": 0, "goal": 1},
      {"emoji": "📝", "title": "Escrever uma carta", "progress": 0, "goal": 1},
    ];
    novas.shuffle();
    return novas.first;
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA0B0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '${widget.relationshipDays} dias juntos',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: widget.userImage != null
                                ? FileImage(widget.userImage!)
                                : null,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.favorite,
                              color: Color(0xFFFF5C75), size: 32),
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: widget.partnerImage != null
                                ? FileImage(widget.partnerImage!)
                                : null,
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.userName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'DancingScript',
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 32),
                          Text(widget.partnerName,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'DancingScript',
                                  fontWeight: FontWeight.bold)),
                        ],
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
                      image: const DecorationImage(
                        image: AssetImage('assets/imagem_quests.png'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
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
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) =>
                    _taskCard(tasks[index], index),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: animateFAB,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF5C75),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4))
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