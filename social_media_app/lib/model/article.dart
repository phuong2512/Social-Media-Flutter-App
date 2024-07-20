class Article {
  final String title;
  final String urlToImage;
  final String author;
  final String content;
  final String publishedAt;
  final String url;

  Article({
    required this.title,
    required this.urlToImage,
    required this.author,
    required this.content,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json["title"],
      urlToImage: json["urlToImage"],
      author: json["author"],
      content: json["content"],
      publishedAt: json["publishedAt"],
      url: json["url"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['urlToImage'] = urlToImage;
    data['author'] = author;
    data['content'] = content;
    data['publishedAt'] = publishedAt;
    data['url'] = url;
    return data;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': this.title,
      'urlToImage': this.urlToImage,
      'author': this.author,
      'content': this.content,
      'publishedAt': this.publishedAt,
      'url': this.url,
    };
  }

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      title: map['title'] as String,
      urlToImage: map['urlToImage'] as String,
      author: map['author'] as String,
      content: map['content'] as String,
      publishedAt: map['publishedAt'] as String,
      url: map['url'] as String,
    );
  }
//
}
