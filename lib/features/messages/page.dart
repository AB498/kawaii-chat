import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kawaii_chat/globals/error.dart';
import 'package:kawaii_chat/globals/utils.dart';
import 'package:kawaii_chat/globals/globalStateProvider.dart';

class MessagesScreen extends HookConsumerWidget {
  // final chatsProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  //   return FirebaseFirestore.instance.collection('chats').where('users', arrayContains: uid).snapshots();
  // });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.read(globalStateProvider);
    // print('got users');
    if (globalState['user'] == null) {
      print('no user');
      return Center(child: CircularProgressIndicator());
    }

    var chats = ref.watch(useState(StreamProvider.autoDispose<QuerySnapshot>((ref) {
      return FirebaseFirestore.instance.collection('chats').where('users', arrayContains: globalState['user']['uid']).snapshots();
    })).value);
    print('chats ${chats.asData?.value}');
    if (chats.hasError) {
      print('error ${chats.error}');
      return ErrorWidget(chats.error.toString());
    }
    if (!chats.hasValue) {
      print('no data');
      return Center(child: CircularProgressIndicator());
    }
    if (chats.asData!.value.docs.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Messages'),
        ),
        body: Center(
            child: Text(
          'No Chats',
          style: TextStyle(fontSize: 20),
        )),
      );
    }
    var chatsList = chats.asData!.value.docs.map((e) => e.data()).toList();

    void createChat(otherUser) {
      safe(() async {
        var participants = [globalState['user'], otherUser];
        print('participants');
        print(participants);
        participants.sort((a, b) => a['uid'].toString().compareTo(b['uid'].toString()));
        // Create a concatenated string of sorted user IDs
        var participantIds = participants.map((e) => e['uid']).toList();
        var concatenatedIds = participantIds.join('_');

        // Query Firestore for an existing chat with these user IDs
        var existingChat = (await FirebaseFirestore.instance.collection('chats').where('userIdsConcatenated', isEqualTo: concatenatedIds).get()).docs.firstOrNull;
        DocumentSnapshot chatRef;
        if (existingChat == null) {
          await FirebaseFirestore.instance.collection('chats').add({
            'type': 'direct', // DM | Group
            'users': participantIds,
            'userIdsConcatenated': concatenatedIds,
            'names': participants.map((e) => e['email']).toList()..sort(),
          });
          existingChat = (await FirebaseFirestore.instance.collection('chats').where('userIdsConcatenated', isEqualTo: concatenatedIds).get()).docs.firstOrNull;
        } else {
          print('existingChat');
        }
        chatRef = existingChat as DocumentSnapshot;
        context.push('/chat/${chatRef.id}');
      });
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Messages'),
        ),
        body: Container(
          child: chatsList == null
              ? SizedBox(
                  child: Center(child: CircularProgressIndicator()),
                  height: 50.0,
                  width: 50.0,
                )
              : SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: chatsList.map((dynamic e) {
                        return InkWell(
                          onTap: () async {
                            var otherUser = await FirebaseFirestore.instance.collection('users').doc(e['users'].where((element) => element != globalState['user']['uid']).first).get();
                            createChat(otherUser.data());
                          },
                          child: Container(
                              // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network('https://avatar.iran.liara.run/public?username=' + new Random().nextInt(100).toString(), width: 40, height: 40),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(child: Text(e['names'].where((element) => element != globalState['user']['email']).first)),
                                ],
                              )),
                        );
                      }).toList()),
                ),
        ));
  }
}
