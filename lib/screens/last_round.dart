import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';

class LastRound extends StatefulWidget {
  final List<Player> finalists;
  final int grandPrize;
  final List<Question> allQuestions;

  const LastRound({
    super.key,
    required this.finalists,
    required this.grandPrize,
    required this.allQuestions,
  });

  @override
  State<LastRound> createState() => _LastRoundState();
}

class _LastRoundState extends State<LastRound> {
  int _currentPlayerIndex = 0;
  final List<bool?> _player1Results = List.filled(5, null, growable: true);
  final List<bool?> _player2Results = List.filled(5, null, growable: true);

  int _p1Correct = 0;
  int _p2Correct = 0;
  int _p1Asked = 0;
  int _p2Asked = 0;

  bool _isSuddenDeath = false;
  Player? _winner;

  late List<Question> _finalQuestions;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    // Filter questions by difficulty 5 and shuffle
    _finalQuestions = widget.allQuestions
        .where((q) => q.difficulty == 5)
        .toList();
    
    // Fallback if no difficulty 5 questions exist
    if (_finalQuestions.isEmpty) {
      _finalQuestions = List.from(widget.allQuestions);
    }
    
    _finalQuestions.shuffle();
  }

  void _handleAnswer(bool isCorrect) {
    if (_winner != null) return;

    setState(() {
      if (_currentPlayerIndex == 0) {
        if (_isSuddenDeath && _p1Asked >= 5) {
          _player1Results.add(isCorrect);
        } else {
          _player1Results[_p1Asked] = isCorrect;
        }
        if (isCorrect) _p1Correct++;
        _p1Asked++;
        _currentPlayerIndex = 1;
      } else {
        if (_isSuddenDeath && _p2Asked >= 5) {
          _player2Results.add(isCorrect);
        } else {
          _player2Results[_p2Asked] = isCorrect;
        }
        if (isCorrect) _p2Correct++;
        _p2Asked++;
        _currentPlayerIndex = 0;
      }

      _currentQuestionIndex = (_currentQuestionIndex + 1) % _finalQuestions.length;
      _checkGameState();
    });
  }

  void _checkGameState() {
    if (!_isSuddenDeath) {
      int p1Remaining = 5 - _p1Asked;
      int p2Remaining = 5 - _p2Asked;

      if (_p1Correct > _p2Correct + p2Remaining) {
        _winner = widget.finalists[0];
        return;
      }
      if (_p2Correct > _p1Correct + p1Remaining) {
        _winner = widget.finalists[1];
        return;
      }

      if (_p1Asked == 5 && _p2Asked == 5) {
        if (_p1Correct == _p2Correct) {
          _isSuddenDeath = true;
        } else {
          _winner = _p1Correct > _p2Correct ? widget.finalists[0] : widget.finalists[1];
        }
      }
    } else {
      if (_p1Asked == _p2Asked) {
        int p1SDResult = _player1Results.last == true ? 1 : 0;
        int p2SDResult = _player2Results.last == true ? 1 : 0;

        if (p1SDResult != p2SDResult) {
          _winner = p1SDResult > p2SDResult ? widget.finalists[0] : widget.finalists[1];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.finalists[_currentPlayerIndex];
    final currentQuestion = _finalQuestions[_currentQuestionIndex % _finalQuestions.length];

    return Scaffold(
      appBar: AppBar(
        title: Text('FINAL ROUND - \$${widget.grandPrize}'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildScoreBoard(),
            const Spacer(),
            
            if (_winner == null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: currentPlayer.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: currentPlayer.color, width: 4),
                ),
                child: Text(
                  currentPlayer.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: currentPlayer.color,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                currentQuestion.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                "(${currentQuestion.answer})",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const Spacer(),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAnswer(true),
                      icon: const Icon(Icons.check_circle, size: 32),
                      label: const Text("CORRECT", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAnswer(false),
                      icon: const Icon(Icons.cancel, size: 32),
                      label: const Text("WRONG", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                "WINNER",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                _winner!.name,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _winner!.color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Banked: \$${widget.grandPrize}",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text("EXIT GAME"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Column(
      children: [
        _buildPlayerScoreRow(widget.finalists[0], _player1Results),
        const SizedBox(height: 12),
        _buildPlayerScoreRow(widget.finalists[1], _player2Results),
        if (_isSuddenDeath)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              "SUDDEN DEATH",
              style: TextStyle(
                color: Colors.red.shade900,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerScoreRow(Player player, List<bool?> results) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            player.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Wrap(
            spacing: 4,
            children: results.map((res) {
              return Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: res == null
                      ? Colors.grey.shade300
                      : (res ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  res == null ? null : (res ? Icons.check : Icons.close),
                  color: Colors.white,
                  size: 20,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
