import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weakest_link/classes/player.dart';
import 'package:weakest_link/classes/question_collection.dart';
import 'package:weakest_link/screens/home_tabs/players_tab.dart';
import 'package:weakest_link/screens/home_tabs/collections_tab.dart';
import 'package:weakest_link/screens/home_tabs/settings_tab.dart';
import 'package:weakest_link/screens/round_start.dart';
import 'package:weakest_link/services/player_service.dart';
import 'package:weakest_link/services/question_service.dart';
import 'package:weakest_link/screens/question_collections.dart';

import '../classes/question.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final List<Player> _selectedPlayers = [];
  final List<QuestionCollection> _selectedQuestionCollections = [];

  bool _isTimerEnabled = true;
  bool _isSoundEnabled = true;

  bool _isEditingPlayers = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  bool get _canStartGame =>
      _selectedPlayers.length >= 2 && _selectedQuestionCollections.isNotEmpty;

  void _toggleEditingPlayers() {
    setState(() {
      _isEditingPlayers = !_isEditingPlayers;
      if (_isEditingPlayers) {
        _shakeController.repeat(reverse: true);
      } else {
        _shakeController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weakest Link'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (_isEditingPlayers)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _toggleEditingPlayers,
                tooltip: 'Done editing',
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Players'),
              Tab(text: 'Collections'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ValueListenableBuilder<Box<Player>>(
              valueListenable: PlayerService.listenable,
              builder: (context, box, _) {
                final allPlayers = box.values.toList();
                // Clean up selected players if any were deleted
                _selectedPlayers.removeWhere((p) => !allPlayers.contains(p));
                
                return PlayersTab(
                  allPlayers: allPlayers,
                  selectedPlayers: _selectedPlayers,
                  isEditing: _isEditingPlayers,
                  shakeController: _shakeController,
                  onToggleSelection: (player) {
                    setState(() {
                      if (_selectedPlayers.contains(player)) {
                        _selectedPlayers.remove(player);
                      } else {
                        _selectedPlayers.add(player);
                      }
                    });
                  },
                  onToggleEditing: _toggleEditingPlayers,
                  onAddPlayer: (player) async {
                    await PlayerService.addPlayer(player);
                  },
                  onDeletePlayer: (player) async {
                    await PlayerService.deletePlayer(player);
                    setState(() {
                      _selectedPlayers.remove(player);
                    });
                  },
                );
              },
            ),
            ValueListenableBuilder<Box<QuestionCollection>>(
              valueListenable: QuestionService.listenable,
              builder: (context, box, _) {
                final allCollections = box.values.toList();
                // Clean up selected collections if any were deleted
                _selectedQuestionCollections.removeWhere((c) => !allCollections.contains(c));

                return CollectionsTab(
                  allCollections: allCollections,
                  selectedCollections: _selectedQuestionCollections,
                  onToggleSelection: (collection, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedQuestionCollections.add(collection);
                      } else {
                        _selectedQuestionCollections.remove(collection);
                      }
                    });
                  },
                  onAddCollection: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QuestionCollections(),
                      ),
                    );
                  },
                );
              },
            ),
            SettingsTab(
              isTimerEnabled: _isTimerEnabled,
              isSoundEnabled: _isSoundEnabled,
              onTimerChanged: (value) => setState(() => _isTimerEnabled = value),
              onSoundChanged: (value) => setState(() => _isSoundEnabled = value),
            ),
          ],
        ),
        floatingActionButton: _canStartGame && !_isEditingPlayers
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    )),
                onPressed: () {
                  // Collect all questions from selected collections
                  final List<Question> allQuestions = [];
                  for (var collection in _selectedQuestionCollections) {
                    allQuestions.addAll(collection.questions);
                  }
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RoundStart(
                        players: _selectedPlayers,
                        questions: allQuestions,
                        roundNumber: 1,
                      ),
                    ),
                  );
                })
            : null,
      ),
    );
  }
}
