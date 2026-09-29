package kz.nu.duryssoile

import android.app.Application
import kz.nu.duryssoile.data.AudioPlayer
import kz.nu.duryssoile.data.Network
import kz.nu.duryssoile.data.WordRepository

/** Hand-rolled service locator -- the graph is three objects, a DI framework would be noise. */
class DurysSoileApp : Application() {

    lateinit var repository: WordRepository
        private set
    lateinit var audioPlayer: AudioPlayer
        private set

    override fun onCreate() {
        super.onCreate()
        val client = Network.okHttp(cacheDir)
        val api = Network.openApi(client)
        repository = WordRepository(api)
        audioPlayer = AudioPlayer(api, cacheDir)
    }
}
