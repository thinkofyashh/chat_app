import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'dart:io';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogin = true;
  final form = GlobalKey<FormState>();

  var enteredemail = '';
  var enteredpassword = '';
  File? selectedimage;

  void submit() async {
    final isValid = form.currentState!.validate();
    if (!isValid || !isLogin && selectedimage == null) {
      return;
    }
    form.currentState!.save();
    if (isLogin) {
      // log user in
      try {
        final usercredentials = await firebase.signInWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
      } on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication Failed')));
      }
    } else {
      // sign up mode
      try {
        final usercredentials = await firebase.createUserWithEmailAndPassword(
            email: enteredemail, password: enteredpassword);
        final storageref = FirebaseStorage.instance
            .ref()
            .child("user_image")
            .child('${usercredentials.user!.uid}.jpg');

        storageref.putFile(selectedimage!);
        final imageurl=await storageref.getDownloadURL();
        print(imageurl);

      } on FirebaseAuthException catch (error) {
        // you can specifically handle each other
        if (error.code == 'email-already-in-use') {
          // . .. . ... .
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication Failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Image.asset(
            "assets/images/plant.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 30, bottom: 20, left: 20, right: 20),
                    width: 200,
                    child: Image.asset('assets/images/chat.png'),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isLogin)
                                UserImagePicker(
                                  onPickimage: (pickedimage) {
                                    selectedimage = pickedimage;
                                  },
                                ), // Display UserImagePicker when !isLogin
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "Email Address"),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                onSaved: (value) {
                                  enteredemail = value!;
                                },
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !value.contains("@")) {
                                    return "Enter a valid Email Address";
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: "Password"),
                                keyboardType: TextInputType.text,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return "Password must be at least 6 characters long.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  enteredpassword = value!;
                                },
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).primaryColorLight),
                                  child: Text(isLogin ? "Login" : "Sign up")),
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLogin = !isLogin;
                                    });
                                  },
                                  child: Text(isLogin
                                      ? "Create an Account"
                                      : "I Already have an Account"))
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
