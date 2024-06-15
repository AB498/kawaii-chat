import 'package:riverpod/riverpod.dart';

final globalStateProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {'count': 1};
});
