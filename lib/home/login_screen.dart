import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();
    _checkLoginStatus();
  }

  /// التحقق مما إذا كان المستخدم قد سجل دخوله مسبقاً وبخيار "Remember Me"
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool remember = prefs.getBool('remember_me') ?? false;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && remember) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// عملية تسجيل الدخول
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // حفظ خيار "Remember Me"
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', _rememberMe);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred during login.";
      if (e.code == 'user-not-found') {
        message = "No user found with that email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else {
        message = e.message ?? message;
      }
      setState(() {
        errorMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Email Address',
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.email, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email address.';
        }
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.lock, color: Colors.black),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your password.';
        }
        if (value.trim().length < 6) {
          return 'Password must be at least 6 characters.';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          activeColor: Colors.teal[700],
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
        ),
        const Text('Remember Me', style: TextStyle(fontSize: 14, color: Colors.black)),
        const Spacer(),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('"Forgot Password" feature is under development.')),
            );
          },
          child: const Text('Forgot Password?', style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // لا تغيير في لون الخلفية؛ نستخدم نفس التدرج الأصلي
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[700]!, Colors.teal[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                        ),
                        const SizedBox(height: 24),
                        _buildEmailField(),
                        const SizedBox(height: 16),
                        _buildPasswordField(),
                        const SizedBox(height: 8),
                        _buildRememberMe(),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: login,
                          child: const Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text("Don't have an account? Sign Up", style: TextStyle(fontSize: 16, color: Colors.teal)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
