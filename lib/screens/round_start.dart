import 'package:flutter/material.dart';
import 'package:weakest_link/classes/player.dart';

class RoundStart extends StatelessWidget {
  final List<Player> players;
  final int roundNumber;

  const RoundStart({
    super.key,
    required this.players,
    required this.roundNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Round $roundNumber'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Round $roundNumber',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              'Remaining Players:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: player.isEliminated 
                            ? player.color.withOpacity(0.3) 
                            : player.color,
                        radius: 12,
                      ),
                      title: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: player.isEliminated ? Colors.grey : null,
                          decoration: player.isEliminated 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton.tonal(
                onPressed: () {
                  // Logic to start the round timer
                },
                child: const Text(
                  'CLOCK!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
