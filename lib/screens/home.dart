import 'package:flutter/material.dart';
import 'package:weakest_link/screens/home_tabs/players_tab.dart';
import 'package:weakest_link/screens/home_tabs/collections_tab.dart';
import 'package:weakest_link/screens/home_tabs/settings_tab.dart';
import 'package:weakest_link/screens/round_start.dart';

import '../classes/player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final List<Player> _allPlayers = [
    Player(name: 'Alice', color: Colors.blue),
    Player(name: 'Bob', color: Colors.red),
    Player(name: 'Charlie', color: Colors.green),
    Player(name: 'David', color: Colors.orange),
    Player(name: 'Eve', color: Colors.purple),
  ];
  final List<Player> _selectedPlayers = [];

  final List<String> _allQuestionCollections = [
    'Default',
    'My Collection 1',
    'My Collection 2',
    'My Collection 3',
  ];
  final List<String> _selectedQuestionCollections = [];

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
              Tab(text: 'Question Collections'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PlayersTab(
              allPlayers: _allPlayers,
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
              onAddPlayer: (player) {
                setState(() {
                  _allPlayers.add(player);
                });
              },
              onDeletePlayer: (player) {
                setState(() {
                  _allPlayers.remove(player);
                  _selectedPlayers.remove(player);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${player.name} removed'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            CollectionsTab(
              allCollections: _allQuestionCollections,
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Question Collection clicked')),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RoundStart(
                        players: _selectedPlayers,
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
