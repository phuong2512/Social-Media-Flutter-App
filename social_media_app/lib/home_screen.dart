import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white60,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home"),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
          ),
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
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("HOME"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    leading: const Icon(Icons.person),
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
                leading: const Icon(Icons.logout),
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
                      hintText: "Tell us what you are feeling ...",
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
                ),
              ],
            ),
          ),

          if (_selectedImage != null)
            Expanded(
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(17),
                  child: Image.file(
                    File(_selectedImage!.path),
                  ),
                ),
                
                Positioned(
                  top: -13,
                  right: -13,
                  child: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
                ),
              ]),
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

                      DateTime dateTime =
                          (post['timestamp'] as Timestamp).toDate();
                      String formattedTime =
                          DateFormat('HH:mm  |  dd-MM-yyyy').format(dateTime);

                      List<dynamic> likes = post['Likes'];
                      bool isLiked = likes
                          .contains(FirebaseAuth.instance.currentUser!.email);
                      String? imageUrl = post['imageUrl'];

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrl != null && imageUrl.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 10.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: "assets/gifs/Loading.gif",
                                      image: imageUrl,
                                      fadeInDuration:
                                          const Duration(milliseconds: 500),
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                        );
                                      },
                                    ),
                                  ),

                                Text(
                                  "Posted by: $userName",
                                  maxLines: 1,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
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
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        firestoreDB.toggleLike(post);
                                      },
                                      child: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
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
                                const SizedBox(width: 4,),

                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () { },
                                      child: const Icon(
                                        Icons.mode_comment_outlined
                                      ),
                                    ),
                                    const Text(
                                      '0',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
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
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void postMessage() {
    if (postController.text.isNotEmpty) {
      String message = postController.text;
      firestoreDB.createPost(message, _selectedImage);

      postController.clear();
      setState(() {
        _selectedImage = null;
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  "Let us know how you're feeling before posting 😊",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),

                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Ok"),
                  ),
                ],
              ));
    }
  }
}
