
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:kawaii_chat/globals/error.dart';

class SettingsScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var users = [];
    useEffect(() {
      (() async {
        users = (await FirebaseFirestore.instance.collection('users').get()).docs;
        print("Users: " + users.length.toString());
      })();
      return () => {print("Messages Page Unmount")};
    }, []);

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.blue, // appbar color.
        // foregroundColor: Colors.white, // appbar text color.
        automaticallyImplyLeading: false,
        title: Text('Settings'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
              child: Container(
                // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 40),
                    SizedBox(width: 10),
                    Expanded(child: Text('Sign out')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
