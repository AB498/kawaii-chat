import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AuthScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final authType = useState('login');
    return authType.value == 'login' ? LoginPage(authType) : RegisterPage(authType);
  }
}

class LoginPage extends HookWidget {
  ValueNotifier<String> authType;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage(this.authType);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ModernOutlinedInputField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ModernOutlinedInputField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                (() async {
                  try {
                    print({'email': _emailController.text, 'password': _passwordController.text});
                    var creds = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    print('Error: ${e.toString()}');
                  }
                })();
              },
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                authType.value = 'register';
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      print({'email': _emailController.text, 'password': _passwordController.text});
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }
}

class RegisterPage extends HookWidget {
  ValueNotifier<String> authType;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  RegisterPage(this.authType);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ModernOutlinedInputField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ModernOutlinedInputField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20),
            ModernOutlinedInputField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  print('Error: ${e.toString()}');
                }
              },
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () {
                authType.value = 'login';
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernOutlinedInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  const ModernOutlinedInputField({
    required this.controller,
    required this.label,
    this.hint = '',
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
