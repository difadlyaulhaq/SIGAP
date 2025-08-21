// lib/services/news_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class NewsApiService {
  // Ganti URL dengan endpoint RSS-to-JSON
  final String _url = 'https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fwww.cnnindonesia.com%2Fgaya-hidup%2Frss';

  Future<List<Article>> fetchHealthArticles() async {
    print('Mencoba mengambil data dari: $_url');

    try {
      final response = await http.get(Uri.parse(_url));
      print('Status Kode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'ok') {
          // 'items' adalah key untuk daftar artikel di API ini
          final List articles = data['items'];
          return articles.map((json) => Article.fromJson(json)).toList();
        } else {
          throw Exception('Gagal memuat artikel: API status bukan ok');
        }
      } else {
        throw Exception('Gagal terhubung ke server: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi eror: $e');
      throw Exception('Gagal memuat artikel: $e');
    }
  }
} 