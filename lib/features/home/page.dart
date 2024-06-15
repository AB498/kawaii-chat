import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:kawaii_chat/features/chat/page.dart';
import 'package:kawaii_chat/globals/error.dart';
import 'package:kawaii_chat/features/discover/page.dart';
import 'package:kawaii_chat/features/messages/page.dart';
import 'package:kawaii_chat/features/settings/page.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // GoRoute(
    //   path: '/',
    //   builder: (context, state) => Text('Homem'),
    // ),
    GoRoute(
      path: '/chat/:chatId',
      pageBuilder: (context, state) {
        var chatId = state.pathParameters['chatId'];
        return NoTransitionPage(child: ChatScreen(chatId: chatId));
      },
    ),
    ShellRoute(builder: (context, state, child) => Container(child: child), routes: [
      ShellRoute(pageBuilder: (context, state, child) => NoTransitionPage(child: HomeNavigation(child: child)), routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(child: MessagesScreen()),
        ),
        GoRoute(
          path: '/messages',
          redirect: (BuildContext context, GoRouterState state) => '/',
        ),
        GoRoute(
          path: '/discover',
          pageBuilder: (context, state) {
            return NoTransitionPage(child: DiscoverScreen());
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(child: SettingsScreen()),
        )
      ])
    ]),
  ],
);

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    // only return the child without warping it with animations
    return child!;
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(elevation: 6, backgroundColor: Colors.blue, foregroundColor: Colors.white, shadowColor: Colors.black.withOpacity(.5)),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          for (final platform in TargetPlatform.values) platform: const NoTransitionsBuilder(),
        }),
      ),
      routerConfig: _router,
    );
  }
}

class HomeNavigation extends HookWidget {
  final child;

  HomeNavigation({this.child});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    useEffect(() {
      (() async {
        print("user");
        print('home page');
        if (!(await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get()).exists) {
          await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
            'name': FirebaseAuth.instance.currentUser!.displayName,
            'email': FirebaseAuth.instance.currentUser!.email,
            'id': FirebaseAuth.instance.currentUser!.uid,
            'image': FirebaseAuth.instance.currentUser!.photoURL,
          });
        }
      })();
      return null;
    }, []);

    var pageMap = {0: 'messages', 1: 'discover', 2: 'settings'};
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex.value,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: ("Messages"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: ("Discover"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: ("Settings"),
          )
        ],
        onTap: (int index) {
          selectedIndex.value = index;
          context.push('/${pageMap[index]}');
        },
      ),
    );
  }
}
