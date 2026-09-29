package kz.nu.duryssoile.ui.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color

// Seeded from the launcher icon: terracotta ornament (#E8A57B) + cyan headphones.
val LightColors = lightColorScheme(
    primary = Color(0xFF8F4E24),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFFFDBC8),
    onPrimaryContainer = Color(0xFF331200),
    secondary = Color(0xFF00687D),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFB3EBFA),
    onSecondaryContainer = Color(0xFF001F27),
    tertiary = Color(0xFF6F5B40),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFFADEBC),
    onTertiaryContainer = Color(0xFF261906),
    background = Color(0xFFFFF8F5),
    onBackground = Color(0xFF211A16),
    surface = Color(0xFFFFF8F5),
    onSurface = Color(0xFF211A16),
    surfaceVariant = Color(0xFFF4DED4),
    onSurfaceVariant = Color(0xFF52443C),
    surfaceContainer = Color(0xFFFCEDE6),
    surfaceContainerHigh = Color(0xFFF7E7E0),
    outline = Color(0xFF85736B),
    outlineVariant = Color(0xFFD7C2B8),
    error = Color(0xFFBA1A1A),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = Color(0xFF410002),
)

val DarkColors = darkColorScheme(
    primary = Color(0xFFFFB68C),
    onPrimary = Color(0xFF542100),
    primaryContainer = Color(0xFF72350D),
    onPrimaryContainer = Color(0xFFFFDBC8),
    secondary = Color(0xFF5FD4EE),
    onSecondary = Color(0xFF003642),
    secondaryContainer = Color(0xFF004E5F),
    onSecondaryContainer = Color(0xFFB3EBFA),
    tertiary = Color(0xFFDDC2A1),
    onTertiary = Color(0xFF3D2E16),
    tertiaryContainer = Color(0xFF55442B),
    onTertiaryContainer = Color(0xFFFADEBC),
    background = Color(0xFF1A120D),
    onBackground = Color(0xFFF1DFD7),
    surface = Color(0xFF1A120D),
    onSurface = Color(0xFFF1DFD7),
    surfaceVariant = Color(0xFF52443C),
    onSurfaceVariant = Color(0xFFD7C2B8),
    surfaceContainer = Color(0xFF271D18),
    surfaceContainerHigh = Color(0xFF322722),
    outline = Color(0xFF9F8D84),
    outlineVariant = Color(0xFF52443C),
    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6),
)

/**
 * Correct/incorrect usage colors. The v1 app hardcoded #f03e01 and #013220,
 * which fail contrast on a dark background, so each has a per-theme value.
 */
data class UsageColors(
    val incorrect: Color,
    val onIncorrectContainer: Color,
    val incorrectContainer: Color,
    val correct: Color,
    val onCorrectContainer: Color,
    val correctContainer: Color,
)

val LightUsageColors = UsageColors(
    incorrect = Color(0xFFA33A26),
    onIncorrectContainer = Color(0xFF3B0A02),
    incorrectContainer = Color(0xFFFFDAD1),
    correct = Color(0xFF1E6B45),
    onCorrectContainer = Color(0xFF00210F),
    correctContainer = Color(0xFFB8F0CE),
)

val DarkUsageColors = UsageColors(
    incorrect = Color(0xFFFFB4A3),
    onIncorrectContainer = Color(0xFFFFDAD1),
    incorrectContainer = Color(0xFF5E1706),
    correct = Color(0xFF7EDBAA),
    onCorrectContainer = Color(0xFFB8F0CE),
    correctContainer = Color(0xFF00522F),
)
