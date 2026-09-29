package kz.nu.duryssoile.data

import androidx.paging.PagingSource
import androidx.paging.PagingState

const val PAGE_SIZE = 20

/**
 * Pages through /words. Keys are page indices starting at 0, matching the
 * backend's page-index `offset` semantics.
 */
class WordPagingSource(
    private val api: OpenApi,
    private val type: WordType,
    private val filter: String,
) : PagingSource<Int, Word>() {

    override fun getRefreshKey(state: PagingState<Int, Word>): Int? =
        state.anchorPosition?.let { anchor ->
            state.closestPageToPosition(anchor)?.prevKey?.plus(1)
                ?: state.closestPageToPosition(anchor)?.nextKey?.minus(1)
        }

    override suspend fun load(params: LoadParams<Int>): LoadResult<Int, Word> {
        val page = params.key ?: 0
        return try {
            val words = api.words(
                type = type.apiValue,
                offset = page,
                limit = params.loadSize.coerceAtMost(PAGE_SIZE),
                sort = "asc",
                filter = filter.ifBlank { null },
            )
            LoadResult.Page(
                data = words,
                prevKey = if (page == 0) null else page - 1,
                // A short page means the end; the v1 client only stopped on a
                // fully empty one, which cost an extra round trip every time.
                nextKey = if (words.size < PAGE_SIZE) null else page + 1,
            )
        } catch (e: Exception) {
            LoadResult.Error(e)
        }
    }
}
