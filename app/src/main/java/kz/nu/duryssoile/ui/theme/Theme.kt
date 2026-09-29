package kz.nu.duryssoile.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf

val LocalUsageColors = staticCompositionLocalOf { LightUsageColors }

@Composable
fun DurysSoileTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    // Deliberately not using dynamic color: the terracotta/cyan palette is the
    // app's identity and matches the launcher icon.
    val colors = if (darkTheme) DarkColors else LightColors
    val usage = if (darkTheme) DarkUsageColors else LightUsageColors

    CompositionLocalProvider(LocalUsageColors provides usage) {
        MaterialTheme(colorScheme = colors, content = content)
    }
}
