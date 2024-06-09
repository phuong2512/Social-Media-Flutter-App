import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreDB {
  User? user = FirebaseAuth.instance.currentUser;

  //tham chiếu collection
  final CollectionReference posts =
      FirebaseFirestore.instance.collection("Posts");

  //Phương thức tạo bài đăng
  Future<DocumentReference<Object?>> createPost(String message,[XFile? image]) async {
    String imageUrl = '';
    if (image != null) {
      final Reference storageRef = FirebaseStorage.instance     //tham chiếu đến vị trí lưu ảnh trong Fisebase Storage
          .ref()                    
          .child('posts')
          .child('${user!.email}-${Timestamp.now().millisecondsSinceEpoch}');   //mili giây tính từ Epoch (01-01-1970 00:00:00 UTC)
      final UploadTask uploadTask = storageRef.putFile(File(image.path));       
      final TaskSnapshot downloadUrl = await uploadTask;            //lấy thông tin tham chiếu đến tệp đã tải lên
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

  //Phương thức cập nhật bài đăng
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

  //Phương thức xóa bài đăng
  Future<void> deletePost(String postId) async {
    await posts.doc(postId).delete();
  }

  //Phương thức cập nhật lượt thích
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

  //Phương thức lấy bài đăng từ Firestore
  Stream<QuerySnapshot> getPostsStream() {
    final postStream = FirebaseFirestore.instance
        .collection("Posts")
        .orderBy('timestamp', descending: true)
        .snapshots();
    return postStream;
  }

  //Phương thức lấy bài đăng từ Firestore theo email người dùng đăng nhập
  Stream<QuerySnapshot> getPostsByEmail(String email) {
    final postStream = FirebaseFirestore.instance
        .collection("Posts")
        .where('userEmail', isEqualTo: email)
        .orderBy('timestamp', descending: true)
        .snapshots();
    return postStream;
  }
}
