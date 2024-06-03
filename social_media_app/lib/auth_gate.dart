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
  final formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mode == AuthMode.register
          ? Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Social Media",
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
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.person_outlined),
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
                                icon: const Icon(Icons.email_outlined),
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
                                icon: const Icon(Icons.security_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                label: const Text('Password'),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                icon: const Icon(Icons.security_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                label: const Text('Confirm Password'),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),
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
          : Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(90),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Social Media",
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
                                icon: const Icon(Icons.email_outlined),
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
                                icon: const Icon(Icons.security_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                label: const Text('Password'),
                              ),
                              obscureText: true,
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("Forgot Password?",
                                    style: TextStyle(color: Colors.grey))
                              ],
                            ),
                            const SizedBox(height: 20),
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
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      if (context.mounted) {
        Navigator.pop(context);
      };
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      messageError(e.code, context);
    }
  }

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
        if (formKey.currentState!.validate()) {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        messageError(e.code, context);
      }
    }
  }
}

void messageError(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(message),
          ));
}
