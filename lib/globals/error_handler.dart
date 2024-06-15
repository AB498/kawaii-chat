import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyErrorsHandler {
  void onErrorDetails(FlutterErrorDetails errorDetails) {
    print(errorDetails.exception);
    final stackTrace = errorDetails.toString();
    final filePattern = RegExp(r'(file:\/\/[^\s]+)');
    final matches = filePattern.allMatches(stackTrace);
    for (final match in matches) {
      final filePath = match.group(1);
      print('File: $filePath');
    }
    // final stackLines = errorDetails.stack.toString().split('\n');
    // print(stackLines.sublist(0, min(3, stackLines.length)).join('    \n'));
  }

  void onError(Object error, StackTrace stack) {
    print(error);
    final stackLines = stack.toString().split('\n');
    print(stackLines.sublist(0, min(3, stackLines.length)).join('\n'));
  }

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    print('Initialized Error Handler');
    return;
  }
}

class ErrorPresentation extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const ErrorPresentation({Key? key, required this.errorDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/');
            },
            child: Text('Error')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  errorDetails.toString().split('\n').sublist(0, min(30, errorDetails.toString().split('\n').length)).join('\n'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
