package kz.nu.duryssoile.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider.AndroidViewModelFactory.Companion.APPLICATION_KEY
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import androidx.paging.cachedIn
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch
import kz.nu.duryssoile.DurysSoileApp
import kz.nu.duryssoile.data.AudioPlayer
import kz.nu.duryssoile.data.WordRepository
import kz.nu.duryssoile.data.WordType

@OptIn(FlowPreview::class, ExperimentalCoroutinesApi::class)
class WordsViewModel(
    repository: WordRepository,
    private val audioPlayer: AudioPlayer,
) : ViewModel() {

    private val _query = MutableStateFlow("")
    val query: StateFlow<String> = _query.asStateFlow()

    val playback = audioPlayer.state

    // Typing shouldn't fire a request per keystroke, but clearing the box
    // should feel instant -- hence the per-value delay.
    private val debouncedQuery = _query
        .debounce { if (it.isEmpty()) 0L else 300L }
        .distinctUntilChanged()

    val commonlyWords = debouncedQuery
        .flatMapLatest { repository.words(WordType.COMMONLY_MISPRONOUNCED, it) }
        .cachedIn(viewModelScope)

    val parasiteWords = debouncedQuery
        .flatMapLatest { repository.words(WordType.PARASITE, it) }
        .cachedIn(viewModelScope)

    fun onQueryChange(value: String) {
        _query.value = value
    }

    fun onPlayToggle(id: Long) {
        viewModelScope.launch { audioPlayer.toggle(id) }
    }

    fun onAudioErrorShown() = audioPlayer.clearError()

    override fun onCleared() {
        audioPlayer.stop()
        super.onCleared()
    }

    companion object {
        val Factory = viewModelFactory {
            initializer {
                val app = this[APPLICATION_KEY] as DurysSoileApp
                WordsViewModel(app.repository, app.audioPlayer)
            }
        }
    }
}
