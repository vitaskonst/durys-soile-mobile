import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';

/// About the app, and the interface language.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // Each language named in itself, as language pickers usually do.
  static const _languages = {'kk': 'Қазақша', 'ru': 'Русский', 'en': 'English'};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = AppScope.of(context).locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.infoTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.infoBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.infoThanks,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                  const SizedBox(height: 8),
                  Text(l10n.infoGrant,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ListenableBuilder(
            listenable: locale,
            builder: (context, _) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              trailing: DropdownButton<String>(
                value: locale.locale?.languageCode ?? '',
                underline: const SizedBox.shrink(),
                onChanged: (code) => locale.set(code == null || code.isEmpty ? null : Locale(code)),
                items: [
                  DropdownMenuItem(value: '', child: Text(l10n.languageSystem)),
                  for (final entry in _languages.entries)
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
