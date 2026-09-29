package kz.nu.duryssoile.data

import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.PagingData
import kotlinx.coroutines.flow.Flow

class WordRepository(private val api: OpenApi) {

    fun words(type: WordType, filter: String): Flow<PagingData<Word>> = Pager(
        config = PagingConfig(
            pageSize = PAGE_SIZE,
            initialLoadSize = PAGE_SIZE,
            prefetchDistance = PAGE_SIZE / 2,
            enablePlaceholders = false,
        ),
        pagingSourceFactory = { WordPagingSource(api, type, filter) },
    ).flow
}
