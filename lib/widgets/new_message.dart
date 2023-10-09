import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({Key? key}) : super(key: key);

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var messageController=TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    messageController.dispose();
    super.dispose();
  }

  void submitmessage()async{
    // reading the value from the controller
    final enteredvalue=messageController.text;
    // now we need to add a validator
    if(enteredvalue.trim().isEmpty){
      return;
    }

    FocusScope.of(context).unfocus();
    messageController.clear();

    //send to firebase
    final user=FirebaseAuth.instance.currentUser!;
    final  userdata=await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
    FirebaseFirestore.instance.collection("chat").add({
      'text':enteredvalue,
      'createdAt':Timestamp.now(),
      'userId':user.uid,
      'username':userdata.data()!['username'],
      'userimage':userdata.data()!['image_url'],

    });

    // once we press the on Pressed function the data needs to be clear on the variable it should not hold the value of previous text.
   // messageController.clear();


  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:const  EdgeInsets.only(left: 20, right: 10, bottom: 30),
      child: Row(
        children: [
           Expanded(
            child: TextField(
              controller:messageController ,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration:const  InputDecoration(labelText: "Send a Message."),
            ),
          ),
          IconButton(
            onPressed: submitmessage,
             icon:const  Icon(Icons.send_outlined),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
