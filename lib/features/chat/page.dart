import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kawaii_chat/globals/error.dart';
import 'package:kawaii_chat/features/discover/page.dart';
import 'package:kawaii_chat/features/messages/page.dart';
import 'package:kawaii_chat/features/settings/page.dart';
import 'package:kawaii_chat/globals/globalStateProvider.dart';
import 'package:kawaii_chat/globals/utils.dart';

class ChatScreen extends HookConsumerWidget {
  var chatId;
  var messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatScreen({this.chatId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalState = ref.read(globalStateProvider);
    if (globalState['user'] == null) return Center(child: CircularProgressIndicator());

    var title = useState('');
    print('chat: $chatId');
    var messages = useStream(useMemoized(() => FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('time', descending: false).snapshots(), [chatId]));
    useEffect(() {
      Future.microtask(() {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }, [messages]);
    var chat = useStream(useMemoized(() => FirebaseFirestore.instance.collection('chats').doc(chatId).snapshots(), [chatId]));

    if (chat.hasError) return ErrorWidget(chat.error.toString());
    var chatData = chat.data?.data();
    if (chatData == null) return Center(child: CircularProgressIndicator());
    title.value = chatData['names'].where((element) => element != FirebaseAuth.instance.currentUser!.email).first;

    return Scaffold(
      appBar: AppBar(
        title: Text(title.value),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () async {
              print('more');
              // context.go('/messages');
            },
          )
        ],
      ),
      body: Column(
        children: [
          !messages.hasData
              ? Expanded(
                  child: SizedBox(
                    child: Center(child: CircularProgressIndicator()),
                    height: 50.0,
                    width: 50.0,
                  ),
                )
              : Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.data!.docs.length,
                        itemBuilder: (context, index) {
                          var self = messages.data!.docs[index]['senderEmail'] == globalState['user']['email'];
                          var time = formatTime((messages.data!.docs[index]['time'] as Timestamp).toDate()).toString();
                          var name = messages.data!.docs[index]['senderEmail'];
                          var align = self ? Alignment.topRight : Alignment.topLeft;
                          var alignColumn = self ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                          return Container(
                            margin: EdgeInsets.all(10.0),
                            alignment: align,
                            child: Column(
                              crossAxisAlignment: alignColumn,
                              children: [
                                Container(
                                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(self ? "$time • You" : "$name • $time", style: TextStyle(color: Colors.grey)),
                                  ]),
                                ),
                                SizedBox(height: 5.0),
                                Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.grey[200],
                                    ),
                                    padding: EdgeInsets.all(10.0),
                                    child: Text(messages.data!.docs[index]['text'])),
                              ],
                            ),
                          );
                        }),
                  ),
                ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  safe(() async {
                    var text = messageController.text;
                    messageController.clear();
                    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
                      'text': text,
                      'senderId': FirebaseAuth.instance.currentUser!.uid,
                      'senderEmail': FirebaseAuth.instance.currentUser!.email,
                      'time': Timestamp.now(),
                    });
                    print('sent');
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

String formatTime(DateTime dateTime) {
  // Extracting the hour and minute
  int hour = dateTime.hour;
  int minute = dateTime.minute;

  // Determine AM or PM
  String period = hour >= 12 ? 'PM' : 'AM';

  // Convert hour to 12-hour format
  hour = hour % 12;
  hour = hour == 0 ? 12 : hour; // Convert '0' hour to '12'

  // Formatting to a 2-digit string for minutes
  String minuteStr = minute.toString().padLeft(2, '0');

  // Creating the formatted time string with AM/PM
  return '$hour:$minuteStr $period';
}
