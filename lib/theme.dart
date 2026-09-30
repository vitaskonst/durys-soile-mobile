import 'package:flutter/material.dart';

// Seeded from the launcher icon: terracotta ornament + cyan headphones.
const _light = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF8F4E24),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDBC8),
  onPrimaryContainer: Color(0xFF331200),
  secondary: Color(0xFF00687D),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFB3EBFA),
  onSecondaryContainer: Color(0xFF001F27),
  tertiary: Color(0xFF6F5B40),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFADEBC),
  onTertiaryContainer: Color(0xFF261906),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFF8F5),
  onSurface: Color(0xFF211A16),
  onSurfaceVariant: Color(0xFF52443C),
  surfaceContainer: Color(0xFFFCEDE6),
  surfaceContainerHigh: Color(0xFFF7E7E0),
  outline: Color(0xFF85736B),
  outlineVariant: Color(0xFFD7C2B8),
);

const _dark = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB68C),
  onPrimary: Color(0xFF542100),
  primaryContainer: Color(0xFF72350D),
  onPrimaryContainer: Color(0xFFFFDBC8),
  secondary: Color(0xFF5FD4EE),
  onSecondary: Color(0xFF003642),
  secondaryContainer: Color(0xFF004E5F),
  onSecondaryContainer: Color(0xFFB3EBFA),
  tertiary: Color(0xFFDDC2A1),
  onTertiary: Color(0xFF3D2E16),
  tertiaryContainer: Color(0xFF55442B),
  onTertiaryContainer: Color(0xFFFADEBC),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1A120D),
  onSurface: Color(0xFFF1DFD7),
  onSurfaceVariant: Color(0xFFD7C2B8),
  surfaceContainer: Color(0xFF271D18),
  surfaceContainerHigh: Color(0xFF322722),
  outline: Color(0xFF9F8D84),
  outlineVariant: Color(0xFF52443C),
);

/// Colors of the incorrect/correct example labels, per theme: fixed reds and
/// greens fail contrast on one background or the other.
class UsageColors extends ThemeExtension<UsageColors> {
  const UsageColors({required this.incorrect, required this.correct});

  final Color incorrect;
  final Color correct;

  @override
  UsageColors copyWith({Color? incorrect, Color? correct}) =>
      UsageColors(incorrect: incorrect ?? this.incorrect, correct: correct ?? this.correct);

  @override
  UsageColors lerp(UsageColors? other, double t) => other == null
      ? this
      : UsageColors(
          incorrect: Color.lerp(incorrect, other.incorrect, t)!,
          correct: Color.lerp(correct, other.correct, t)!,
        );
}

ThemeData _theme(ColorScheme scheme, UsageColors usage) => ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      extensions: [usage],
    );

final lightTheme = _theme(_light, const UsageColors(incorrect: Color(0xFFA33A26), correct: Color(0xFF1E6B45)));
final darkTheme = _theme(_dark, const UsageColors(incorrect: Color(0xFFFFB4A3), correct: Color(0xFF7EDBAA)));
