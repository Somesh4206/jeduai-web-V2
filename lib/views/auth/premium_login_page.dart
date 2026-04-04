import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_login_card.dart';
import '../../widgets/animated_login_button.dart';
import '../../widgets/glass_text_field.dart';

class PremiumLoginPage extends StatefulWidget {
  const PremiumLoginPage({Key? key}) : super(key: key);

  @override
  State<PremiumLoginPage> createState() => _PremiumLoginPageState();
}

class _PremiumLoginPageState extends State<PremiumLoginPage>
    with TickerProviderStateMixin {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'Student';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: GlassLoginCard(
                    width: isMobile ? size.width - 40 : 450,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title (replacing logo)
                          _buildTitle(),
                          
                          SizedBox(height: 8),
                          
                          // Subtitle
                          _buildSubtitle(),
                          
                          SizedBox(height: 40),
                          
                          // Role Dropdown
                          _buildRoleDropdown(),
                          
                          SizedBox(height: 20),
                          
                          // Email Field
                          GlassTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Password Field
                          GlassTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Login Button
                          Obx(() => AnimatedLoginButton(
                            onPressed: _handleLogin,
                            isLoading: authController.isLoading.value,
                            text: 'Login',
                          )),
                          
                          SizedBox(height: 20),
                          
                          // Sign Up Link
                          _buildSignUpLink(),
                        ],
                      ),
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


  Widget _buildTitle() {
    return Column(
      children: [
        // JeduAI text logo with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF06B6D4),
            ],
          ).createShader(bounds),
          child: Text(
            'JeduAI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Smart Learning & Assessment Platform',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }


  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRole,
          isExpanded: true,
          dropdownColor: Color(0xFF1E293B),
          icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
          style: TextStyle(color: Colors.white, fontSize: 16),
          items: ['Student', 'Teacher', 'Admin'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'Student'
                        ? Icons.school
                        : value == 'Teacher'
                            ? Icons.person
                            : Icons.admin_panel_settings,
                    color: Color(0xFF7C3AED),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedRole = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        TextButton(
          onPressed: () {
            Get.toNamed('/signup');
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }


  void _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    try {
      await authController.login(
        emailController.text,
        passwordController.text,
        selectedRole,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid credentials',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(20),
        borderRadius: 12,
      );
    }
  }
}
