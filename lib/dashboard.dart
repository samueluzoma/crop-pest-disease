

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crop_pest_insect_detection/routes/routes.dart';
import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Logic Variables (Unchanged)
  String? userName = "Guest";
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String _firstName = 'Guest';
  String _lastName = 'Guest';
  String _email = '';
  bool isGuest = true;

  File? filePath;
  bool isLoading = false;
  double confidence = 0.0;
  String label = "Unknown";
  double confidenceThreshold = 70.0;
  Interpreter? interpreter;
  List<String> labels = [];
  int inputSize = 224;
  int numClasses = 15;

  // Agricultural Palette
  final Color primaryGreen = const Color(0xff2E7D32);
  final Color accentGreen = const Color(0xff81C784);
  final Color bgLeaf = const Color(0xffF1F8E9);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadModel();
    _loadLabels();
  }

  // --- LOGIC METHODS (Strictly preserved) ---

  Future<void> _loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();
      interpreter = await Interpreter.fromAsset(
        'assets/crop pest insect/model_unquant.tflite',
        options: interpreterOptions,
      );
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      _showErrorDialog('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      String labelString =
          await rootBundle.loadString('assets/crop pest insect/labels.txt');
      labels = labelString.split('\n').map((line) => line.trim()).toList();
      print('Labels loaded: $labels');
    } catch (e) {
      print('Error loading labels: $e');
      _showErrorDialog('Error loading labels: $e');
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      filePath = File(image.path);
      isLoading = true;
    });

    var imageBytes = await filePath!.readAsBytes();
    var decodedImage = img.decodeImage(imageBytes);
    if (decodedImage != null) {
      runModelOnImage(decodedImage);
    } else {
      print("Failed to decode image");
    }
  }

  void runModelOnImage(img.Image image) async {
    double mean = 127.5;
    double std = 127.5;
    var resizedImage =
        img.copyResize(image, width: inputSize, height: inputSize);
    var input = imageToByteListFloat32(resizedImage, inputSize, mean, std);
    List<List<List<List<double>>>> inputTensor = [input];
    List<List<double>> outputTensor = [List.filled(numClasses, 0.0)];

    try {
      interpreter?.run(inputTensor, outputTensor);
      double maxConfidence = outputTensor[0].reduce((a, b) => a > b ? a : b);
      int maxIndex = outputTensor[0].indexOf(maxConfidence);
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        confidence = maxConfidence * 100;
        label = labels.isNotEmpty ? labels[maxIndex] : "Unknown";
        isLoading = false;
      });
    } catch (e) {
      print("Error running model: $e");
    }
  }

  List<List<List<double>>> imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    List<List<List<double>>> normalizedImage = List.generate(
        inputSize, (_) => List.generate(inputSize, (_) => List.filled(3, 0.0)));
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);
        normalizedImage[y][x][0] = (pixel.r.toDouble() - mean) / std;
        normalizedImage[y][x][1] = (pixel.g.toDouble() - mean) / std;
        normalizedImage[y][x][2] = (pixel.b.toDouble() - mean) / std;
      }
    }
    return normalizedImage;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void resetPage() {
    setState(() {
      filePath = null;
      label = '';
      confidence = 0.0;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firebaseFirestore.collection('user').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            isGuest = false;
            _firstName = userDoc['firstName'] ?? 'User';
            _lastName = userDoc['lastName'] ?? '';
            _email = userDoc['email'] ?? '';
          });
        } else {
          setState(() {
            isGuest = true;
          });
        }
      } else {
        setState(() {
          isGuest = true;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });
    switch (_currentIndex) {
      case 0:
        Navigator.pushNamed(context, Routes.dashboard);
        break;
      case 1:
        if (isGuest) {
          _showGuestPopup();
        } else {
          await Navigator.pushNamed(context, Routes.profile);
          _fetchUserData();
        }
        break;
    }
  }

  void _showGuestPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Up Required'),
        content: const Text('You need to sign up to access the profile page.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.signup);
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    if (isGuest) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, Routes.autHomePage);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Leave RiceHealth',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // --- UI BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLeaf,
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 90,
        backgroundColor: bgLeaf,
        leading: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 15.0),
          child: CircleAvatar(
            backgroundColor: accentGreen.withOpacity(0.3),
            child: Image.asset('assets/person.png'),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Hello, ",
                      style: TextStyle(fontSize: 22, color: Colors.black54)),
                  Text("$_firstName!",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(width: 5),
                  Image.asset('assets/handshake.png', height: 24)
                ],
              ),
              const Text("Monitor your crop health today",
                  style: TextStyle(fontSize: 14, color: Colors.black45)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Card(
                elevation: 10,
                shadowColor: primaryGreen.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Rice Disease Analysis',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload or capture a rice leaf photo to begin diagnosis',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: accentGreen.withOpacity(0.5),
                                  width: 2),
                            ),
                            child: filePath == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset('assets/upload.jpg',
                                        fit: BoxFit.cover,
                                        opacity:
                                            const AlwaysStoppedAnimation(0.5)),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(filePath!,
                                        fit: BoxFit.cover),
                                  ),
                          ),
                          if (isLoading)
                            Container(
                              height: 260,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white),
                                  SizedBox(height: 12),
                                  Text("Analyzing Leaf...",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryGreen,
                                side: BorderSide(color: primaryGreen),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (label.isNotEmpty && !isLoading) ...[
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text('Result: $label',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text('Confidence: ${confidence.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 16,
                                color: primaryGreen,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showRiceDiseaseDetails(context, label),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen.withOpacity(0.2),
                              foregroundColor: primaryGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Read Detailed Analysis',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: resetPage,
                        child: const Text('Reset Scanner',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildGuestButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

//   void _showCassavaDiseaseDetails(BuildContext context, String diseaseLabel) {
//     // Dictionary Unchanged (Logic Preserved)
//     Map<String, String> diseaseDetails = {
//       "Healthy": """
// Cause:
// - Plant is free from pathogens and stress.

// Importance:
// - Optimal productivity and root yield.

// Care:
// - Monitor soil nutrients and irrigation.
// """,
//       "Bacterial Blight (CBB)": """
// Cause:
// - Xanthomonas axonopodis bacterium.

// Symptoms:
// - Angular leaf spots, wilting, and dieback.

// Management:
// - Use resistant varieties; remove infected plants.
// """,
//       "Brown Streak Disease (CBSD)": """
// Cause:
// - Cassava Brown Streak Virus (CBSV).

// Symptoms:
// - Streaks on leaves; necrotic rot in roots.

// Management:
// - Control whiteflies; use certified clean materials.
// """,
//       "Green Mottle (CGM)": """
// Cause:
// - Cassava Green Mottle Virus.

// Symptoms:
// - Light green patches and distorted leaf shapes.

// Management:
// - Field hygiene and virus-free cuttings.
// """,
//       "Mosaic Disease (CMD)": """
// Cause:
// - Cassava Mosaic Virus.

// Symptoms:
// - Mosaic patterns; leaf distortion; stunting.

// Management:
// - Plant CMD-resistant varieties.
// """
//     };

//     String details = diseaseDetails[diseaseLabel] ?? "Details unavailable.";

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: Text(diseaseLabel, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
//           content: SingleChildScrollView(child: Text(details)),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Close", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
  void _showRiceDiseaseDetails(BuildContext context, String diseaseLabel) {
    // Dictionary aligned EXACTLY with provided rice disease classes
    Map<String, String> diseaseDetails = {
      "Healthy Rice Leaf": """
Cause:
- No infection; plant is healthy and stress-free.

Importance:
- Ensures optimal growth and maximum yield.

Care:
- Maintain proper irrigation, fertilization, and regular field monitoring.
""",
      "Bacterial Leaf Blight": """
Cause:
- Xanthomonas oryzae pv. oryzae (bacteria).

Symptoms:
- Yellowing from leaf tips, drying edges, wilting.

Management:
- Use resistant rice varieties.
- Ensure proper drainage and avoid overcrowding.
""",
      "Brown Spot": """
Cause:
- Cochliobolus miyabeanus (fungus).

Symptoms:
- Brown circular spots on leaves.
- Can lead to reduced grain quality and yield.

Management:
- Apply fungicides when necessary.
- Improve soil nutrients, especially nitrogen and potassium.
""",
      "Leaf Blast": """
Cause:
- Magnaporthe oryzae (fungus).

Symptoms:
- Diamond-shaped lesions with gray centers and dark borders.

Management:
- Plant resistant varieties.
- Avoid excessive nitrogen fertilizer.
""",
      "Leaf scald": """
Cause:
- Microdochium oryzae (fungus).

Symptoms:
- Large irregular lesions with gray centers and brown margins.

Management:
- Practice good field sanitation.
- Use resistant varieties where available.
""",
      "Sheath Blight": """
Cause:
- Rhizoctonia solani (fungus).

Symptoms:
- Green-gray lesions on leaf sheaths.
- Rapid spread under humid conditions.

Management:
- Ensure proper plant spacing.
- Apply fungicides if infection is severe.
"""
    };

    String details = diseaseDetails[diseaseLabel] ?? "Details unavailable.";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            diseaseLabel,
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(details),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mentalhealthchatbot/routes/routes.dart';
// import 'dart:io';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/services.dart';

// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});

//   @override
//   _DashboardPageState createState() => _DashboardPageState();
// }

// class _DashboardPageState extends State<DashboardPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

//   String _firstName = 'Guest';
//   bool isGuest = true;
//   int _currentIndex = 0;

//   File? filePath;
//   bool isLoading = false;
//   double confidence = 0.0;
//   String label = "";

//   Interpreter? interpreter;
//   List<String> labels = [];
//   int inputSize = 224;
//   int numClasses = 2;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//     _loadModel();
//     _loadLabels();
//   }

//   Future<void> _loadModel() async {
//     try {
//       final interpreterOptions = InterpreterOptions();
//       interpreter = await Interpreter.fromAsset(
//         'assets/cassava disease model/model_unquant.tflite',
//         options: interpreterOptions,
//       );
//     } catch (e) {
//       _showErrorDialog('Model initialization failed.');
//     }
//   }

//   Future<void> _loadLabels() async {
//     try {
//       String labelString =
//           await rootBundle.loadString('assets/cassava disease model/labels.txt');
//       labels = labelString
//           .split('\n')
//           .map((line) => line.trim())
//           .where((l) => l.isNotEmpty)
//           .toList();
//     } catch (e) {
//       _showErrorDialog('Labels not found.');
//     }
//   }

//   Future<void> pickImage(ImageSource source) async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: source);

//     if (image == null) return;

//     setState(() {
//       filePath = File(image.path);
//       isLoading = true;
//       label = ""; // Reset label while loading
//     });

//     var imageBytes = await filePath!.readAsBytes();
//     var decodedImage = img.decodeImage(imageBytes);

//     if (decodedImage != null) {
//       runModelOnImage(decodedImage);
//     }
//   }

//   void runModelOnImage(img.Image image) async {
//     // Standard normalization for MobileNetV2 based models
//     double mean = 127.5;
//     double std = 127.5;

//     var resizedImage =
//         img.copyResize(image, width: inputSize, height: inputSize);
//     var input = imageToByteListFloat32(resizedImage, inputSize, mean, std);
//     List<List<List<List<double>>>> inputTensor = [input];
//     List<List<double>> outputTensor = [List.filled(numClasses, 0.0)];

//     try {
//       interpreter?.run(inputTensor, outputTensor);

//       double maxConfidence = outputTensor[0].reduce((a, b) => a > b ? a : b);
//       int maxIndex = outputTensor[0].indexOf(maxConfidence);

//       // Brief delay for UX feel
//       await Future.delayed(const Duration(seconds: 2));

//       if (mounted) {
//         setState(() {
//           confidence = maxConfidence * 100;
//           label = labels.isNotEmpty ? labels[maxIndex] : "Result Processed";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       _showErrorDialog("Analysis Error: $e");
//     }
//   }

//   List<List<List<double>>> imageToByteListFloat32(
//       img.Image image, int size, double mean, double std) {
//     List<List<List<double>>> normalizedImage = List.generate(
//         size, (_) => List.generate(size, (_) => List.filled(3, 0.0)));

//     for (int y = 0; y < size; y++) {
//       for (int x = 0; x < size; x++) {
//         var pixel = image.getPixel(x, y);
//         normalizedImage[y][x][0] = (pixel.r.toDouble() - mean) / std;
//         normalizedImage[y][x][1] = (pixel.g.toDouble() - mean) / std;
//         normalizedImage[y][x][2] = (pixel.b.toDouble() - mean) / std;
//       }
//     }
//     return normalizedImage;
//   }

//   Future<void> _fetchUserData() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc =
//           await _firebaseFirestore.collection('user').doc(user.uid).get();
//       if (userDoc.exists) {
//         setState(() {
//           isGuest = false;
//           _firstName = userDoc['firstName'] ?? 'User';
//         });
//       }
//     }
//   }

//   void resetPage() {
//     setState(() {
//       filePath = null;
//       label = '';
//       confidence = 0.0;
//     });
//   }

//   void _onItemTapped(int index) {
//     if (index == 1 && isGuest) {
//       _showGuestPopup();
//     } else {
//       setState(() => _currentIndex = index);
//       if (index == 1)
//         Navigator.pushNamed(context, Routes.profile)
//             .then((_) => _fetchUserData());
//     }
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("System Notification"),
//         content: Text(message),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context), child: const Text("OK"))
//         ],
//       ),
//     );
//   }

//   void _showGuestPopup() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Access Restricted'),
//         content: const Text(
//             'Please create an account to save scan history and view your profile.'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Later')),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pushNamed(context, Routes.signup);
//             },
//             child: const Text('Sign Up'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const primaryBlue = Color(0xff0D47A1);
//     const bgBlue = Color(0xffF0F4F8);

//     return Scaffold(
//       backgroundColor: bgBlue,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               /// MEDICAL HEADER
//               Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: const BoxDecoration(
//                   color: primaryBlue,
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(32),
//                     bottomRight: Radius.circular(32),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     const CircleAvatar(
//                       radius: 28,
//                       backgroundColor: Colors.white24,
//                       child: Icon(Icons.person, color: Colors.white),
//                     ),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "Welcome, $_firstName",
//                             style: const TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white),
//                           ),
//                           const Text(
//                             "Ready for Diagnostic Screening",
//                             style:
//                                 TextStyle(color: Colors.white70, fontSize: 14),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// SCAN CARD
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Card(
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(24),
//                       side: BorderSide(color: Colors.blue.shade100)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       children: [
//                         const Text(
//                           "Chest X-Ray Analysis",
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: primaryBlue),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text("Upload a clear AP/PA view X-ray image",
//                             style: TextStyle(color: Colors.grey, fontSize: 13)),

//                         const SizedBox(height: 20),

//                         /// IMAGE CONTAINER
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(16),
//                           child: Container(
//                             height: 240,
//                             width: double.infinity,
//                             color: bgBlue,
//                             child: Stack(
//                               children: [
//                                 Center(
//                                   child: filePath == null
//                                       ? Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Icon(
//                                                 Icons.document_scanner_outlined,
//                                                 size: 50,
//                                                 color: Colors.blue.shade200),
//                                             const Text("No image selected",
//                                                 style: TextStyle(
//                                                     color: Colors.blueGrey)),
//                                           ],
//                                         )
//                                       : Image.file(filePath!,
//                                           fit: BoxFit.cover,
//                                           width: double.infinity),
//                                 ),
//                                 if (isLoading)
//                                   Container(
//                                     color: Colors.black45,
//                                     child: const Center(
//                                         child: CircularProgressIndicator(
//                                             color: Colors.white)),
//                                   )
//                               ],
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 25),

//                         /// ACTION BUTTONS
//                         Row(
//                           children: [
//                             Expanded(
//                               child: OutlinedButton.icon(
//                                 style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 12),
//                                     side: const BorderSide(color: primaryBlue)),
//                                 onPressed: () => pickImage(ImageSource.camera),
//                                 icon: const Icon(Icons.camera_alt_outlined,
//                                     color: primaryBlue),
//                                 label: const Text("Camera",
//                                     style: TextStyle(color: primaryBlue)),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: primaryBlue,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 12)),
//                                 onPressed: () => pickImage(ImageSource.gallery),
//                                 icon: const Icon(Icons.photo_library_outlined,
//                                     color: Colors.white),
//                                 label: const Text("Gallery",
//                                     style: TextStyle(color: Colors.white)),
//                               ),
//                             ),
//                           ],
//                         ),

//                         if (label.isNotEmpty && !isLoading) ...[
//                           const SizedBox(height: 25),
//                           const Divider(),
//                           const SizedBox(height: 15),
//                           Text(
//                             label.toLowerCase() == "pneumonia"
//                                 ? "HAS ${label.toUpperCase()}"
//                                 : "${label.toUpperCase()}",
//                             style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.w900,
//                                 color: label.toLowerCase() == "pneumonia"
//                                     ? Colors.redAccent
//                                     : Colors.green),
//                           ),
//                           Text(
//                               "Analysis Confidence: ${confidence.toStringAsFixed(1)}%"),
//                           const SizedBox(height: 15),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blueGrey.shade800),
//                               onPressed: () =>
//                                   _showPneumoniaDetails(context, label),
//                               child: const Text("View Clinical Guidelines",
//                                   style: TextStyle(color: Colors.white)),
//                             ),
//                           ),
//                         ],

//                         const SizedBox(height: 10),
//                         TextButton(
//                             onPressed: resetPage,
//                             child: const Text("Clear Analysis")),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               if (isGuest) ...[
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pushReplacementNamed(
//                         context, Routes.autHomePage),
//                     child: const Text("Exit to Main Menu"),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         selectedItemColor: primaryBlue,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Scan"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline), label: "Profile"),
//         ],
//       ),
//     );
//   }

// // Function to display details for Pneumonia detection results
//   void _showPneumoniaDetails(BuildContext context, String classificationLabel) {
//     Map<String, String> healthDetails = {
//       "normal": """
// Status:
// - The chest X-ray shows clear lung fields with no significant opacities.
// - Diaphragm and heart contours appear within normal limits.

// Clinical Significance:
// - Indicates a low probability of acute bacterial or viral pneumonia at the time of the scan.

// Next Steps:
// - If symptoms (cough, fever, shortness of breath) persist, consult a physician regardless of the X-ray result.
// - Maintain good respiratory hygiene and stay hydrated.

// Note:
// - This is an AI-assisted screening tool and should be verified by a qualified Radiologist.
// """,
//       "pneumonia": """
// Possible Cause:
// - Infection of the lungs caused by bacteria, viruses, or fungi.
// - Inflammation leads to fluid or pus in the air sacs (alveoli).

// Common Symptoms:
// - Persistent cough (often with phlegm).
// - Fever, sweating, and shaking chills.
// - Shortness of breath or chest pain when breathing/coughing.
// - Fatigue and loss of appetite.

// Clinical Management:
// - Immediate consultation with a healthcare professional is required.
// - Treatment may include antibiotics (for bacterial), antivirals, or supportive care.

// Preventive Measures:
// - Vaccination (Pneumococcal and Flu vaccines).
// - Regular handwashing and avoiding smoking.
// - Strengthening the immune system through nutrition.

// Disclaimer:
// - High priority medical review is recommended for 'Pneumonia' detections.
// """
//     };

//     // Ensure case-insensitivity by converting the label to lowercase
//     String searchKey = classificationLabel.toLowerCase();
//     String details = healthDetails[searchKey] ??
//         "Detailed clinical information for this classification is not available.";

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: Row(
//             children: [
//               Icon(
//                 searchKey == "pneumonia"
//                     ? Icons.warning_amber_rounded
//                     : Icons.check_circle_outline,
//                 color: searchKey == "pneumonia" ? Colors.red : Colors.blue,
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 classificationLabel.toUpperCase(),
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Text(
//               details,
//               style: const TextStyle(fontSize: 14, height: 1.5),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text(
//                 "DISMISS",
//                 style: TextStyle(
//                   color: Colors.blueGrey,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
