import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDB {
  User? user = FirebaseAuth.instance.currentUser;

  final CollectionReference posts =
  FirebaseFirestore.instance.collection("Posts");

  Future<DocumentReference<Object?>> createPost(String message) async {
    // Lấy thông tin người dùng từ collection "Users"
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.email)
        .get();

    String userName = userDoc['username'];

    return posts.add({
      'userEmail': user!.email,
      'userName': userName,
      'postMessage': message,
      'timestamp': Timestamp.now(),
      'Likes': [],
    });
  }

  Future<void> toggleLike(DocumentSnapshot post) async {
    String userEmail = user!.email!;
    List<dynamic> likes = post['Likes'];
    if (likes.contains(userEmail)) {
      // Nếu user đã like bài post này, remove like
      likes.remove(userEmail);
    } else {
      // Nếu user chưa like bài post này, add like
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

  Future<void> updatePost(String postId, String newMessage) async {
    await posts.doc(postId).update({
      'postMessage': newMessage,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> deletePost(String postId) async{
    await posts.doc(postId).delete();
  }
}
