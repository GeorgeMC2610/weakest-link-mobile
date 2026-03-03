import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  bool isEliminated;
  bool isWeakestLink;
  bool isStrongestLink;

  Player({
    required this.name, required this.color, this.isEliminated = false,
    this.isStrongestLink = false, this.isWeakestLink = false
  });
}