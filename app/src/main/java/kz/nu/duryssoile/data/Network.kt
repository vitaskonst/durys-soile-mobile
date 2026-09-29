package kz.nu.duryssoile.data

import com.google.gson.GsonBuilder
import kz.nu.duryssoile.BuildConfig
import java.io.File
import java.util.concurrent.TimeUnit
import okhttp3.Cache
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

object Network {

    val BASE_URL: String = BuildConfig.BASE_URL

    /** Audio responses carry Cache-Control: max-age=86400, so an HTTP cache pays off. */
    fun okHttp(cacheDir: File): OkHttpClient = OkHttpClient.Builder()
        .cache(Cache(File(cacheDir, "http"), 32L * 1024 * 1024))
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    fun openApi(client: OkHttpClient, baseUrl: String = BASE_URL): OpenApi = Retrofit.Builder()
        .baseUrl(baseUrl)
        .client(client)
        .addConverterFactory(GsonConverterFactory.create(GsonBuilder().setLenient().create()))
        .build()
        .create(OpenApi::class.java)
}
