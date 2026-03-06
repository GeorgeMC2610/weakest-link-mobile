import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weakest_link/services/game_manager.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        return ListView(
          children: [
            SwitchListTile(
              title: const Text('Host Mode'),
              subtitle: const Text('Turn this off, if you want right answers and weakest/strongest links to be revealed manually.'),
              value: gameManager.hostMode,
              onChanged: (_) => gameManager.toggleHostMode(),
            ),
            const Divider(),
            const ListTile(
              title: Text('App Version'),
              trailing: Text('1.0.0'),

            ),
          ],
        );
      },
    );
  }
}
