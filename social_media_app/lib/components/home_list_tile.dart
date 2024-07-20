import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../firebase/firebase_firestore.dart';
import '../components/image_full_screen.dart';
import '../components/comment.dart';

class HomeListTile extends StatelessWidget {
  final String message;
  final String userName;
  final String formattedTime;
  final String imageUrl;
  final String avatarUrl;
  final bool isLiked;
  final List<dynamic> likes;
  final DocumentSnapshot post;
  final FirestoreDB firestoreDB;

  const HomeListTile({
    super.key,
    required this.message,
    required this.userName,
    required this.formattedTime,
    required this.imageUrl,
    required this.avatarUrl,
    required this.likes,
    required this.isLiked,
    required this.post,
    required this.firestoreDB,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(message),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageFullScreen(imageUrl: imageUrl),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 0, top: 10, right: 0, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: FadeInImage.assetNetwork(
                        placeholder: "assets/gifs/Loading.gif",
                        image: imageUrl,
                        fadeInDuration: const Duration(milliseconds: 500),
                        imageErrorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          avatarUrl.isNotEmpty ?
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 24,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(avatarUrl),
                                radius: 23,
                              ),
                            )
                          : const CircleAvatar(
                            backgroundColor: Colors.black,
                            radius: 24,
                            child: CircleAvatar(
                              backgroundColor: Color(0xffE6E6E6),
                              radius: 23,
                              child: Icon(
                                Icons.person,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              firestoreDB.toggleLike(post);
                            },
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                          Text(
                            '${likes.length}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showCommentsModalBottomSheet(context, post.id, firestoreDB);
                            },
                            child: const Icon(Icons.mode_comment_outlined),
                          ),
                          StreamBuilder(
                            stream: firestoreDB.getCommentsStream(post.id),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  '${snapshot.data!.docs.length}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                );
                              } else {
                                return const Text(
                                  '0',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showCommentsModalBottomSheet(BuildContext context, String postId, FirestoreDB firestoreDB) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return CommentsModalBottomSheet(postId: postId, firestoreDB: firestoreDB);
    },
  );
}


