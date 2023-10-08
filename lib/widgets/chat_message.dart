import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("chat").snapshots(),
        builder: (ctx, chatSnapshots) {
          // while we are in the loading state
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // when you have no message or when you have a doc but it is empty
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text("No New Messages."),
            );
          }
          // if we have somthing error
          if (chatSnapshots.hasError) {
            return const Center(
              child: Text("Something went wrong."),
            );
          }
          // will tell us about the lenght of the messages
          final loadedmessages = chatSnapshots.data!.docs;
          return ListView.builder(
              itemCount: loadedmessages.length,
              itemBuilder: (ctx, index) => Text(
                    loadedmessages[index].data()['text'],
                  ));
        });
    // return const Center(child: Text("No New Messages."),);
  }
}
