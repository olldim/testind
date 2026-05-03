class News {
  final int id;
  final String title;
  final String description;
  final String content;
  final List<String> images;
  final List<NewsLink> links;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.images,
    required this.links,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      links: (json['links'] as List? ?? [])
          .map((link) => NewsLink.fromJson(link as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NewsLink {
  final String title;
  final String url;

  NewsLink({
    required this.title,
    required this.url,
  });

  factory NewsLink.fromJson(Map<String, dynamic> json) {
    return NewsLink(
      title: json['title'] as String,
      url: json['url'] as String,
    );
  }
}
