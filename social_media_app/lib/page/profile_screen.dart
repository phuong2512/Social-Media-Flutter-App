import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/firebase/firebase_firestore.dart';
import 'package:social_media_app/components/edit_profile.dart';

import '../components/profile_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final FirestoreDB firestoreDB = FirestoreDB();

  // Lấy thông tin người dùng từ Firebase
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
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
        title: const Text("My Profile", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              _showEditProfileBottomSheet(context);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
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

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 25.0)),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(90)),
                      child: ClipOval(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: user!['avatarUrl'] != null &&
                              user['avatarUrl'].isNotEmpty
                              ? Center(
                            child: Image.network(
                              user['avatarUrl'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Center(
                            child: Icon(
                              Icons.person,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user['username'],
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
                    StreamBuilder<QuerySnapshot>(
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
                                    child: const Text(
                                      " Post something!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
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

                              DateTime dateTime =
                              (post['timestamp'] as Timestamp).toDate();
                              String formattedTime =
                              DateFormat('HH:mm  |  dd-MM-yyyy')
                                  .format(dateTime);

                              List<dynamic> likes = post['Likes'];
                              bool isLiked = likes.contains(
                                  FirebaseAuth.instance.currentUser!.email);
                              String imageUrl = post['imageUrl'];

                              return ProfileListTile(
                                message: message,
                                formattedTime: formattedTime,
                                imageUrl: imageUrl,
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
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }

  void _showEditProfileBottomSheet(BuildContext context) {
    getUserDetails().then((snapshot) {
      Map<String, dynamic>? user = snapshot.data();
      String? currentAvatarUrl = user?['avatarUrl'];
      String currentUsername = user?['username'];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: EditProfile(
              currentUsername: currentUsername,
              currentAvatarUrl: currentAvatarUrl,
              onSave: (newUsername, newAvatar) async {
                await firestoreDB.updateUserProfile(newUsername, newAvatar);
                _refresh();
              },
            ),
          );
        },
      );
    });
  }
}
