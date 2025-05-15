import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'task_list_screen.dart'; // Home screen after login

class LoginScreen extends StatelessWidget {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginScreen({super.key});

Future<void> _signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    print(" Google user: $googleUser");

    if (googleUser == null) {
      print(" Sign-in cancelled");
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print("Access Token: ${googleAuth.accessToken}");

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(" Firebase user: ${userCredential.user}");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => TaskListScreen()),
    );
  } catch (e, stack) {
    print(" Sign-in error: $e");
    print(stack);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login with Google")),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text("Sign in with Google"),
          onPressed: () => _signInWithGoogle(context),
        ),
      ),
    );
  }
}
