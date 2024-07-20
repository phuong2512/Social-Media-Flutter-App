import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/components/drawer.dart';
import '../components/home_list_tile.dart';
import '../firebase/firebase_firestore.dart';
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

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text("Home", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined),
          ),
        ],
      ),

      drawer: const MyDrawer(),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
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
                          suffixIcon: IconButton(
                            onPressed: () {
                              postMessage();
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                          )),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(10),
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

            StreamBuilder(
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
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      String message = post['postMessage'];
                      String userName = post['userName'];
                      String avatarUrl = post['avatarUrl'];

                      DateTime dateTime =
                          (post['timestamp'] as Timestamp).toDate();
                      String formattedTime =
                          DateFormat('HH:mm  |  dd-MM-yyyy').format(dateTime);

                      List<dynamic> likes = post['Likes'];
                      bool isLiked = likes
                          .contains(FirebaseAuth.instance.currentUser!.email);
                      String imageUrl = post['imageUrl'];

                      return HomeListTile(
                        message: message,
                        userName: userName,
                        formattedTime: formattedTime,
                        imageUrl: imageUrl,
                        avatarUrl: avatarUrl,
                        likes: likes,
                        isLiked: isLiked,
                        post: post,
                        firestoreDB: firestoreDB,
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
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
