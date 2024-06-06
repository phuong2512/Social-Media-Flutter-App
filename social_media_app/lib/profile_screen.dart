import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirestoreDB firestoreDB = FirestoreDB();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  void updatePostDiaglog(BuildContext context, DocumentSnapshot post) {
    final updatePostController = TextEditingController();
    updatePostController.text = post['postMessage'];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Edit your post"),
            content: TextFormField(
              controller: updatePostController,
              decoration: const InputDecoration(
                hintText: "Edit your post...",
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  firestoreDB.updatePost(post.id, updatePostController.text);
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
  }

  void dedleteDialog(BuildContext context, DocumentSnapshot post) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete your post"),
            content:
                const Text("Are you sure you want to delete this post? 😢"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  firestoreDB.deletePost(post.id);
                  Navigator.of(context).pop();
                },
                child: const Text("Delete"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("My Profile"),
        backgroundColor: Colors.cyan,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();

            return Center(
              child: Column(
                children: [
                  const Padding(padding: EdgeInsets.only(top: 25.0)),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.all(25),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user!['username'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user['email'],
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(
                    thickness: 1,
                    color: Colors.black,
                    indent: 100,
                    endIndent: 100,
                  ),
                  const Text(
                    "My posts",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: firestoreDB.getPostsByEmail(currentUser!.email!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No new posts! Post something!"),
                            ),
                          );
                        } else {
                          final posts = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              String message = post['postMessage'];

                              // Chuyển timestamp thành DateTime
                              DateTime dateTime =
                                  (post['timestamp'] as Timestamp).toDate();

                              // Định dạng DateTime thành chuỗi thời gian
                              String formattedTime =
                                  DateFormat('HH:mm  |  dd-MM-yyyy')
                                      .format(dateTime);

                              List<dynamic> likes = post['Likes'];
                              bool isLiked = likes.contains(
                                  FirebaseAuth.instance.currentUser!.email);

                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: ListTile(
                                    title: Text(message),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formattedTime,
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            firestoreDB.toggleLike(post);
                                          },
                                          child: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${likes.length}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: () {
                                            updatePostDiaglog(context, post);
                                          },
                                          child: const Icon(
                                            Icons.create,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: () {
                                            dedleteDialog(context, post);
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}
