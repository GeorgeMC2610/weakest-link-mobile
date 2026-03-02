import 'package:flutter/material.dart';
import 'package:weakest_link/screens/shared_views/add_player.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  bool get _canStartGame =>
      _selectedPlayers.length >= 2 && _selectedQuestionCollections.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weakest Link'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            _buildPlayersTab(),
            _buildCollectionsTab(),
            _buildSettingsTab(),
          ],
        ),
        floatingActionButton: _canStartGame
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game',
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                    )),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting Game...')),
                  );
                })
            : null,
      ),
    );
  }

  Widget _buildPlayersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              ..._allPlayers.map((player) {
                final isSelected = _selectedPlayers.contains(player);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(player.name),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: player.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      if (isSelected) {
                        _selectedPlayers.remove(player);
                      } else {
                        _selectedPlayers.add(player);
                      }
                    });
                  },
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () async {
                  final newPlayer = await showDialog<Player>(
                    context: context,
                    builder: (context) => const AddPlayerDialog(),
                  );
                  if (newPlayer != null) {
                    setState(() {
                      _allPlayers.add(newPlayer);
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              ..._allQuestionCollections.map((item) {
                final isSelected = _selectedQuestionCollections.contains(item);
                final count = (item.length * 7) % 50 + 10;
                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item),
                      Text(
                        '$count questions',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedQuestionCollections.add(item);
                      } else {
                        _selectedQuestionCollections.remove(item);
                      }
                    });
                  },
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add Question Collection clicked')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Timer Enabled'),
          value: _isTimerEnabled,
          onChanged: (value) {
            setState(() {
              _isTimerEnabled = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Sound Effects'),
          value: _isSoundEnabled,
          onChanged: (value) {
            setState(() {
              _isSoundEnabled = value;
            });
          },
        ),
        const ListTile(
          title: Text('Difficulty'),
          trailing: Text('Medium'),
        ),
        const ListTile(
          title: Text('Language'),
          trailing: Text('English'),
        ),
      ],
    );
  }
}
