package kz.nu.duryssoile

import androidx.paging.PagingSource
import kotlinx.coroutines.test.runTest
import kz.nu.duryssoile.data.Network
import kz.nu.duryssoile.data.OpenApi
import kz.nu.duryssoile.data.PAGE_SIZE
import kz.nu.duryssoile.data.Word
import kz.nu.duryssoile.data.WordPagingSource
import kz.nu.duryssoile.data.WordType
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class WordPagingSourceTest {

    private lateinit var server: MockWebServer
    private lateinit var backend: FakeBackend
    private lateinit var api: OpenApi

    @Before
    fun setUp() {
        backend = FakeBackend()
        server = MockWebServer().apply {
            dispatcher = backend
            start()
        }
        api = Network.openApi(OkHttpClient(), server.url("/api/v1.0/").toString())
    }

    @After
    fun tearDown() = server.shutdown()

    private fun source(type: WordType, filter: String = "") = WordPagingSource(api, type, filter)

    private suspend fun load(
        source: WordPagingSource,
        key: Int?,
    ): PagingSource.LoadResult.Page<Int, Word> {
        val result = source.load(
            PagingSource.LoadParams.Refresh(key, PAGE_SIZE, false),
        )
        assertTrue("expected a page, got $result", result is PagingSource.LoadResult.Page)
        return result as PagingSource.LoadResult.Page
    }

    @Test
    fun `sends exactly the query the v1 backend expects`() = runTest {
        load(source(WordType.PARASITE), null)

        val url = backend.requests.single().requestUrl!!
        assertEquals("parasite", url.queryParameter("type"))
        assertEquals("0", url.queryParameter("offset"))
        assertEquals("20", url.queryParameter("limit"))
        assertEquals("asc", url.queryParameter("sort"))
        // filter must be absent, not empty -- an empty filter is still falsy
        // server-side, but omitting it keeps the request identical to v1's.
        assertNull(url.queryParameter("filter"))
    }

    @Test
    fun `offset is a page index, so consecutive pages do not overlap`() = runTest {
        val source = source(WordType.PARASITE)

        val first = load(source, null)
        assertEquals(PAGE_SIZE, first.data.size)
        assertEquals(1, first.nextKey)

        val second = load(source, first.nextKey)
        assertEquals("2nd request must ask for page 1", "1", backend.requests[1].requestUrl!!.queryParameter("offset"))

        val firstIds = first.data.mapNotNull { it.id }.toSet()
        val secondIds = second.data.mapNotNull { it.id }.toSet()
        assertTrue("pages overlapped: ${firstIds intersect secondIds}", (firstIds intersect secondIds).isEmpty())
    }

    @Test
    fun `walks the whole dataset exactly once and stops`() = runTest {
        val source = source(WordType.PARASITE)
        val seen = mutableListOf<Long>()
        var key: Int? = null

        while (true) {
            val page = load(source, key)
            seen += page.data.mapNotNull { it.id }
            key = page.nextKey ?: break
        }

        assertEquals(backend.total("parasite"), seen.size)
        assertEquals("every id should be unique", seen.size, seen.toSet().size)
    }

    @Test
    fun `filter is applied as a case-insensitive prefix`() = runTest {
        val page = load(source(WordType.PARASITE, "а"), null)

        assertEquals("а", backend.requests.single().requestUrl!!.queryParameter("filter"))
        assertTrue(page.data.isNotEmpty())
        assertTrue(page.data.all { it.word!!.lowercase().startsWith("а") })
    }

    @Test
    fun `commonly-mispronounced words parse without correctVersions`() = runTest {
        val page = load(source(WordType.COMMONLY_MISPRONOUNCED), null)

        assertEquals(PAGE_SIZE, page.data.size)
        page.data.forEach { word ->
            assertNotNull(word.id)
            assertNotNull(word.word)
            assertEquals("commonly-mispronounced", word.type)
            // The key is absent in the response; it must land as null, not crash.
            assertNull(word.correctVersions)
            assertTrue(!word.hasUsageExamples)
        }
    }

    @Test
    fun `parasite words expose their usage examples`() = runTest {
        val page = load(source(WordType.PARASITE), null)
        val withVersions = page.data.filter { it.hasUsageExamples }

        assertTrue("parasite rows should carry correctVersions", withVersions.isNotEmpty())
        val version = withVersions.first().correctVersions!!.first()
        assertNotNull(version.word)
    }

    @Test
    fun `a short final page ends pagination`() = runTest {
        val total = backend.total("parasite")
        val lastPage = total / PAGE_SIZE
        val source = source(WordType.PARASITE)

        val page = load(source, lastPage)
        assertTrue("last page should be short", page.data.size < PAGE_SIZE)
        assertNull(page.nextKey)
    }
}
