import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:weakest_link/services/game_manager.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate('settings.select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  changeLocale(context, 'en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Ελληνικά'),
                onTap: () {
                  changeLocale(context, 'el');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final currentLocale = LocalizedApp.of(context).delegate.currentLocale.languageCode;
        final languageName = currentLocale == 'en' ? 'English' : 'Ελληνικά';

        return ListView(
          children: [
            SwitchListTile(
              title: Text(
                translate('settings.host_mode'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                translate(gameManager.hostMode ? 'settings.host_mode_desc2' : 'settings.host_mode_desc1'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: gameManager.hostMode,
              onChanged: (_) => gameManager.toggleHostMode(),
            ),
            const Divider(),
            ListTile(
              title: Text(translate('settings.language')),
              subtitle: Text(languageName),
              leading: const Icon(Icons.language),
              onTap: () => _showLanguageDialog(context),
            ),
            const Divider(),
            ListTile(
              title: Text(translate('settings.app_version')),
              trailing: const Text('1.0.0'),
            ),
          ],
        );
      },
    );
  }
}
