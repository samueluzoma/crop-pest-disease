
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:crop_pest_insect_detection/routes/routes.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({super.key});

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Medical Blue Theme
//   static const Color primaryBlue = Color(0xff0D47A1);
//   static const Color bgCanvas = Color(0xffF8FAFF);
//   static const Color textMain = Color(0xff0A1931);

//   Future<void> signUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final fullName = _fullNameController.text.trim();
//       final email = _emailController.text.trim();
//       final password = _passwordController.text.trim();

//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       final uid = credential.user!.uid;
//       final nameParts = fullName.split(" ");
//       final firstName = nameParts.first;
//       final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

//       // LOGIC CORRECTION: Using 'user' (singular) to match your Dashboard/Login calls
//       await _firestore.collection("user").doc(uid).set({
//         "firstName": firstName,
//         "lastName": lastName,
//         "email": email,
//         "createdAt": FieldValue.serverTimestamp(),
//       });

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Medical Professional Registered Successfully"),
//           backgroundColor: primaryBlue,
//         ),
//       );

//       Navigator.pushReplacementNamed(
//         context,
//         Routes.dashboard,
//         arguments: {
//           "firstName": firstName,
//           "lastName": lastName,
//           "email": email,
//         },
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = "Registration failed";
//       if (e.code == "email-already-in-use") {
//         message = "This email is already registered.";
//       } else if (e.code == "weak-password") {
//         message = "Password is too weak.";
//       }
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A system error occurred")));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgCanvas,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: primaryBlue),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text("User's Registration", 
//           style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: textMain)),
//                 const SizedBox(height: 8),
//                 const Text("Register to access the PneuScan AI diagnostic tools.", style: TextStyle(color: Colors.blueGrey)),
                
//                 const SizedBox(height: 35),

//                 _label("Full Name"),
//                 _buildField(_fullNameController, "e.g. Tunmise ola", Icons.person_outline),

//                 const SizedBox(height: 20),

//                 _label("Institutional Email"),
//                 _buildField(_emailController, "name@tumni@gmail.com", Icons.email_outlined, isEmail: true),

//                 const SizedBox(height: 20),

//                 _label("Secure Password"),
//                 _buildField(_passwordController, "Min. 6 characters", Icons.lock_outline, isPassword: true),

//                 const SizedBox(height: 40),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : signUp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryBlue,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       elevation: 0,
//                     ),
//                     child: _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text("Register Credentials", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already authorized? ", style: TextStyle(color: Colors.blueGrey)),
//                     TextButton(
//                       onPressed: () => Navigator.pushNamed(context, Routes.login),
//                       child: const Text("Login here", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _label(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8, left: 4),
//       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: textMain, fontSize: 14)),
//     );
//   }

//   Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, bool isEmail = false}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: isPassword && !_isPasswordVisible,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.4)),
//         filled: true,
//         fillColor: Colors.white,
//         suffixIcon: isPassword 
//           ? IconButton(
//               icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
//               onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//             ) 
//           : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//         enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue)),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return "Field required";
//         if (isEmail && !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) return "Invalid email";
//         if (isPassword && value.length < 6) return "Too short (min 6)";
//         return null;
//       },
//     );
//   }
// }
