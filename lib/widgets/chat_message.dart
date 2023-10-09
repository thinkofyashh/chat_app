import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy('createdAt', descending: true)
            .snapshots(),
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
              padding: const EdgeInsets.only(left: 13, right: 13, bottom: 40),
              itemCount: loadedmessages.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                // this data() will connect us to all the meta data the loaded messsages has
                // to hold the data of current message
                final chatmessages = loadedmessages[index].data();
                // it hold the data of next message if any
                final nextchatmessage = index + 1 < loadedmessages.length
                    ? loadedmessages[index + 1].data()
                    : null;

                final currentmessageuserid = chatmessages['userId'];
                final nextmessageuserid =
                    nextchatmessage != null ? nextchatmessage['userId'] : null;
                // checks if the currentmessage and next message is send by the same user or not
                final nextUserIsSame =
                    nextmessageuserid == currentmessageuserid;
                // if this is true means it state that we have an ongoing sequence of message by the same user
                if (nextUserIsSame) {
                  // message will show the text messsage by the user and isMe will identify if the user who is  logged in and the currentmessageuserid(who messaged currently) is same or not
                  return MessageBubble.next(
                      message: chatmessages['text'],
                      isMe: authenticatedUser.uid == currentmessageuserid);
                } else {
                  // if the user is not same
                  return MessageBubble.first(
                      userImage: chatmessages['userimage'],
                      username: chatmessages['username'],
                      message: chatmessages['text'],
                      isMe: authenticatedUser.uid == currentmessageuserid);
                }
              });
        });
    // return const Center(child: Text("No New Messages."),);
  }
}
