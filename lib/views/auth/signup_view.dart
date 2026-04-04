import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String selectedRole = 'Student';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // JeduAI Logo
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/JeduAi_logo.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(128),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join JeduAI Learning Platform',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white.withAlpha(204),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Email Field
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white.withAlpha(204),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Role Selector (Student and Staff only - Admin cannot be created via signup)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(204),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school, color: Colors.grey[700]),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: selectedRole,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            style: TextStyle(color: Colors.black),
                            underline: SizedBox(),
                            items: ['Student', 'Staff'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedRole = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white.withAlpha(204),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Confirm Password Field
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white.withAlpha(204),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 25),

                  // Signup Button
                  Obx(
                    () => authController.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withAlpha(128),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _handleSignup,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    // Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showErrorSnackbar('Please fill all fields');
      return;
    }

    if (!emailController.text.contains('@')) {
      _showErrorSnackbar('Please enter a valid email');
      return;
    }

    if (passwordController.text.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    // Call signup method
    final success = await authController.signupWithEmailPassword(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      role: selectedRole.toLowerCase(),
    );

    if (success) {
      // Show success dialog after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSuccessDialog();
        }
      });
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 32),
              SizedBox(width: 10),
              Text('Success!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your account has been created successfully!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ Account created',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    Text(
                      '✓ $selectedRole profile set up',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                    Text(
                      '✓ Database initialized',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Text(
                'You can now login with your credentials:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: ${emailController.text}'),
              Text('Role: $selectedRole'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to login
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Go to Login', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
