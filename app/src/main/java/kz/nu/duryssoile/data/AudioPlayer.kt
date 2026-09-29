package kz.nu.duryssoile.data

import android.media.AudioAttributes
import android.media.MediaPlayer
import java.io.File
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext

data class PlaybackState(
    val loadingId: Long? = null,
    val playingId: Long? = null,
    val failedId: Long? = null,
)

/**
 * Fetches a word's audio, then plays it from a local file.
 *
 * The v1 app called MediaPlayer.prepare() on a remote URL from the click
 * handler, which blocks the UI thread for as long as the network takes. Here
 * the bytes are pulled on Dispatchers.IO into the cache directory first, so
 * prepare() only ever touches a local file -- and a replay costs nothing.
 */
class AudioPlayer(
    private val api: OpenApi,
    private val cacheDir: File,
) {
    private val _state = MutableStateFlow(PlaybackState())
    val state: StateFlow<PlaybackState> = _state.asStateFlow()

    private var player: MediaPlayer? = null

    suspend fun toggle(id: Long) {
        if (_state.value.playingId == id || _state.value.loadingId == id) {
            stop()
            return
        }
        play(id)
    }

    private suspend fun play(id: Long) {
        release()
        _state.value = PlaybackState(loadingId = id)
        try {
            val file = withContext(Dispatchers.IO) { fetch(id) }
            withContext(Dispatchers.IO) {
                player = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .build(),
                    )
                    setDataSource(file.absolutePath)
                    setOnCompletionListener {
                        _state.value = PlaybackState()
                        release()
                    }
                    setOnErrorListener { _, _, _ ->
                        _state.value = PlaybackState(failedId = id)
                        release()
                        true
                    }
                    prepare()
                    start()
                }
            }
            _state.value = PlaybackState(playingId = id)
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            _state.value = PlaybackState(failedId = id)
            release()
        }
    }

    private suspend fun fetch(id: Long): File {
        val cached = File(cacheDir, "word-$id.mp3")
        if (cached.exists() && cached.length() > 0) return cached

        val response = api.audio(id)
        if (!response.isSuccessful) error("HTTP ${response.code()}")
        val body = response.body() ?: error("empty body")

        // Write to a temp file first so an interrupted download never leaves a
        // truncated file that would be served from cache forever after.
        val tmp = File(cacheDir, "word-$id.mp3.part")
        body.byteStream().use { input -> tmp.outputStream().use { input.copyTo(it) } }
        if (tmp.length() == 0L) {
            tmp.delete()
            error("empty audio")
        }
        tmp.renameTo(cached)
        return cached
    }

    fun stop() {
        _state.value = PlaybackState()
        release()
    }

    fun clearError() {
        if (_state.value.failedId != null) _state.value = PlaybackState()
    }

    private fun release() {
        player?.runCatching {
            if (isPlaying) stop()
            release()
        }
        player = null
    }
}
