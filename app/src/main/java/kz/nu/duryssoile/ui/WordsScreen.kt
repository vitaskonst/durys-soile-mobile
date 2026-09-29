package kz.nu.duryssoile.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.paging.LoadState
import androidx.paging.compose.LazyPagingItems
import androidx.paging.compose.collectAsLazyPagingItems
import kotlinx.coroutines.launch
import kz.nu.duryssoile.R
import kz.nu.duryssoile.data.PlaybackState
import kz.nu.duryssoile.data.Word

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WordsScreen(viewModel: WordsViewModel) {
    val query by viewModel.query.collectAsStateWithLifecycle()
    val playback by viewModel.playback.collectAsStateWithLifecycle()
    val commonly = viewModel.commonlyWords.collectAsLazyPagingItems()
    val parasite = viewModel.parasiteWords.collectAsLazyPagingItems()

    val pagerState = rememberPagerState(pageCount = { 2 })
    val scope = rememberCoroutineScope()
    val keyboard = LocalSoftwareKeyboardController.current

    var detail by remember { mutableStateOf<Word?>(null) }

    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = {
                    Text(
                        text = stringResource(R.string.app_name),
                        fontWeight = FontWeight.SemiBold,
                    )
                },
            )
        },
    ) { padding ->
        Column(Modifier.padding(padding).fillMaxSize()) {
            OutlinedTextField(
                value = query,
                onValueChange = viewModel::onQueryChange,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                placeholder = { Text(stringResource(R.string.search_hint)) },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                trailingIcon = {
                    if (query.isNotEmpty()) {
                        IconButton(onClick = { viewModel.onQueryChange("") }) {
                            Icon(
                                Icons.Default.Clear,
                                contentDescription = stringResource(R.string.search_clear),
                            )
                        }
                    }
                },
                singleLine = true,
                shape = MaterialTheme.shapes.large,
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                keyboardActions = KeyboardActions(onSearch = { keyboard?.hide() }),
            )

            TabRow(selectedTabIndex = pagerState.currentPage) {
                listOf(R.string.tab_commonly, R.string.tab_parasite).forEachIndexed { index, res ->
                    Tab(
                        selected = pagerState.currentPage == index,
                        onClick = { scope.launch { pagerState.animateScrollToPage(index) } },
                        text = {
                            Text(
                                text = stringResource(res),
                                maxLines = 2,
                                textAlign = TextAlign.Center,
                                style = MaterialTheme.typography.labelLarge,
                            )
                        },
                    )
                }
            }

            HorizontalPager(state = pagerState, modifier = Modifier.fillMaxSize()) { page ->
                WordList(
                    items = if (page == 0) commonly else parasite,
                    playback = playback,
                    onPlay = viewModel::onPlayToggle,
                    onOpen = { detail = it },
                )
            }
        }
    }

    detail?.let { word ->
        WordDetailSheet(
            word = word,
            playback = playback,
            onPlay = viewModel::onPlayToggle,
            onDismiss = { detail = null },
        )
    }
}

@Composable
private fun WordList(
    items: LazyPagingItems<Word>,
    playback: PlaybackState,
    onPlay: (Long) -> Unit,
    onOpen: (Word) -> Unit,
) {
    when (val refresh = items.loadState.refresh) {
        is LoadState.Loading -> Box(Modifier.fillMaxSize(), Alignment.Center) {
            CircularProgressIndicator()
        }

        is LoadState.Error -> Box(Modifier.fillMaxSize(), Alignment.Center) {
            MessageState(
                title = stringResource(R.string.error_title),
                subtitle = stringResource(R.string.error_subtitle),
                onRetry = items::retry,
            )
        }

        else -> {
            if (items.itemCount == 0) {
                Box(Modifier.fillMaxSize(), Alignment.Center) {
                    MessageState(
                        title = stringResource(R.string.empty_title),
                        subtitle = stringResource(R.string.empty_subtitle),
                    )
                }
                return
            }
            LazyColumn(Modifier.fillMaxSize()) {
                items(count = items.itemCount) { index ->
                    items[index]?.let { word ->
                        WordRow(
                            word = word,
                            isLoading = playback.loadingId == word.id,
                            isPlaying = playback.playingId == word.id,
                            onPlay = { word.id?.let(onPlay) },
                            onOpen = { onOpen(word) },
                        )
                        HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
                    }
                }

                when (val append = items.loadState.append) {
                    is LoadState.Loading -> item {
                        Box(
                            Modifier.fillMaxWidth().padding(16.dp),
                            Alignment.Center,
                        ) { CircularProgressIndicator(Modifier.size(24.dp), strokeWidth = 2.dp) }
                    }

                    is LoadState.Error -> item {
                        MessageState(
                            title = stringResource(R.string.error_title),
                            subtitle = stringResource(R.string.error_subtitle),
                            onRetry = items::retry,
                        )
                    }

                    else -> Unit
                }
            }
        }
    }
}

@Composable
private fun WordRow(
    word: Word,
    isLoading: Boolean,
    isPlaying: Boolean,
    onPlay: () -> Unit,
    onOpen: () -> Unit,
) {
    // Words with usage examples open a detail sheet; the rest just play.
    val clickAction = if (word.hasUsageExamples) onOpen else onPlay

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = clickAction)
            .padding(start = 16.dp, end = 8.dp, top = 14.dp, bottom = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Column(Modifier.weight(1f)) {
            Text(
                text = word.word.orEmpty(),
                style = MaterialTheme.typography.bodyLarge,
            )
            word.correctVersions?.firstOrNull()?.word?.let { suggestion ->
                Text(
                    text = suggestion,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.primary,
                )
            }
        }

        IconButton(onClick = onPlay, enabled = word.id != null) {
            PlayIndicator(isLoading = isLoading, isPlaying = isPlaying)
        }

        if (word.hasUsageExamples) {
            Icon(
                Icons.Default.KeyboardArrowRight,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
