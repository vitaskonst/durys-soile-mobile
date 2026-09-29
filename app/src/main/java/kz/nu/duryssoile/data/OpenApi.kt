package kz.nu.duryssoile.data

import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query
import retrofit2.http.Streaming
import okhttp3.ResponseBody
import retrofit2.Response

interface OpenApi {

    /**
     * NOTE: `offset` is a PAGE NUMBER, not a row offset -- the backend computes
     * `result[offset * limit : (offset + 1) * limit]`. Incrementing it by 1 per
     * page is load-bearing; passing a row offset would re-fetch overlapping rows.
     */
    @GET("words")
    suspend fun words(
        @Query("type") type: String,
        @Query("offset") offset: Int,
        @Query("limit") limit: Int,
        @Query("sort") sort: String = "asc",
        @Query("filter") filter: String? = null,
    ): List<Word>

    @Streaming
    @GET("audio/{id}")
    suspend fun audio(@Path("id") id: Long): Response<ResponseBody>
}
