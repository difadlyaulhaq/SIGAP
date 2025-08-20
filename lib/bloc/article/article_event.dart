// lib/bloc/article/article_event.dart
import 'package:equatable/equatable.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memberitahu BLoC agar mulai mengambil data artikel
class FetchArticles extends ArticleEvent {}