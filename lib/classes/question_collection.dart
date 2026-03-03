import 'package:hive/hive.dart';
import 'package:weakest_link/classes/question.dart';

part 'question_collection.g.dart';

@HiveType(typeId: 2)
class QuestionCollection extends HiveObject {
  @HiveField(0)
  final List<Question> questions;
  
  @HiveField(1)
  final String title;

  QuestionCollection({required this.title, required this.questions});
}
