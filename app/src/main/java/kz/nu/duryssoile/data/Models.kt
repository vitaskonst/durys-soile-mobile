package kz.nu.duryssoile.data

import java.io.Serializable

/**
 * Mirrors the v1 API response exactly.
 *
 * Every field is nullable on purpose: the backend omits `correctVersions`
 * entirely for commonly-mispronounced words (their source JSON never had the
 * key), and omits `incorrectUsage`/`correctUsage` when a version has no usage
 * example. Gson leaves anything absent as null.
 */
data class Word(
    val id: Long? = null,
    val word: String? = null,
    val type: String? = null,
    val correctVersions: List<CorrectVersion>? = null,
) : Serializable {
    val hasUsageExamples: Boolean
        get() = !correctVersions.isNullOrEmpty()
}

data class CorrectVersion(
    val word: String? = null,
    val incorrectUsage: String? = null,
    val correctUsage: String? = null,
) : Serializable

/** The two `type` query values the backend accepts. */
enum class WordType(val apiValue: String) {
    COMMONLY_MISPRONOUNCED("commonly-mispronounced"),
    PARASITE("parasite"),
}
