package kz.nu.duryssoile.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kz.nu.duryssoile.R
import kz.nu.duryssoile.data.CorrectVersion
import kz.nu.duryssoile.data.PlaybackState
import kz.nu.duryssoile.data.Word
import kz.nu.duryssoile.ui.theme.LocalUsageColors

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WordDetailSheet(
    word: Word,
    playback: PlaybackState,
    onPlay: (Long) -> Unit,
    onDismiss: () -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(onDismissRequest = onDismiss, sheetState = sheetState) {
        Column(
            Modifier
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp)
                .padding(bottom = 24.dp)
                .navigationBarsPadding(),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        text = word.word.orEmpty(),
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.SemiBold,
                    )
                    word.correctVersions?.firstOrNull()?.word?.let {
                        Text(
                            text = it,
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.primary,
                        )
                    }
                }

                FilledTonalButton(
                    onClick = { word.id?.let(onPlay) },
                    enabled = word.id != null,
                ) {
                    PlayIndicator(
                        isLoading = playback.loadingId == word.id,
                        isPlaying = playback.playingId == word.id,
                        tint = MaterialTheme.colorScheme.onSecondaryContainer,
                    )
                    Text(
                        text = stringResource(R.string.listen),
                        modifier = Modifier.padding(start = 8.dp),
                    )
                }
            }

            word.correctVersions.orEmpty().forEach { version ->
                UsageCard(version)
            }
        }
    }
}

@Composable
private fun UsageCard(version: CorrectVersion) {
    val usage = LocalUsageColors.current

    // Some versions carry no example sentences at all -- skip the card entirely
    // rather than rendering two empty labels.
    if (version.incorrectUsage.isNullOrBlank() && version.correctUsage.isNullOrBlank()) return

    Card(
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceContainer,
        ),
        modifier = Modifier.fillMaxWidth(),
    ) {
        Column(
            Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            version.incorrectUsage?.takeIf { it.isNotBlank() }?.let {
                UsageBlock(
                    label = stringResource(R.string.detail_incorrect),
                    text = it,
                    labelColor = usage.incorrect,
                )
            }
            version.correctUsage?.takeIf { it.isNotBlank() }?.let {
                UsageBlock(
                    label = stringResource(R.string.detail_correct),
                    text = it,
                    labelColor = usage.correct,
                )
            }
        }
    }
}

@Composable
private fun UsageBlock(
    label: String,
    text: String,
    labelColor: androidx.compose.ui.graphics.Color,
) {
    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelMedium,
            color = labelColor,
            fontWeight = FontWeight.SemiBold,
        )
        Text(
            text = text,
            style = MaterialTheme.typography.bodyLarge,
        )
    }
}
