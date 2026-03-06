import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question.dart';

class GameManager with ChangeNotifier {
  GameManager._internal();
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;

  GameState _currentState = GameState.notStarted;
  GameState get currentState => _currentState;

  List<Player> _players = [];
  List<Player> get players => _players;
  List<Player> get notEliminatedPlayers => _players.where((p) => !p.isEliminated).toList();
  List<Player> get eliminatedPlayers => _players.where((p) => p.isEliminated).toList();
  
  Player? get strongestLink {
    try {
      return _players.firstWhere((p) => p.isStrongestLink);
    } catch (e) {
      return null;
    }
  }

  Player? get weakestLink {
    try {
      return _players.firstWhere((p) => p.isWeakestLink);
    } catch (e) {
      return null;
    }
  }

  List<Question> _allQuestions = [];
  List<Question> get allQuestions => _allQuestions;

  List<Question> _standardQuestions = [];
  int _standardQuestionIndex = 0;

  List<Question> _finalQuestions = [];
  int _finalQuestionIndex = 0;

  int _totalBankedPoints = 0;
  int get totalBankedPoints => _totalBankedPoints;

  int _roundNumber = 1;
  int get roundNumber => _roundNumber;

  int _totalRounds = 0;
  int get totalRounds => _totalRounds;

  void startGame(List<Player> selectedPlayers, List<Question> questions) {
    _players = selectedPlayers;
    _allQuestions = List.from(questions)..shuffle();
    
    _standardQuestions = _allQuestions.where((q) => q.difficulty < 5).toList();
    if (_standardQuestions.isEmpty) _standardQuestions = List.from(_allQuestions);
    _standardQuestionIndex = 0;

    _finalQuestions = _allQuestions.where((q) => q.difficulty == 5).toList();
    if (_finalQuestions.isEmpty) _finalQuestions = List.from(_allQuestions);
    _finalQuestionIndex = 0;

    _roundNumber = 1;
    // Total rounds is equal to the number of players.
    // For 3 players: Round 1 (3p), Round 2 (2p - Decisive), Round 3 (2p - Final)
    _totalRounds = _players.length;
    _totalBankedPoints = 0;
    _currentState = GameState.playing;

    for (var p in _players) {
      p.isEliminated = false;
      p.isStrongestLink = false;
      p.isWeakestLink = false;
      p.rightAnswers = 0;
      p.wrongAnswers = 0;
      p.pointsSaved = 0;
      p.votes = 0;
    }
    notifyListeners();
  }

  Question getNextStandardQuestion() {
    final question = _standardQuestions[_standardQuestionIndex % _standardQuestions.length];
    _standardQuestionIndex++;
    return question;
  }

  Question getNextFinalQuestion() {
    final question = _finalQuestions[_finalQuestionIndex % _finalQuestions.length];
    _finalQuestionIndex++;
    return question;
  }

  void eliminatePlayer(Player player) {
    player.isEliminated = true;
    notifyListeners();
  }

  void addBankedPoints(int amount) {
    _totalBankedPoints += amount;
    notifyListeners();
  }

  void incrementRoundNumber() {
    _roundNumber++;
    notifyListeners();
  }

  void determineLinks() {
    final activePlayers = notEliminatedPlayers;
    if (activePlayers.isEmpty) return;

    for (var p in _players) {
      p.isStrongestLink = false;
      p.isWeakestLink = false;
    }

    // Determine Strongest Link
    Player strongest = activePlayers[0];
    for (var i = 1; i < activePlayers.length; i++) {
      final p = activePlayers[i];
      if (p.rightAnswers > strongest.rightAnswers) {
        strongest = p;
      } else if (p.rightAnswers == strongest.rightAnswers) {
        if (p.pointsSaved > strongest.pointsSaved) {
          strongest = p;
        } else if (p.pointsSaved == strongest.pointsSaved) {
          if (p.wrongAnswers < strongest.wrongAnswers) {
            strongest = p;
          }
        }
      }
    }
    strongest.isStrongestLink = true;

    // Determine Weakest Link
    Player weakest = activePlayers[0];
    for (var i = 1; i < activePlayers.length; i++) {
      final p = activePlayers[i];
      if (p.wrongAnswers > weakest.wrongAnswers) {
        weakest = p;
      } else if (p.wrongAnswers == weakest.wrongAnswers) {
        if (p.pointsSaved < weakest.pointsSaved) {
          weakest = p;
        } else if (p.pointsSaved == weakest.pointsSaved) {
          if (p.rightAnswers < weakest.rightAnswers) {
            weakest = p;
          }
        }
      }
    }
    weakest.isWeakestLink = true;

    notifyListeners();
  }

  void resetRoundStats() {
    for (var p in _players) {
      p.rightAnswers = 0;
      p.wrongAnswers = 0;
      p.pointsSaved = 0;
    }
    notifyListeners();
  }
}

enum GameState {
  notStarted,
  menu,
  playing,
  voting,
}
