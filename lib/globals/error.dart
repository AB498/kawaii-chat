import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomErrorWidget extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;

  const CustomErrorWidget({super.key, this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              GoRouter.of(context).push('/');
            },
            child: const Text('Error')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  error.toString().split('\n').sublist(0, min(20, error.toString().split('\n').length)).join('\n'),
                  style: const TextStyle(
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
