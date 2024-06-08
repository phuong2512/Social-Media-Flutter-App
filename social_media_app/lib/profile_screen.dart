import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'firebase_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final FirestoreDB firestoreDB = FirestoreDB();

  XFile? _updatedImage;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  void updatePostDialog(BuildContext context, DocumentSnapshot post) {
    final updatePostController = TextEditingController();
    updatePostController.text = post['postMessage'];
    String? existingImageUrl = post['imageUrl'];

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Edit your post"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: updatePostController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Edit your post...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 10),
                      if (existingImageUrl != null &&
                          existingImageUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/gifs/Loading.gif",
                            image: existingImageUrl!,
                            fadeInDuration: const Duration(milliseconds: 500),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                color: Colors.red,
                              );
                            },
                          ),
                        ),

                      ElevatedButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _updatedImage = pickedFile;
                              existingImageUrl = '';
                            });
                          }
                        },
                        child: const Text("Update Image"),
                      ),
                      if (_updatedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Image.file(File(_updatedImage!.path)),
                        ),
                    ],
                  ),
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
                      firestoreDB.updatePost(
                          post.id, updatePostController.text, _updatedImage);
                      Navigator.of(context).pop();
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            },
          );
        });
  }

  void deletePostDialog(BuildContext context, DocumentSnapshot post) {
    String? existingImageUrl = post['imageUrl'];

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete your post"),
            content: SingleChildScrollView(
              child:
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Are you sure you want to delete this post? 😢"),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(post['postMessage'])),
                    const SizedBox(
                      height: 10,
                    ),
                    if (existingImageUrl != null && existingImageUrl.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 10.0),
                        child: FadeInImage.assetNetwork(
                          placeholder:
                          "assets/gifs/Loading.gif",
                          image: existingImageUrl,
                          fadeInDuration: const Duration(
                              milliseconds: 500),
                          imageErrorBuilder:
                              (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              color: Colors.red,
                            );
                          },
                        ),
                      ),
                  ],
                ),
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
                  firestoreDB.deletePost(post.id);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: const Text('Delete post successfully!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        margin: EdgeInsets.only(
                        right: 30,
                        left: 30,
                        bottom: MediaQuery.of(context).size.height - 150),
                      )
                  );
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
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("No new posts!"),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(" Post something!", style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          final posts = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              String message = post['postMessage'];

                              DateTime dateTime =
                                  (post['timestamp'] as Timestamp).toDate();
                              String formattedTime =
                                  DateFormat('HH:mm  |  dd-MM-yyyy')
                                      .format(dateTime);

                              List<dynamic> likes = post['Likes'];
                              bool isLiked = likes.contains(
                                  FirebaseAuth.instance.currentUser!.email);
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (imageUrl != null &&
                                            imageUrl.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0, bottom: 10.0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  "assets/gifs/Loading.gif",
                                              image: imageUrl,
                                              fadeInDuration: const Duration(
                                                  milliseconds: 500),
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
                                          formattedTime,
                                          style: const TextStyle(
                                              color: Colors.grey),
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
                                              color: Colors.grey),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: () {
                                            updatePostDialog(context, post);
                                          },
                                          child: const Icon(Icons.create),
                                        ),
                                        const SizedBox(width: 3),
                                        GestureDetector(
                                          onTap: () {
                                            deletePostDialog(context, post);
                                          },
                                          child: const Icon(Icons.delete),
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
