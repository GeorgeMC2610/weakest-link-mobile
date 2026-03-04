import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';
import 'package:weakest_link/screens/voting_phase.dart';
import 'package:weakest_link/services/game_manager.dart';
import 'package:weakest_link/screens/round_start.dart';

class PlayingRound extends StatefulWidget {
  final List<Player> players;
  final List<Question> questions;
  final int roundNumber;
  final int totalSeconds;
  final int? playFirst; // 1: first, 2: second (for last round)

  const PlayingRound({
    super.key,
    required this.players,
    required this.questions,
    required this.roundNumber,
    required this.totalSeconds,
    this.playFirst,
  });

  @override
  State<PlayingRound> createState() => _PlayingRoundState();
}

class _PlayingRoundState extends State<PlayingRound> with TickerProviderStateMixin {
  final List<int> _pointsScale = [0, 20, 50, 100, 200, 300, 450, 600, 800, 1000];
  int _currentChainIndex = 0;
  int _roundBankedPoints = 0;
  int _currentPlayerIndex = 0;
  late List<Player> _activePlayers;

  // Timer logic
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRoundActive = false;
  bool _isStarting = true;
  bool _isTimeOver = false;

  // Animation logic for the starting lights
  late AnimationController _startLightsController;

  // Question logic
  int _currentQuestionIndex = 0;
  late List<Question> _roundQuestions;

  @override
  void initState() {
    super.initState();
    _activePlayers = widget.players.where((p) => !p.isEliminated).toList();
    _remainingSeconds = widget.totalSeconds;
    
    // Determine who starts
    if (widget.roundNumber == 1) {
      _activePlayers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _currentPlayerIndex = 0;
    } else {
      final strongest = GameManager().strongestLink;
      if (strongest != null) {
        final index = _activePlayers.indexOf(strongest);
        _currentPlayerIndex = index != -1 ? index : 0;
      }
    }

    _roundQuestions = widget.questions.where((q) => q.difficulty < 5).toList();
    if (_roundQuestions.isEmpty) _roundQuestions = List.from(widget.questions);
    _roundQuestions.shuffle();

    _startLightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _startLightsController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isStarting = false;
          _startRound();
        });
      }
    });

    _startLightsController.forward();
  }

  void _startRound() {
    setState(() {
      _isRoundActive = true;
      _isTimeOver = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isTimeOver = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _startLightsController.dispose();
    super.dispose();
  }

  void _nextPlayer() {
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _activePlayers.length;
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _roundQuestions.length;
    });
  }

  void _handleCorrect() {
    if (!_isRoundActive) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      currentPlayer.rightAnswers++;
      if (_currentChainIndex < _pointsScale.length - 1) {
        _currentChainIndex++;
      }
      _nextPlayer();
    });
  }

  void _handleWrong() {
    if (!_isRoundActive) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      currentPlayer.wrongAnswers++;
      _currentChainIndex = 0;
      _nextPlayer();
    });
  }

  void _handleBank() {
    if (!_isRoundActive || _currentChainIndex == 0) return;
    final currentPlayer = _activePlayers[_currentPlayerIndex];
    setState(() {
      final bankedAmount = _pointsScale[_currentChainIndex];
      _roundBankedPoints += bankedAmount;
      currentPlayer.pointsSaved += bankedAmount;
      _currentChainIndex = 0;
    });
  }

  void _handleBurn() {
    if (!_isRoundActive) return;
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % _roundQuestions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedBuilder(
            animation: _startLightsController,
            builder: (context, child) {
              return CustomPaint(
                painter: StartingLightsPainter(
                  progress: _startLightsController.value,
                  roundNumber: widget.roundNumber,
                ),
                size: const Size(300, 300),
              );
            },
          ),
        ),
      );
    }

    final currentPlayer = _activePlayers[_currentPlayerIndex];
    final currentQuestion = _roundQuestions[_currentQuestionIndex % _roundQuestions.length];
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = "$minutes:${seconds.toString().padLeft(2, '0')}";

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Banked: $_roundBankedPoints'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _remainingSeconds < 10 ? Colors.red : Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeStr,
                style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false,
      ),
      body: Row(
        children: [
          // Points Scale Sidebar
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pointsScale.length, (index) {
                int reverseIndex = _pointsScale.length - 1 - index;
                if (reverseIndex == 0) return const SizedBox.shrink();
                
                bool isTarget = _currentChainIndex == reverseIndex;
                return Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isTarget 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isTarget ? null : Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${_pointsScale[reverseIndex]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isTarget 
                              ? Theme.of(context).colorScheme.onPrimary 
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // Player Turn Indicator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: currentPlayer.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: currentPlayer.color, width: 3),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("CURRENT PLAYER", style: TextStyle(fontSize: 12, letterSpacing: 2)),
                        Text(
                          currentPlayer.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: (isLandscape ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.headlineMedium)?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: currentPlayer.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  
                  // Question & Answer
                  Text(
                    currentQuestion.title,
                    textAlign: TextAlign.center,
                    style: (isLandscape ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.headlineSmall)?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "(${currentQuestion.answer})",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),

                  if (_isTimeOver)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: FilledButton(
                              onPressed: () {
                                GameManager().addBankedPoints(_roundBankedPoints);
                                GameManager().determineLinks();
                                
                                if (_activePlayers.length == 2) {
                                  // This was the decisive round.
                                  // No one is voted out. Skip voting phase.
                                  GameManager().resetRoundStats();
                                  GameManager().incrementRoundNumber();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => RoundStart(
                                        players: GameManager().players,
                                        questions: GameManager().allQuestions,
                                        roundNumber: GameManager().roundNumber,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => VotingPhase(
                                        players: widget.players,
                                        strongestLink: GameManager().strongestLink!,
                                        weakestLink: GameManager().weakestLink!,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "NEXT",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Action Grid
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: isLandscape ? 4.5 : 2.5,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isRoundActive ? _handleCorrect : null,
                            icon: const Icon(Icons.check_circle),
                            label: const Text("CORRECT"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _isRoundActive ? _handleWrong : null,
                            icon: const Icon(Icons.cancel),
                            label: const Text("WRONG"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: (_isRoundActive && _currentChainIndex > 0) ? _handleBank : null,
                            icon: const Icon(Icons.account_balance),
                            label: const Text("BANK"),
                            style: FilledButton.styleFrom(
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _isRoundActive ? _handleBurn : null,
                            icon: const Icon(Icons.local_fire_department),
                            label: const Text("BURN"),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.orange, width: 2),
                              foregroundColor: Colors.orange.shade800,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StartingLightsPainter extends CustomPainter {
  final double progress;
  final int roundNumber;

  StartingLightsPainter({required this.progress, required this.roundNumber});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 80.0;
    final lineLength = 30.0;
    final paint = Paint()
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      Color color = Colors.grey.withOpacity(0.1);
      if (progress > 0.66) {
        color = Colors.indigo;
      } else if (progress > 0.33) {
        if (i == 0 || i == 4 || i == 5 || i == 7) color = Colors.lightBlueAccent;
      } else if (progress > 0) {
        if (i == 0 || i == 4) color = Colors.lightBlueAccent;
      }
      paint.color = color;
      final start = Offset(
        center.dx + (radius - lineLength / 2) * math.cos(angle),
        center.dy + (radius - lineLength / 2) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + lineLength / 2) * math.cos(angle),
        center.dy + (radius + lineLength / 2) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: "ROUND $roundNumber",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant StartingLightsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
