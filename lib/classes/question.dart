import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 1)
class Question extends HiveObject {
  @HiveField(0)
  final String title;
  
  @HiveField(1)
  final String answer;
  
  @HiveField(2)
  final int difficulty;

  Question({required this.title, required this.answer, required this.difficulty});
}
