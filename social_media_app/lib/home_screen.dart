import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final postController = TextEditingController();
  final FirestoreDB firestoreDB = FirestoreDB();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home"),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.image_outlined))
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const DrawerHeader(
                    child: Icon(
                  Icons.camera,
                  size: 45,
                )),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.home,
                    ),
                    title: const Text("HOME"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: const Text("MY PROFILE"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile_screen');
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                ),
                title: const Text("LOGOUT"),
                onTap: () {
                  Navigator.pop(context);
                  logout();
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(23.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: postController,
                    decoration: InputDecoration(
                      hintText: "Tell us what are you feeling ...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    postMessage();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(19),
                    margin: const EdgeInsets.only(left: 10.0),
                    child: const Center(
                      child: Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: firestoreDB.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                          String userName = post['userName'];

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
                                      Text(
                                        "Posted by: " + userName,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.grey,
                                            fontSize: 12),
                                      ),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12),
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
                                      const SizedBox(width: 4),
                                      Text(
                                        '${likes.length} likes',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        });
                  }
                }),
          )
        ],
      ),
    );
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (postController.text.isNotEmpty) {
      String message = postController.text;
      firestoreDB.createPost(message);
    }

    postController.clear();
  }
}
