import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kawaii_chat/globals/error.dart';
import 'package:kawaii_chat/globals/error_handler.dart';
import 'package:kawaii_chat/features/auth/authService.dart';
import 'package:kawaii_chat/features/auth/page.dart';
import 'package:kawaii_chat/globals/utils.dart';
import 'package:kawaii_chat/firebase_options.dart';
import 'package:kawaii_chat/features/home/page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kawaii_chat/globals/globalStateProvider.dart';

Future<void> main() async {
  final myErrorsHandler = MyErrorsHandler();
  await myErrorsHandler.initialize();
  FlutterError.onError = (details) {
    // FlutterError.presentError(details);
    myErrorsHandler.onErrorDetails(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    myErrorsHandler.onError(error, stack);
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();
  await safe(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends HookConsumerWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final globalState = ref.read(globalStateProvider);

    // var stream = useState(FirebaseAuth.instance.authStateChanges()).value;
    final authState = ref.watch(firebaseAuthProvider);
    // final authState = useStream(useState(FirebaseAuth.instance.authStateChanges()).value);
    // print('authState $authState');
    print('authState ${authState.hasValue}');
    if (authState.hasError) return CustomErrorWidget(error: authState.error, stackTrace: authState.stackTrace);

    if (!authState.hasValue) return const Center(child: CircularProgressIndicator());

    dynamic user = authState.asData!.value;
    print('user $user');

    return authState.when(
        data: (data) {
          if (data == null)
            return MaterialApp(
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  appBarTheme: AppBarTheme(elevation: 6, backgroundColor: Colors.blue, foregroundColor: Colors.white, shadowColor: Colors.black.withOpacity(.5)),
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    for (final platform in TargetPlatform.values) platform: const NoTransitionsBuilder(),
                  }),
                ),
                home: AuthScreen());

          return FutureBuilder(future: (() async {
            if (user == null) return 2;
            await Future.microtask(() async {
              var existingUser = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
              if (!existingUser.exists) {
                await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                  'email': user.email,
                  'uid': user.uid,
                  'name': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous${Random().nextInt(1000)}',
                });
              }
              user = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
              ref.read(globalStateProvider.notifier).state = {...ref.read(globalStateProvider), 'user': user};
            });
            return 1;
          })(), builder: (context, snapshot) {
            print('setting user ${snapshot.data}');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return MaterialApp(home: HomeScreen());
          });
        },
        error: (error, stackTrace) => CustomErrorWidget(error: error, stackTrace: stackTrace),
        loading: () => const Center(child: CircularProgressIndicator()));

    return Consumer(
        builder: (context, ref, child) => FutureBuilder(future: (() async {
              if (user == null) return 2;
              await Future.microtask(() async {
                var existingUser = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
                if (!existingUser.exists) {
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                    'email': user.email,
                    'uid': user.uid,
                    'name': user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous${Random().nextInt(1000)}',
                  });
                }
                user = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                ref.read(globalStateProvider.notifier).state = {...ref.read(globalStateProvider), 'user': user};
              });
              return 1;
            })(), builder: (context, snapshot) {
              print('setting user ${snapshot.data}');
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              return MaterialApp(home: user != null ? HomeScreen() : AuthScreen());
            }));
  }
}
