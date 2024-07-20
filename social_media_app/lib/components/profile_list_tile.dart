import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../firebase/firebase_firestore.dart';
import 'comment.dart';
import 'image_full_screen.dart';

class ProfileListTile extends StatefulWidget {
  final String message;
  final String formattedTime;
  final String imageUrl;
  final bool isLiked;
  final List<dynamic> likes;
  final DocumentSnapshot post;
  final FirestoreDB firestoreDB;

  const ProfileListTile({
    super.key,
    required this.message,
    required this.formattedTime,
    required this.imageUrl,
    required this.likes,
    required this.isLiked,
    required this.post,
    required this.firestoreDB,
  });

  @override
  State<ProfileListTile> createState() => _ProfileListTileState();
}

class _ProfileListTileState extends State<ProfileListTile> {
  XFile? _updatedImage;

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
          title: Text(widget.message),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageFullScreen(imageUrl: widget.imageUrl),
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
                        image: widget.imageUrl,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.formattedTime,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          widget.firestoreDB.toggleLike(widget.post);
                        },
                        child: Icon(
                          widget.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isLiked ? Colors.red : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Text(
                        '${widget.likes.length}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          _showCommentsModalBottomSheet(context, widget.post.id, widget.firestoreDB);
                        },
                        child: const Icon(Icons.mode_comment_outlined),
                      ),
                      const SizedBox(width: 1),
                      StreamBuilder(
                        stream: widget.firestoreDB.getCommentsStream(widget.post.id),
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
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          updatePostDialog(context, widget.post);
                        },
                        child: const Icon(Icons.create),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          deletePostDialog(context, widget.post);
                        },
                        child: const Icon(Icons.delete),
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

  //Hộp thoại update
  void updatePostDialog(BuildContext context, DocumentSnapshot post) {
    final updatePostController = TextEditingController();
    updatePostController.text = post['postMessage'];
    String existingImageUrl = post['imageUrl'];

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
                        hintText: 'Write something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (existingImageUrl.isNotEmpty)
                      Stack(
                        children: [
                          Image.network(existingImageUrl),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  existingImageUrl = '';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    if (_updatedImage != null)
                      Stack(
                        children: [
                          Image.file(File(_updatedImage!.path)),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _updatedImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        XFile? newImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        setState(() {
                          _updatedImage = newImage;
                          existingImageUrl = '';
                        });
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Pick new image"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Update"),
                  onPressed: () {
                    widget.firestoreDB.updatePost(
                      post.id,
                      updatePostController.text,
                      _updatedImage,
                    );
                    _updatedImage = null;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Hộp thoại xác nhận delete
  void deletePostDialog(BuildContext context, DocumentSnapshot post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                widget.firestoreDB.deletePost(post.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
}
