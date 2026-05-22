
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crop_pest_insect_detection/routes/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Colors - Clinical Medical Theme
  static const Color primaryBlue = Color(0xff0D47A1);
  static const Color accentBlue = Color(0xff1976D2);
  static const Color bgCanvas = Color(0xffF8FAFF);
  static const Color cardBg = Colors.white;
  static const Color textMain = Color(0xff0A1931);

  void login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        String userId = userCredential.user!.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        String firstName = userDoc.get('firstName') ?? 'User';
        String lastName = userDoc.get('lastName') ?? '';

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access Granted. Welcome Dr. $lastName'),
            backgroundColor: primaryBlue,
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          Routes.dashboard,
          arguments: {
            'firstName': firstName,
            'lastName': lastName,
            '_email': email,
          },
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Authentication failed.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No medical record found for this email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Invalid credentials.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                /// BRANDING HEADER
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: primaryBlue, size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.biotech_rounded, color: primaryBlue),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CassavaPred AI',
                      style: TextStyle(
                        color: textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 40),

                /// LOGIN CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Portal Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Secure access to diagnostic tools',
                          style: TextStyle(
                            color: Colors.blueGrey.shade400,
                            fontSize: 15,
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        /// EMAIL FIELD
                        _buildInputField(
                          label: 'Institutional Email',
                          controller: _emailController,
                          hint: 'name@hospital.com',
                          icon: Icons.alternate_email_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Email required';
                            if (!value.contains('@')) return 'Invalid format';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD FIELD
                        _buildInputField(
                          label: 'Secure Password',
                          controller: _passwordController,
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password required';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        /// REMEMBER ME
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: primaryBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _rememberMe = val!),
                            ),
                            const Text('Keep me logged in', style: TextStyle(color: Colors.blueGrey)),
                          ],
                        ),

                        const SizedBox(height: 30),

                        /// SIGN IN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isLoading ? null : login,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                : const Text(
                                    'Authorize Access',
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// SIGN UP LINK
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, Routes.signup),
                            child: RichText(
                              text: const TextSpan(
                                text: 'New researcher? ',
                                style: TextStyle(color: Colors.blueGrey),
                                children: [
                                  TextSpan(
                                    text: 'Register Credentials',
                                    style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textMain)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5)),
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ) 
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: primaryBlue, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}