import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  void _submitAuthForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userEmail', _emailController.text.trim());
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')),
        );
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAuthForm,
                child: const Text('Sign In'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Implement forgot password functionality
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              SignInButton(
                Buttons.Google,
                text: "Sign in with Google",
                onPressed: () {
                  // Implement Google Sign In
                },
              ),
              SignInButton(
                Buttons.Facebook,
                text: "Sign in with Facebook",
                onPressed: () {
                  // Implement Facebook Sign In
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text('Create an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
