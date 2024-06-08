import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreDB {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts =
      FirebaseFirestore.instance.collection("Posts");

  Future<DocumentReference<Object?>> createPost(String message,[XFile? image]) async {
    String imageUrl = '';
    if (image != null) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('${user!.email}-${Timestamp.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot downloadUrl = await uploadTask;
      imageUrl = await downloadUrl.ref.getDownloadURL();
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.email)
        .get();

    String userName = userDoc['username'];

    return posts.add({
      'userEmail': user!.email,
      'userName': userName,
      'postMessage': message,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
      'Likes': [],
    });
  }

  Future<void> updatePost(String postId, String newMessage,
      [XFile? image]) async {
    String imageUrl = '';
    if (image != null) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child('${user!.email}-${Timestamp.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot downloadUrl = await uploadTask;
      imageUrl = await downloadUrl.ref.getDownloadURL();
    }

    final postData = {
      'postMessage': newMessage,
      'timestamp': Timestamp.now(),
    };

    if (imageUrl.isNotEmpty) {
      postData['imageUrl'] = imageUrl;
    }

    await posts.doc(postId).update(postData);
  }

  Future<void> deletePost(String postId) async {
    await posts.doc(postId).delete();
  }

  Future<void> toggleLike(DocumentSnapshot post) async {
    String userEmail = user!.email!;
    List<dynamic> likes = post['Likes'];
    if (likes.contains(userEmail)) {
      likes.remove(userEmail);
    } else {
      likes.add(userEmail);
    }
    await post.reference.update({'Likes': likes});
  }

  Stream<QuerySnapshot> getPostsStream() {
    final postStream = FirebaseFirestore.instance
        .collection("Posts")
        .orderBy('timestamp', descending: true)
        .snapshots();
    return postStream;
  }

  Stream<QuerySnapshot> getPostsByEmail(String email) {
    final postStream = FirebaseFirestore.instance
        .collection("Posts")
        .where('userEmail', isEqualTo: email)
        .orderBy('timestamp', descending: true)
        .snapshots();
    return postStream;
  }
}
