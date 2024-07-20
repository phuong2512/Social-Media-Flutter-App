import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthMode { login, register }

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  var mode = AuthMode.login;

  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>(); //Khóa quản lý trạng thái của Form
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Kiểm tra chế độ
      body: mode == AuthMode.register

          //Register
          ? Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Icon(
                        Icons.camera,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Chill and Share",
                      style: TextStyle(fontSize: 20),
                    ),

                    //form register
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),

                            //username
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                label: const Text('Username'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 10),

                            //email
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                label: const Text('Email'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 10),

                            //password
                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                label: const Text('Password'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),

                            //confirm password
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                label: const Text('Confirm Password'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),

                            //button register
                            GestureDetector(
                                onTap: () {
                                  register();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: const Center(
                                      child: Text("Sign up",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          )),
                                    ))),

                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Already have account? "),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      mode = AuthMode.login;
                                    });
                                  },
                                  child: const Text("Login here",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )

          //login
          : Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Icon(
                        Icons.camera,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Chill and Share",
                      style: TextStyle(fontSize: 20),
                    ),

                    //form login
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const SizedBox(height: 25),

                            //email
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                label: const Text('Email'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 10),

                            //password
                            TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                label: const Text('Password'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),

                            const SizedBox(height: 20),

                            //buton login
                            GestureDetector(
                                onTap: () {
                                  login();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: const Center(
                                      child: Text("Login",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          )),
                                    ))),

                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have any account? "),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      mode = AuthMode.register;
                                    });
                                  },
                                  child: const Text("Register here",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // Phương thức login
  Future<void> login() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      if (formKey.currentState!.validate()) {
        //Kiểm tra các trường nhập hợp lệ hay không
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      if (mounted) {
        // Kiểm tra widget còn nằm trong cây không
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      //Bắt lấy lỗi do FirebaseAuthException ném ra
      if (mounted) {
        Navigator.pop(context);
        messageError(e.code, context);
      }
    }
  }

  //Phương thức register
  Future<void> register() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);

      messageError("Password doesn't match!", context);
    } else {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      try {
        //Tạo user
        if (formKey.currentState!.validate()) {
          //Kiểm tra các trường nhập hợp lệ hay không
          UserCredential? userCredential =
              await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          //Thêm user vào firestore
          addUserFirestore(userCredential);

          if (mounted) Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          Navigator.pop(context);
          messageError(e.code, context);
        }
      }
    }
  }

  //Phương thức thêm user vào Firestore
  Future<void> addUserFirestore(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'username': userController.text,
        'avatarUrl': "",
      });
    }
  }
}

//Hàm thông báo lỗi
void messageError(String error, BuildContext context) {
  String errorMessage = error;
  if (error == "invalid-email") {
    errorMessage = "The email you entered is not valid";
  } else if (error == 'invalid-credential') {
    errorMessage = "Wrong password or email";
  } else if (error == 'weak-password') {
    errorMessage = 'Try a stronger password';
  } else if (error == 'email-already-in-use') {
    errorMessage = 'The email is already in use';
  }
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(errorMessage),
          ));
}
