// lib/models/article_model.dart

class Article {
  final String title;
  final String? description;
  final String? urlToImage;
  final String url;
  final String sourceName;
  final DateTime publishedAt;

  Article({
    required this.title,
    this.description,
    this.urlToImage,
    required this.url,
    required this.sourceName,
    required this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // --- LOGIKA BARU UNTUK GAMBAR DAN DESKRIPSI ---

    String? imageUrl;
    String? descriptionText;

    // 1. Coba ambil gambar dari 'thumbnail' terlebih dahulu.
    if (json['thumbnail'] != null && (json['thumbnail'] as String).isNotEmpty) {
      imageUrl = json['thumbnail'];
    }

    // 2. Ambil deskripsi dari 'description' dan bersihkan dari tag HTML.
    // Ini juga akan kita gunakan untuk mencari gambar jika 'thumbnail' kosong.
    if (json['description'] != null) {
      String descriptionHtml = json['description'];

      // Jika imageUrl masih kosong, coba cari di dalam tag <img>
      if (imageUrl == null) {
        final regExp = RegExp(r'<img[^>]+src="([^">]+)"');
        final match = regExp.firstMatch(descriptionHtml);
        imageUrl = match?.group(1); // Mengambil URL dari atribut src
      }

      // Bersihkan deskripsi dari semua tag HTML untuk ditampilkan sebagai teks biasa.
      descriptionText = descriptionHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    }

    // --- AKHIR LOGIKA BARU ---

    return Article(
      title: json['title'] ?? 'Tanpa Judul',
      description: descriptionText,
      urlToImage: imageUrl, // Gunakan imageUrl yang sudah kita proses
      url: json['link'] ?? '',
      sourceName: json['author'] ?? 'CNN Indonesia',
      publishedAt: DateTime.tryParse(json['pubDate'] ?? '') ?? DateTime.now(),
    );
  }
}