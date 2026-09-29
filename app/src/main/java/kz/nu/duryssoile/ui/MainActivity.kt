package kz.nu.duryssoile.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.List
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import kz.nu.duryssoile.R
import kz.nu.duryssoile.ui.theme.DurysSoileTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DurysSoileTheme {
                AppRoot()
            }
        }
    }
}

private enum class Destination { Words, Info }

@Composable
private fun AppRoot(viewModel: WordsViewModel = viewModel(factory = WordsViewModel.Factory)) {
    var destination by rememberSaveable { mutableStateOf(Destination.Words) }
    val snackbarHostState = remember { SnackbarHostState() }
    val playback by viewModel.playback.collectAsStateWithLifecycle()
    val audioError = stringResource(R.string.audio_error)

    LaunchedEffect(playback.failedId) {
        if (playback.failedId != null) {
            snackbarHostState.showSnackbar(audioError)
            viewModel.onAudioErrorShown()
        }
    }

    Scaffold(
        snackbarHost = { SnackbarHost(snackbarHostState) },
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    selected = destination == Destination.Words,
                    onClick = { destination = Destination.Words },
                    icon = { Icon(Icons.Default.List, contentDescription = null) },
                    label = { Text(stringResource(R.string.nav_words)) },
                )
                NavigationBarItem(
                    selected = destination == Destination.Info,
                    onClick = { destination = Destination.Info },
                    icon = { Icon(Icons.Default.Info, contentDescription = null) },
                    label = { Text(stringResource(R.string.nav_info)) },
                )
            }
        },
    ) { innerPadding ->
        Box(Modifier.padding(bottom = innerPadding.calculateBottomPadding())) {
            when (destination) {
                Destination.Words -> WordsScreen(viewModel)
                Destination.Info -> InfoScreen()
            }
        }
    }
}
