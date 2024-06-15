Future<void> safe(Function() fn) async {
  try {
    await fn();
  } catch (e) {
    print(e.toString().substring(0, 200));
  }
}
