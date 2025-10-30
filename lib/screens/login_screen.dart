import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_digidex_frontend/providers/auth_provider.dart';
import 'package:project_digidex_frontend/screens/profile_screen.dart';
import 'package:project_digidex_frontend/screens/register_screen.dart';

// --- 1. CONVERTED TO STATEFULWIDGET ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- 2. ADD STATE FOR PASSWORD VISIBILITY ---
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await auth.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // On success, go to the Profile Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const ProfileScreen()),
        );
      }
    } catch (e) {
      // Error is handled by the provider, but we can show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'An unknown error occurred.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  // --- 3. APPLY PASSWORD VISIBILITY ---
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    // --- 4. ADD THE TOGGLE BUTTON ---
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // --- 5. UPDATE THE STATE ---
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a password' : null,
                ),
                const SizedBox(height: 24),
                auth.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: theme.textTheme.titleMedium,
                        ),
                        onPressed: _submitForm,
                        child: const Text('Login'),
                      ),
                if (auth.error != null && !auth.isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (ctx) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Don\'t have an account? Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}