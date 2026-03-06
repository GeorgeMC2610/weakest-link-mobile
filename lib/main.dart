import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:weakest_link/screens/home.dart';
import 'package:weakest_link/services/game_manager.dart';
import 'package:weakest_link/services/player_service.dart';
import 'package:weakest_link/services/question_service.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'classes/player.dart';
import 'classes/question.dart';
import 'classes/question_collection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive for Flutter
  await Hive.initFlutter();

  // 2. Register Type Adapters (Must match the IDs in your models)
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(QuestionCollectionAdapter());

  // 3. Open Boxes via Services
  await PlayerService.init();
  await QuestionService.init();

  // 4. Initialize Localization
  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en',
    supportedLocales: ['en', 'el'],
  );

  runApp(
    LocalizedApp(
      delegate,
      ChangeNotifierProvider(
        create: (_) => GameManager(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'Weakest Link',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          localizationDelegate,
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const Home(),
      ),
    );
  }
}
