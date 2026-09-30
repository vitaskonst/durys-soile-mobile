import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Play / loading / stop, crossfading so the button never jumps.
class PlayIndicator extends StatelessWidget {
  const PlayIndicator({super.key, required this.isLoading, required this.isPlaying, this.color});

  final bool isLoading;
  final bool isPlaying;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    final Widget child;
    if (isLoading) {
      child = SizedBox.square(
        key: const ValueKey('loading'),
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: tint),
      );
    } else if (isPlaying) {
      child = Container(
        key: const ValueKey('playing'),
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(3)),
      );
    } else {
      child = Icon(Icons.play_arrow, key: const ValueKey('idle'), color: tint);
    }
    return SizedBox.square(
      dimension: 24,
      child: Center(child: AnimatedSwitcher(duration: const Duration(milliseconds: 150), child: child)),
    );
  }
}

/// A centered title, explanation and optional retry button.
class MessageState extends StatelessWidget {
  const MessageState({super.key, required this.title, required this.subtitle, this.onRetry});

  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ],
      ),
    );
  }
}
