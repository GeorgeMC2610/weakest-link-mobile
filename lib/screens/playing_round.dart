import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';

class PlayingRound extends StatefulWidget {
  final List<Player> players;
  final int roundNumber;
  final int totalSeconds;

  const PlayingRound({
    super.key,
    required this.players,
    required this.roundNumber,
    required this.totalSeconds,
  });

  @override
  State<PlayingRound> createState() => _PlayingRoundState();
}

class _PlayingRoundState extends State<PlayingRound> with TickerProviderStateMixin {
  final List<int> _pointsScale = [0, 20, 50, 100, 200, 300, 450, 600, 800, 1000];
  int _currentChainIndex = 0;
  int _totalBankedPoints = 0;
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
  int _blinkCount = 0;

  // Placeholder question logic
  String _currentQuestion = "Who was the first President of the United States?";
  String _currentAnswer = "George Washington";

  @override
  void initState() {
    super.initState();
    _activePlayers = widget.players.where((p) => !p.isEliminated).toList();
    _remainingSeconds = widget.totalSeconds;

    _startLightsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _startLightsController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_blinkCount < 3) {
          _blinkCount++;
          _startLightsController.reverse();
        } else {
          setState(() {
            _isStarting = false;
            _startRound();
          });
        }
      } else if (status == AnimationStatus.dismissed) {
        if (_blinkCount < 4) {
          _startLightsController.forward();
        }
      }
    });

    // Start the blink animation
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
    });
  }

  void _handleCorrect() {
    if (!_isRoundActive) return;
    setState(() {
      if (_currentChainIndex < _pointsScale.length - 1) {
        _currentChainIndex++;
      }
      _nextPlayer();
    });
  }

  void _handleWrong() {
    if (!_isRoundActive) return;
    setState(() {
      _currentChainIndex = 0;
      _nextPlayer();
    });
  }

  void _handleBank() {
    if (!_isRoundActive || _currentChainIndex == 0) return;
    setState(() {
      _totalBankedPoints += _pointsScale[_currentChainIndex];
      _currentChainIndex = 0;
    });
  }

  void _handleBurn() {
    if (!_isRoundActive) return;
    setState(() {
      _currentQuestion = "What is the capital of France?";
      _currentAnswer = "Paris";
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
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.withOpacity(_startLightsController.value), width: 10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(_startLightsController.value * 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    "ROUND ${widget.roundNumber}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final currentPlayer = _activePlayers[_currentPlayerIndex];
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = "$minutes:${seconds.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Banked: $_totalBankedPoints'),
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
          // Points Scale Sidebar (Weakest Link Style)
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pointsScale.length, (index) {
                // Display highest value at top
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
          
          // Main Game Play Area
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
                      children: [
                        const Text("CURRENT PLAYER", style: TextStyle(fontSize: 12, letterSpacing: 2)),
                        Text(
                          currentPlayer.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    _currentQuestion,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "($_currentAnswer)",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),

                  if (_isTimeOver)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
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
                  
                  // Action Grid
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
