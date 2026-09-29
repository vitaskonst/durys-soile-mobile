package kz.nu.duryssoile.ui

import androidx.compose.animation.Crossfade
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.res.stringResource
import kz.nu.duryssoile.R

/** Play / loading / stop, crossfading so the button never jumps. */
@Composable
fun PlayIndicator(
    isLoading: Boolean,
    isPlaying: Boolean,
    tint: Color = MaterialTheme.colorScheme.primary,
) {
    Crossfade(
        targetState = when {
            isLoading -> 0
            isPlaying -> 1
            else -> 2
        },
        label = "play-state",
    ) { state ->
        when (state) {
            0 -> CircularProgressIndicator(modifier = Modifier.size(20.dp), strokeWidth = 2.dp, color = tint)
            1 -> Box(
                Modifier
                    .size(18.dp)
                    .clip(RoundedCornerShape(3.dp))
                    .background(tint),
            )
            else -> Icon(
                Icons.Default.PlayArrow,
                contentDescription = stringResource(R.string.listen),
                tint = tint,
            )
        }
    }
}

@Composable
fun MessageState(
    title: String,
    subtitle: String,
    onRetry: (() -> Unit)? = null,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            textAlign = TextAlign.Center,
        )
        Text(
            text = subtitle,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
        )
        if (onRetry != null) {
            Button(onClick = onRetry, modifier = Modifier.padding(top = 8.dp)) {
                Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(18.dp))
                Text(
                    text = stringResource(R.string.retry),
                    modifier = Modifier.padding(start = 8.dp),
                )
            }
        }
    }
}
