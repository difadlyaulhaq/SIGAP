// lib/bloc/article/article_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/news_api_service.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final NewsApiService _newsApiService;

  // 1. Ganti constructor untuk menggunakan Bloc
  ArticleBloc(this._newsApiService) : super(ArticleInitial()) {
    // 2. Daftarkan event handler untuk merespons event FetchArticles
    on<FetchArticles>(_onFetchArticles);
  }

  // 3. Buat method handler yang akan dieksekusi saat event diterima
  Future<void> _onFetchArticles(
    FetchArticles event,
    Emitter<ArticleState> emit,
  ) async {
    try {
      // Logika di dalamnya sama seperti Cubit Anda sebelumnya
      emit(ArticleLoading());
      final articles = await _newsApiService.fetchHealthArticles();

      if (!isClosed) {
        emit(ArticleLoaded(articles));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ArticleError(e.toString()));
      }
    }
  }
}