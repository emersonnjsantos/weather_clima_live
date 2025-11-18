class Article {
  final String? sourceName;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;

  Article({
    this.sourceName,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      sourceName: json['source'] != null ? json['source']['name'] : null,
      author: json['author'],
      title: json['title'] ?? 'Sem título',
      description: json['description'] ?? 'Sem descrição',
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt:
          DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      content: json['content'],
    );
  }
}
