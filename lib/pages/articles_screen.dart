import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rescuein/bloc/article/article_bloc.dart';
import 'package:rescuein/bloc/article/article_event.dart';
import 'package:rescuein/bloc/article/article_state.dart';
import 'package:rescuein/models/article_model.dart';
import 'package:rescuein/services/news_api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart' as theme;

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menyediakan ArticleBloc khusus untuk halaman ini
    return BlocProvider(
      create: (context) => ArticleBloc(NewsApiService())..add(FetchArticles()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Artikel Kesehatan'),
          backgroundColor: theme.whiteColor,
          foregroundColor: theme.textPrimaryColor,
          elevation: 1,
        ),
        body: BlocBuilder<ArticleBloc, ArticleState>(
          builder: (context, state) {
            // Tampilkan loading indicator saat data diambil
            if (state is ArticleLoading || state is ArticleInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            // Tampilkan daftar artikel jika berhasil
            else if (state is ArticleLoaded) {
              if (state.articles.isEmpty) {
                return const Center(child: Text('Tidak ada artikel ditemukan.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.articles.length,
                itemBuilder: (context, index) {
                  final article = state.articles[index];
                  return _buildArticleCard(context, article);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              );
            }
            // Tampilkan pesan error jika gagal
            else if (state is ArticleError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Gagal memuat artikel:\n${state.message}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Widget ini kita salin dari HomeScreen untuk konsistensi UI
  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: theme.mediumRadius),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: theme.mediumRadius,
        onTap: () => _launchURL(article.url),
        child: Padding(
          padding: const EdgeInsets.all(theme.AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: theme.smallRadius,
                child: article.urlToImage != null
                    ? Image.network(
                        article.urlToImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: theme.backgroundLight,
                          child: Icon(Icons.broken_image, color: theme.textTertiaryColor),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: theme.backgroundLight,
                        child: Icon(Icons.image_not_supported_outlined, color: theme.textTertiaryColor),
                      ),
              ),
              const SizedBox(width: theme.AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: theme.modernBlackTextStyle.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: theme.AppSpacing.sm),
                    Text(
                      article.sourceName,
                      style: theme.bodySmallTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function untuk membuka URL artikel
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Di Flutter versi baru, tidak perlu `use_build_context_synchronously`
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Tidak dapat membuka link: $url')),
      // );
    }
  }
}