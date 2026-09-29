package kz.nu.duryssoile

import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import okhttp3.mockwebserver.Dispatcher
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.RecordedRequest

/**
 * Replays the backend's API contract over the word lists in test resources:
 * `offset` is a PAGE INDEX, `filter` is a case-insensitive prefix, and
 * `correctVersions` is omitted entirely rather than sent as an empty list.
 */
class FakeBackend : Dispatcher() {

    val requests = mutableListOf<RecordedRequest>()

    private fun load(name: String): List<JsonObject> =
        JsonParser.parseReader(
            javaClass.classLoader!!.getResourceAsStream("$name.json")!!.reader(),
        ).asJsonArray.map { it.asJsonObject }

    private val byType = mapOf(
        "parasite" to load("parasite"),
        "commonly-mispronounced" to load("commonly-mispronounced"),
    )

    fun total(type: String, filter: String = ""): Int = rows(type, filter).size

    private fun rows(type: String, filter: String): List<JsonObject> {
        val all = byType.getValue(type)
        if (filter.isBlank()) return all
        return all.filter {
            it.get("word")?.asString.orEmpty().lowercase().startsWith(filter.lowercase())
        }
    }

    override fun dispatch(request: RecordedRequest): MockResponse {
        requests += request
        val url = request.requestUrl!!

        if (url.encodedPath.endsWith("/words")) {
            val type = url.queryParameter("type") ?: return MockResponse().setResponseCode(422)
            val offset = url.queryParameter("offset")?.toIntOrNull() ?: 0
            val limit = url.queryParameter("limit")?.toIntOrNull() ?: 20
            val filter = url.queryParameter("filter").orEmpty()

            val matching = rows(type, filter)
            val page = matching.drop(offset * limit).take(limit)

            val body = JsonArray().apply {
                page.forEach { row ->
                    add(
                        JsonObject().apply {
                            addProperty("id", row.get("id").asLong)
                            addProperty("word", row.get("word").asString)
                            // Present only when the source row actually has versions.
                            row.getAsJsonArray("correctVersions")
                                ?.takeIf { it.size() > 0 }
                                ?.let { add("correctVersions", it) }
                            addProperty("type", type)
                        },
                    )
                }
            }
            return MockResponse()
                .setHeader("Content-Type", "application/json")
                .setBody(Gson().toJson(body))
        }

        if (url.encodedPath.contains("/audio/")) {
            return MockResponse()
                .setHeader("Content-Type", "audio/mpeg")
                .setBody("fake-mp3-bytes")
        }

        return MockResponse().setResponseCode(404)
    }
}
