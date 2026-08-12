// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:crop_pest_insect_detection/routes/routes.dart';
// import 'package:share_plus/share_plus.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   Future<Map<String, dynamic>> _fetchUserData() async {
//     try {
//       User? user = _auth.currentUser; // Get the currently logged-in user
//       if (user != null) {
//         DocumentSnapshot userDoc =
//             await _firebaseFirestore.collection('user').doc(user.uid).get();

//         if (userDoc.exists) {
//           return userDoc.data() as Map<String, dynamic>;
//         }
//       }
//     } catch (e) {
//       print("Error fetching user data: $e");
//     }
//     return {};
//   }

//   void _logout() async {
//     try {
//       await _auth.signOut();
//       Navigator.pushReplacementNamed(context, Routes.autHomePage);
//     } catch (e) {
//       print('Error logging out: $e');
//     }
//   }

//   final applink =
//       'https://drive.google.com/file/d/1IsJInHojsejiQFJz46N6DGNXhf7v_R10/view?usp=sharing';

//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Log Out?'),
//           content: const Text('Are you sure you want to log out?'),
//           actions: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 43,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: const Color(0xff8078B7),
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: TextButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: EdgeInsets.zero, // Remove extra padding
//                         foregroundColor: Colors.purple,
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Cancel',
//                           style: TextStyle(
//                             fontSize: 16, // Adjust font size
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16), // Add space between buttons
//                 Expanded(
//                   child: Container(
//                     height: 43,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Colors.red,
//                         width: 2,
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.red,
//                     ),
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         _logout();
//                       },
//                       style: TextButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: EdgeInsets.zero, // Remove extra padding
//                         foregroundColor: Colors.white,
//                       ),
//                       child: const Center(
//                         child: Text(
//                           'Continue',
//                           style: TextStyle(
//                             fontSize: 16, // Adjust font size
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showFeedbackDialog() {
//     final TextEditingController _feedbackController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Column(
//             children: [
//               Image.asset('assets/feedbacklogo.png'),
//               const Text('Make App Better'),
//               const SizedBox(height: 20),
//               const Text(
//                 'What should we improve on?',
//                 style: TextStyle(fontSize: 11),
//               ),
//             ],
//           ),
//           content: TextField(
//             controller: _feedbackController,
//             maxLines: 4,
//             decoration: const InputDecoration(
//               hintText: 'What should we do to improve the App?',
//               hintStyle: TextStyle(color: Colors.grey),
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xff612A74), width: 2),
//                   borderRadius: BorderRadius.circular(12),
//                   color: const Color(0xff612A74),
//                 ),
//                 child: TextButton(
//                   onPressed: () {
//                     final feedback = _feedbackController.text.trim();
//                     if (feedback.isNotEmpty) {
//                       _submitFeedback(feedback);
//                       Navigator.of(context).pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Feedback submitted successfully!'),
//                         ),
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Please enter your feedback.'),
//                         ),
//                       );
//                     }
//                   },
//                   style: TextButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Submit'),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _submitFeedback(String feedback) async {
//     try {
//       final User? user = _auth.currentUser;
//       if (user != null) {
//         await _firebaseFirestore.collection('feedback').add({
//           'feedback': feedback,
//           'userId': user.uid,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       print('Error submitting feedback: $e');
//     }
//   }

//   void _shareWithFriends() {
//     const apkFolderUrl =
//         'https://drive.google.com/drive/folders/1PpZ7DfvIiUrDPk87nOXbBmeV7SBtuQxp?usp=sharing';

//     final encodedUrl = Uri.encodeFull(apkFolderUrl);

//     Share.share(
//       'Check out the SKIN App!\nAccess the latest APK files here: $encodedUrl',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.black,
//           ),
//         ),
//         title: const Text(
//           'Profile',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.only(
//             bottom: isKeyboardVisible ? mediaQuery.viewInsets.bottom : 0),
//         child: FutureBuilder<Map<String, dynamic>>(
//           future: _fetchUserData(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return const Center(
//                 child: Text("An error occurred while fetching data."),
//               );
//             }

//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(
//                 child: Text("No user data found."),
//               );
//             }

//             final userData = snapshot.data!;
//             final String firstName = userData['firstName'] ?? 'Guest';
//             final String lastName = userData['lastName'] ?? 'Guest';
//             final String email = userData['email'] ?? '';

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       width: MediaQuery.of(context).size.width,
//                       color: const Color.fromARGB(255, 247, 238, 250),
//                       child: Column(
//                         children: [
//                           Image.asset('assets/Group.png'),
//                           Text(
//                             '$lastName $firstName',
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(email),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     Container(
//                       width: MediaQuery.of(context).size.width,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: const Color.fromARGB(255, 247, 238, 250),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Text(
//                               'User List',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           ListTile(
//                             leading: Image.asset('assets/profile.png'),
//                             title: const Text('Edit Profile'),
//                             trailing: const Icon(Icons.arrow_forward),
//                             onTap: () async {
//                               final updatedUserData = await Navigator.pushNamed(
//                                 context,
//                                 Routes.editprofile,
//                                 arguments: {
//                                   'firstName': userData['firstName'] ?? 'Guest',
//                                   'lastName': userData['lastName'] ?? 'Guest',
//                                   'email': userData['email'] ?? '',
//                                 },
//                               );

//                               if (updatedUserData != null &&
//                                   updatedUserData is Map<String, dynamic>) {
//                                 setState(() {
//                                   userData['firstName'] =
//                                       updatedUserData['firstName'];
//                                   userData['lastName'] =
//                                       updatedUserData['lastName'];
//                                   userData['email'] = updatedUserData['email'];
//                                 });
//                               }
//                             },
//                           ),
//                           ListTile(
//                             leading: Image.asset('assets/message.png'),
//                             title: const Text('Feedback'),
//                             trailing: const Icon(Icons.arrow_forward),
//                             onTap: _showFeedbackDialog,
//                           ),
//                           ListTile(
//                             leading: Image.asset('assets/people.png'),
//                             title: const Text('Share With Friends'),
//                             trailing: const Icon(Icons.arrow_forward),
//                             onTap: _shareWithFriends,
//                           ),
//                           ListTile(
//                             leading: Image.asset('assets/logout.png'),
//                             title: const Text(
//                               'Logout',
//                               style: TextStyle(color: Colors.red),
//                             ),
//                             onTap: _showLogoutDialog,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
