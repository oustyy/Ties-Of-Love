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
  late Animation<double> _animateIcon;
  double abaHeight = 0.0;
  double barraBottom = 0.0;

  final List<Map<String, dynamic>> tasks = [
    {
      "emoji": "🍽",
      "title": "Tenha um jantar romântico",
      "progress": 0,
      "goal": 1,
    },
    {
      "emoji": "💋",
      "title": "Beije seu cônjuge",
      "progress": 3,
      "goal": 5,
    },
    {
      "emoji": "🎁",
      "title": "Surpreenda com um presente",
      "progress": 0,
      "goal": 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void animateFAB() {
    setState(() {
      if (!isOpen) {
        _controller.forward();
        abaHeight = MediaQuery.of(context).size.height * 0.55;
        barraBottom = abaHeight - 50; // sobreposição ajustada
      } else {
        _controller.reverse();
        abaHeight = 0.0;
        barraBottom = 0.0;
      }
      isOpen = !isOpen;
    });
  }
  Widget _animatedTaskCard(
      String emoji, String title, int progress, int goal, int index) {
    final completed = progress >= goal;

    final Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.1 * index,
        0.6 + 0.1 * index,
        curve: Curves.easeOut,
      ),
    ));

    final Animation<double> fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        0.1 * index,
        0.6 + 0.1 * index,
        curve: Curves.easeIn,
      ),
    );

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress / goal,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green),
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
                        if (tasks[index]["progress"] > 0) {
                          tasks[index]["progress"]--;
                        }
                      });
                    },
                  ),
                  Text(
                    "$progress/$goal",
                    style: TextStyle(
                      color: completed ? Colors.green : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(completed ? Icons.check_circle : Icons.add_circle_outline),
                    color: completed ? Colors.green : Colors.pink,
                    onPressed: () {
                      setState(() {
                        if (tasks[index]["progress"] < goal) {
                          tasks[index]["progress"]++;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFFFE6F0),
        body: SafeArea(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 30),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA0B0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        '${widget.relationshipDays} dias juntos',
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
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'DancingScript',
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Text(
                          widget.partnerName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'DancingScript',
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),

                // ABA EXPANSÍVEL
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: abaHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD6E0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, barraBottom + 80),
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _animatedTaskCard(
                        task["emoji"],
                        task["title"],
                        task["progress"],
                        task["goal"],
                        index,
                      );
                    },
                  ),
                ),

                // BARRA INFERIOR
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: barraBottom,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA0B0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_album,
                                size: 33, color: Colors.white),
                            onPressed: () {},
                          ),

                          // BOTÃO CENTRAL PERSONALIZADO
                          // BOTÃO CENTRAL PERSONALIZADO
                          // BOTÃO CENTRAL PERSONALIZADO
                          GestureDetector(
                            onTap: animateFAB,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFF5C75), // SEMPRE ROSA
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Center(
                                child: TweenAnimationBuilder<Color?>(
                                  tween: ColorTween(
                                    begin: Colors.white,
                                    end: isOpen ? Colors.red : Colors.white,
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  builder: (context, color, child) {
                                    return Icon(
                                      Icons.favorite,
                                      color: color,
                                      size: 36,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings,
                                size: 33, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
    );
 }
}