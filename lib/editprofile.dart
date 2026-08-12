// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class EditProfilePage extends StatefulWidget {
//   final String firstName;
//   final String lastName;
//   final String email;

//   const EditProfilePage({
//     super.key,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//   });

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   late final TextEditingController _firstNameController;
//   late final TextEditingController _lastNameController;
//   late final TextEditingController _emailController;
//   final TextEditingController _passwordController = TextEditingController();

//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void initState() {
//     super.initState();
//     _firstNameController = TextEditingController(text: widget.firstName);
//     _lastNameController = TextEditingController(text: widget.lastName);
//     _emailController = TextEditingController(text: widget.email);
//   }

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _reauthenticateUser(String email, String currentPassword) async {
//     try {
//       final credential = EmailAuthProvider.credential(
//         email: email,
//         password: currentPassword,
//       );
//       await _auth.currentUser?.reauthenticateWithCredential(credential);
//     } catch (e) {
//       throw Exception("Reauthentication failed. Please check your password.");
//     }
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       User? user = _auth.currentUser;

//       if (user != null) {
//         // Reauthenticate if email or password is being updated
//         if (_emailController.text != widget.email ||
//             _passwordController.text.isNotEmpty) {
//           if (_passwordController.text.isEmpty) {
//             throw Exception(
//                 "To update your email or password, please provide your current password.");
//           }
//           await _reauthenticateUser(widget.email, _passwordController.text);
//         }

//         // Update user profile in Firestore
//         await _firebaseFirestore.collection('user').doc(user.uid).update({
//           'firstName': _firstNameController.text,
//           'lastName': _lastNameController.text,
//           'email': _emailController.text,
//         });

//         // Update Firebase Auth email
//         if (user.email != _emailController.text) {
//           await user.updateEmail(_emailController.text);
//         }

//         // Update Firebase Auth password
//         if (_passwordController.text.isNotEmpty) {
//           await user.updatePassword(_passwordController.text);
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully!')),
//         );

//         // Navigate back with updated profile details
//         Navigator.pop(context, {
//           'firstName': _firstNameController.text,
//           'lastName': _lastNameController.text,
//           'email': _emailController.text,
//         });
//       }
//     } on FirebaseAuthException catch (e) {
//       _handleFirebaseAuthError(e);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _handleFirebaseAuthError(FirebaseAuthException e) {
//     String errorMessage = "An error occurred while updating your profile.";

//     switch (e.code) {
//       case 'requires-recent-login':
//         errorMessage =
//             "You need to log in again to update your email or password.";
//         break;
//       case 'email-already-in-use':
//         errorMessage = "This email is already in use by another account.";
//         break;
//       case 'invalid-email':
//         errorMessage = "Please enter a valid email address.";
//         break;
//       case 'weak-password':
//         errorMessage =
//             "The password is too weak. Please choose a stronger one.";
//         break;
//       default:
//         errorMessage = e.message ?? errorMessage;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(errorMessage)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 230, 220, 232),
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 230, 220, 232),
//         elevation: 0.0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Update Your Profile',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Text('Update your details below'),
//                 const SizedBox(height: 25),
//                 _buildLabel('First Name'),
//                 const SizedBox(height: 12),
//                 _buildTextField(
//                   controller: _firstNameController,
//                   labelText: 'First Name',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your first name.';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 25),
//                 _buildLabel('Last Name'),
//                 const SizedBox(height: 12),
//                 _buildTextField(
//                   controller: _lastNameController,
//                   labelText: 'Last Name',
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your last name.';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 25),
//                 _buildLabel('Email Address'),
//                 const SizedBox(height: 12),
//                 _buildTextField(
//                   controller: _emailController,
//                   labelText: 'Email Address',
//                   validator: (value) {
//                     if (value == null ||
//                         !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
//                             .hasMatch(value)) {
//                       return 'Please enter a valid email address.';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 25),
//                 _buildLabel('Password', isOptional: true),
//                 const SizedBox(height: 12),
//                 _buildTextField(
//                   controller: _passwordController,
//                   labelText: 'Password',
//                   obscureText: _obscurePassword,
//                   validator: (value) {
//                     if (value != null && value.isNotEmpty && value.length < 6) {
//                       return 'Password must be at least 6 characters long.';
//                     }
//                     return null;
//                   },
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 80),
//                 const Align(
//                   alignment: Alignment.center,
//                   child: Text(
//                     'By updating your profile, you agree to RiceHealth \nprivacy policy and terms of service.',
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : Align(
//                         alignment: Alignment.center,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff612A74),
//                             minimumSize: const Size(300, 50),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           onPressed: _updateProfile,
//                           child: const Text(
//                             'Update Profile',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String labelText, {bool isOptional = false}) {
//     return Row(
//       children: [
//         Text(labelText),
//         Text(
//           isOptional ? ' (optional)' : '*',
//           style: TextStyle(color: isOptional ? Colors.grey : Colors.red),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     String? Function(String?)? validator,
//     bool obscureText = false,
//     Widget? suffixIcon,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Colors.grey[200],
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         labelText: labelText,
//         suffixIcon: suffixIcon,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       obscureText: obscureText,
//       validator: validator,
//     );
//   }
// }
