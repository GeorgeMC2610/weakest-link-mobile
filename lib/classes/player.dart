import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  bool isEliminated;
  bool isWeakestLink;
  bool isStrongestLink;
  int votes;
  int pointsSaved;
  int wrongAnswers;
  int rightAnswers;

  Player({
    required this.name, required this.color, this.isEliminated = false,
    this.isStrongestLink = false, this.isWeakestLink = false, this.votes = 0,
    this.pointsSaved = 0, this.wrongAnswers = 0, this.rightAnswers = 0,
  });
}