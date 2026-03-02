import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _allPlayers = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
  final List<String> _selectedPlayers = [];

  final List<String> _allQuestionCollections = [
    'Default',
    'My Collection 1',
    'My Collection 2',
    'My Collection 3',
  ];
  final List<String> _selectedQuestionTypes = [];

  bool _isTimerEnabled = true;
  bool _isSoundEnabled = true;

  bool get _canStartGame =>
      _selectedPlayers.length >= 2 && _selectedQuestionTypes.isNotEmpty;

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
              Tab(text: 'Questions'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSelectionTab(
              items: _allPlayers,
              selectedItems: _selectedPlayers,
              showColorDot: true,
              onToggle: (item) {
                setState(() {
                  if (_selectedPlayers.contains(item)) {
                    _selectedPlayers.remove(item);
                  } else {
                    _selectedPlayers.add(item);
                  }
                });
              },
              onAdd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Player clicked')),
                );
              },
            ),
            _buildSelectionTab(
              items: _allQuestionCollections,
              selectedItems: _selectedQuestionTypes,
              showSubtitle: true,
              onToggle: (item) {
                setState(() {
                  if (_selectedQuestionTypes.contains(item)) {
                    _selectedQuestionTypes.remove(item);
                  } else {
                    _selectedQuestionTypes.add(item);
                  }
                });
              },
              onAdd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Question Type clicked')),
                );
              },
            ),
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

  Widget _buildSelectionTab({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onToggle,
    required VoidCallback onAdd,
    bool showColorDot = false,
    bool showSubtitle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              ...items.map((item) {
                final isSelected = selectedItems.contains(item);
                // Imaginary count for demonstration
                final count = (item.length * 7) % 50 + 10;
                return FilterChip(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item),
                          if (showColorDot) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.primaries[
                                    items.indexOf(item) % Colors.primaries.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (showSubtitle)
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
                  onSelected: (_) => onToggle(item),
                );
              }),
              ActionChip(
                avatar: const Icon(Icons.add),
                label: const Text('Add'),
                onPressed: onAdd,
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
