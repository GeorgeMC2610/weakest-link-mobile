import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:weakest_link/screens/home.dart';
import 'package:weakest_link/services/game_manager.dart';
import 'package:weakest_link/services/player_service.dart';
import 'package:weakest_link/services/question_service.dart';

import 'classes/player.dart';
import 'classes/question.dart';
import 'classes/question_collection.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Hive for Flutter
  await Hive.initFlutter();

  // 3. Register Type Adapters (Must match the IDs in your models)
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuestionCollectionAdapter());

  // 4. Open Boxes via Services
  await PlayerService.init();
  await QuestionService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameManager(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}