import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../firebase/firebase_firestore.dart';

class CommentsModalBottomSheet extends StatefulWidget {
  final String postId;
  final FirestoreDB firestoreDB;

  const CommentsModalBottomSheet({
    super.key,
    required this.postId,
    required this.firestoreDB,
  });

  @override
  _CommentsModalBottomSheetState createState() =>
      _CommentsModalBottomSheetState();
}

class _CommentsModalBottomSheetState extends State<CommentsModalBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.95,
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: widget.firestoreDB.getCommentsStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No comments yet!"),
                  );
                } else {
                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      String userName = comment['userName'];
                      String avatarUrl = comment['avatarUrl'];
                      String commentText = comment['comment'];

                      DateTime dateTime =
                          (comment['timestamp'] as Timestamp).toDate();
                      String formattedTime =
                          DateFormat('HH:mm  |  dd-MM-yyyy').format(dateTime);

                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 5, top: 10, right: 5, bottom: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                                right: 10, left: 10, top: 0, bottom: 5),
                            title: Row(
                              children: [
                                avatarUrl.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundColor: Colors.black,
                                        radius: 24,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              const Color(0xffE6E6E6),
                                          backgroundImage:
                                              NetworkImage(avatarUrl),
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
                                const SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(formattedTime,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12))
                                  ],
                                ),
                              ],
                            ),

                            subtitle:

                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(commentText),
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
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              left: 10,
              right: 10,
              top: 10,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          String comment = _commentController.text;
                          if (comment.isNotEmpty) {
                            widget.firestoreDB
                                .addComment(widget.postId, comment);
                            _commentController.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
