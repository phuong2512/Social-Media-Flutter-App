import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../model/article.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _searchQuery = '';
  String _currentCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "News",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ngày tháng
              Text(
                DateFormat('EEE, dd\'th\' MMMM yyyy').format(DateTime.now()),
                style: GoogleFonts.tinos(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10,),
              // Input tìm kiếm
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search for article',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Thanh danh sách thể loại
              SizedBox(
                height: 40,
                child: CategoriesBar(onCategorySelected: _updateCategory),
              ),
              // Danh sách bài báo
              const SizedBox(height: 24),
              Expanded(
                  child: ArticleList(
                searchQuery: _searchQuery,
                category: _currentCategory,
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _updateCategory(String category) {
    setState(() {
      _currentCategory = category;
    });
  }
}

class CategoriesBar extends StatefulWidget {
  final Function(String) onCategorySelected;
  const CategoriesBar({super.key, required this.onCategorySelected});

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  List<String> categories = const [
    'All',
    'Science',
    'Sports',
    'Health',
    'Entertainment',
    'Technology',
    'Business'
  ];

  int currentCategory = 0;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              currentCategory = index;
            });
            String selectedCategory = categories.elementAt(index);
            widget.onCategorySelected(selectedCategory);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            decoration: BoxDecoration(
              color: currentCategory == index ? Colors.black : Colors.white,
              border: Border.all(),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Center(
              child: Text(
                categories.elementAt(index),
                style: TextStyle(
                  color: currentCategory == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ArticleList extends StatelessWidget {
  const ArticleList(
      {super.key, required this.searchQuery, required this.category});
  final String searchQuery;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getArticles(category),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              final List<Article> articles = snapshot.data ?? [];
              final filteredArticles = articles.where((article) {
                return article.title.toLowerCase().contains(searchQuery);
              }).toList();
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredArticles.length,
                itemBuilder: (context, index) {
                  return ArticleTile(
                    article: filteredArticles[index],
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<List<Article>> getArticles(String category) async {
    String url = 'https://newsapi.org/v2/top-headlines?country=us';
    if (category != 'All') {
      url += '&category=$category';
    }
    url += '&apiKey=219ec2779eae4d309d8f8049aad4603f'; //apikey is private
    final res = await http.get(Uri.parse(url));
    final body = json.decode(res.body) as Map<String, dynamic>;
    final List<Article> result = [];
    for (final article in body['articles']) {
      if (article['title'] != '[Removed]') {
        result.add(Article(
          title: article['title'],
          author: article['author'] ?? 'Unknown',
          urlToImage: article['urlToImage'] ??
              "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png",
          content: article['content'] ?? '',
          publishedAt: article['publishedAt'] ?? '',
          url: article['url'] ?? '',
        ));
      }
    }

    return result;
  }
}

class ArticleTile extends StatelessWidget {
  const ArticleTile({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ArticleDetail(article: article)));
        },
        child: Container(
          height: 128,
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  article.urlToImage,
                  fit: BoxFit.cover,
                  height: 128,
                  width: 128,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 128,
                      width: 128,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                                "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png")),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                  child: ListTile(
                title: Text(
                  article.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  "By ${article.author}",
                  style: const TextStyle(fontSize: 10),
                ),
                dense: true,
              )),
            ],
          ),
        ));
  }
}
