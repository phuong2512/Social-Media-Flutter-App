import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/article.dart';

class ArticleDetail extends StatefulWidget {
  final Article article;

  const ArticleDetail({super.key, required this.article});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.green,
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200.0,
              width: double.infinity,
              decoration: BoxDecoration(
                //let's add the height

                image: DecorationImage(
                    image: NetworkImage(widget.article.urlToImage),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(widget.article.publishedAt,
                    style: const TextStyle(
                      color: Color.fromARGB(130, 50, 50, 50),
                      fontSize: 11,
                    )),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              widget.article.title,
              style: const TextStyle(
                fontSize: 18, // Kích thước của font chữ
                fontWeight: FontWeight
                    .bold, // Độ đậm của font chữ (có thể là normal, bold, ...)
                fontStyle:
                    FontStyle.normal, // Kiểu font chữ (normal hoặc italic)
                color: Colors.black, // Màu của font chữ
                letterSpacing: 1.5, // Khoảng cách giữa các ký tự
                wordSpacing: 2.0, // Khoảng cách giữa các từ
                fontFamily: 'Arial', // Font chữ cụ thể (nếu có)
              ),
            ),
            Text("By ${widget.article.author}",
                style: const TextStyle(
                  color: Color.fromARGB(130, 50, 50, 50),
                  fontSize: 11,
                )),
            const SizedBox(
              height: 15,
            ),
            Text(
              widget.article.content,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full article details: ',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),

                 InkWell(
                    onTap: () => launchUrl(Uri.parse(widget.article.url)),
                    child: Text(
                      widget.article.url,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
