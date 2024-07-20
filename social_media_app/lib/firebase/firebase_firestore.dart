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
  final CollectionReference users =
      FirebaseFirestore.instance.collection("Users");

  //Phương thức tạo bài đăng
  Future<DocumentReference<Object?>> createPost(String message,
      [XFile? image]) async {
    String imageUrl = '';
    if (image != null) {
      final Reference storageRef = FirebaseStorage
          .instance //tham chiếu đến vị trí lưu ảnh trong Fisebase Storage
          .ref()
          .child('posts')
          .child(
              '${user!.email}-${Timestamp.now().millisecondsSinceEpoch}'); //mili giây tính từ Epoch (01-01-1970 00:00:00 UTC)
      final UploadTask uploadTask = storageRef.putFile(File(image.path));
      final TaskSnapshot downloadUrl = await uploadTask; //lấy thông tin tham chiếu đến tệp đã tải lên
      imageUrl = await downloadUrl.ref.getDownloadURL();
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.email)
        .get();

    String userName = userDoc['username'];
    String avatarUrl = userDoc['avatarUrl'];

    return posts.add({
      'userEmail': user!.email,
      'userName': userName,
      'avatarUrl': avatarUrl,
      'postMessage': message,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.now(),
      'Likes': [],
    });
  }

  //Phương thức cập nhật thông tin người dùng
  Future<void> updateUserProfile(String newUserName, XFile? newAvatar) async {
    String avatarUrl = '';

    if (newAvatar != null) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${user!.email}-${Timestamp.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageRef.putFile(File(newAvatar.path));
      final TaskSnapshot downloadUrl = await uploadTask;
      avatarUrl = await downloadUrl.ref.getDownloadURL();

      // Delete old avatar if exists
      DocumentSnapshot userSnapshot = await users.doc(user!.email).get();
      String oldAvatarUrl = userSnapshot['avatarUrl'] ?? '';
      if (oldAvatarUrl.isNotEmpty) {
        Reference oldAvatarRef =
            FirebaseStorage.instance.refFromURL(oldAvatarUrl);
        await oldAvatarRef.delete();
      }
    }

    final updateUserInfo = {
      'username': newUserName,
    };

    if (avatarUrl.isNotEmpty) {
      updateUserInfo['avatarUrl'] = avatarUrl;
    }

    await users.doc(user!.email).update(updateUserInfo);

    await _updateUsernameInPosts(newUserName);
    await _updateUsernameInComments(newUserName);
    await _updateAvatarInComments(avatarUrl);
    await _updateAvatarInPosts(avatarUrl);
  }

  Future<void> _updateUsernameInPosts(String newUserName) async {
    QuerySnapshot userPosts = await posts.where('userEmail', isEqualTo: user!.email).get();
    for (var post in userPosts.docs) {
      await post.reference.update({'userName': newUserName});
    }
  }

  Future<void> _updateUsernameInComments(String newUserName) async {
    QuerySnapshot userPosts = await posts.get();
    for (var post in userPosts.docs) {
      QuerySnapshot comments = await post.reference.collection('Comments').where('userEmail', isEqualTo: user!.email).get();
      for (var comment in comments.docs) {
        await comment.reference.update({'userName': newUserName});
      }
    }
  }

  Future<void> _updateAvatarInPosts(String newAvatarURL) async {
    QuerySnapshot userPosts = await posts.where('userEmail', isEqualTo: user!.email).get();
    for (var post in userPosts.docs) {
      await post.reference.update({'avatarUrl': newAvatarURL});
    }
  }

  Future<void> _updateAvatarInComments(String newAvatarURL) async {
    QuerySnapshot userPosts = await posts.get();
    for (var post in userPosts.docs) {
      QuerySnapshot comments = await post.reference.collection('Comments').where('userEmail', isEqualTo: user!.email).get();
      for (var comment in comments.docs) {
        await comment.reference.update({'avatarUrl': newAvatarURL});
      }
    }
  }

  //Phương thức cập nhật bài đăng
  Future<void> updatePost(String postId, String newMessage,
      [XFile? image]) async {
    String imageUrl = '';
    if (image != null) {
      // Delete old image if exists
      DocumentSnapshot postSnapshot = await posts.doc(postId).get();
      String oldImageUrl = postSnapshot['imageUrl'];
      if (oldImageUrl.isNotEmpty) {
        Reference oldImageRef =
            FirebaseStorage.instance.refFromURL(oldImageUrl);
        await oldImageRef.delete();
      }

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
    DocumentSnapshot postSnapshot = await posts.doc(postId).get();
    String imageUrl = postSnapshot['imageUrl'];

    if (imageUrl.isNotEmpty) {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();
    }

    // Get the comments collection reference for the post
    CollectionReference comments = posts.doc(postId).collection('Comments');

    // Delete all comments
    QuerySnapshot commentsSnapshot = await posts.doc(postId).collection('Comments').get();
    for (var doc in commentsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the post
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

  //Phương thức thêm comment
  Future<void> addComment(String postId, String comment) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user!.email)
        .get();

    String userName = userDoc['username'];
    String avatarUrl = userDoc['avatarUrl'];

    final cmt = {
      'userEmail': user!.email,
      'userName': userName,
      'comment': comment,
      'avatarUrl': avatarUrl,
      'timestamp': Timestamp.now(),
    };

    await posts.doc(postId).collection('Comments').add(cmt);
  }

  // Phương thức lấy các comments của một bài post
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return posts
        .doc(postId)
        .collection('Comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
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
