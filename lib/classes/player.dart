import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int colorValue;

  @HiveField(2)
  bool isEliminated;

  @HiveField(3)
  bool isWeakestLink;

  @HiveField(4)
  bool isStrongestLink;

  @HiveField(5)
  int votes;

  @HiveField(6)
  int pointsSaved;

  @HiveField(7)
  int wrongAnswers;

  @HiveField(8)
  int rightAnswers;

  Player({
    required this.name,
    required this.colorValue,
    this.isEliminated = false,
    this.isStrongestLink = false,
    this.isWeakestLink = false,
    this.votes = 0,
    this.pointsSaved = 0,
    this.wrongAnswers = 0,
    this.rightAnswers = 0,
  });

  Color get color => Color(colorValue);
}
