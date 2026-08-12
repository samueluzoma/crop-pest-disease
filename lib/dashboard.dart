// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_pest_insect_detection/routes/routes.dart';
import 'package:image_picker/image_picker.dart';
import 'prediction/prediction_service.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Logic Variables (Unchanged)
  String? userName = "Guest";
  int _currentIndex = 0;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  String _firstName = 'Guest';
  String _lastName = 'Guest';
  String _email = '';
  bool isGuest = true;

  Uint8List? imageBytes;
  bool isLoading = false;
  double confidence = 0.0;
  String label = "Unknown";
  double confidenceThreshold = 70.0;
  final PredictionService _predictionService = PredictionService();

  // Agricultural Palette
  final Color primaryGreen = const Color(0xff2E7D32);
  final Color accentGreen = const Color(0xff81C784);
  final Color bgLeaf = const Color(0xffF1F8E9);

  @override
  void initState() {
    super.initState();
    // _fetchUserData();
    _loadModel();
    _loadLabels();
  }

  // --- LOGIC METHODS (Strictly preserved) ---

  Future<void> _loadModel() async {
    try {
      await _predictionService.load();
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      _showErrorDialog('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {}

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      imageBytes = bytes;
      isLoading = true;
    });

    runModelOnImage(bytes);
  }

  void runModelOnImage(Uint8List bytes) async {
    try {
      final result = await _predictionService.predict(bytes);
      setState(() {
        confidence = result.confidence;
        label = result.label;
        isLoading = false;
      });
    } catch (e) {
      print("Error running model: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void resetPage() {
    setState(() {
      imageBytes = null;
      label = '';
      confidence = 0.0;
    });
  }

  // Future<void> _fetchUserData() async {
  //   try {
  //     User? user = _auth.currentUser;
  //     if (user != null) {
  //       DocumentSnapshot userDoc =
  //           await _firebaseFirestore.collection('user').doc(user.uid).get();
  //       if (userDoc.exists) {
  //         setState(() {
  //           isGuest = false;
  //           _firstName = userDoc['firstName'] ?? 'User';
  //           _lastName = userDoc['lastName'] ?? '';
  //           _email = userDoc['email'] ?? '';
  //         });
  //       } else {
  //         setState(() {
  //           isGuest = true;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         isGuest = true;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching user data: $e");
  //   }
  // }

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
          // _fetchUserData();
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
            child: const Text('Cancel'),
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Leave PestDiseasePred',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
                  const Text(
                    "Hello, ",
                    style: TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                  Text(
                    "$_firstName!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Image.asset('assets/handshake.png', height: 24),
                ],
              ),
              const Text(
                "Monitor your crop health today",
                style: TextStyle(fontSize: 14, color: Colors.black45),
              ),
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
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Crop Pest Disease Analysis',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload or capture a crop pest photo to begin diagnosis',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 320,
                            width: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accentGreen.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: imageBytes == null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/upload.jpg',
                                      fit: BoxFit.cover,
                                      opacity: const AlwaysStoppedAnimation(
                                        0.5,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      imageBytes!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                          if (isLoading)
                            Container(
                              height: 320,
                              width: MediaQuery.of(context).size.width * 0.8,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Analyzing Leaf...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (label.isNotEmpty && !isLoading) ...[
                        const SizedBox(height: 25),
                        const Divider(),
                        const SizedBox(height: 10),
                        Text(
                          'Result: $label',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Confidence: ${confidence.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                _showPestOrDiseaseDetails(context, label),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen.withOpacity(0.2),
                              foregroundColor: primaryGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Read Detailed Analysis',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: resetPage,
                        child: const Text(
                          'Reset Scanner',
                          style: TextStyle(color: Colors.grey),
                        ),
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
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
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

//   void _showRiceDiseaseDetails(BuildContext context, String diseaseLabel) {
//     // Dictionary aligned EXACTLY with provided rice disease classes
//     Map<String, String> diseaseDetails = {
//       "Healthy Rice Leaf": """
// Cause:
// - No infection; plant is healthy and stress-free.

// Importance:
// - Ensures optimal growth and maximum yield.

// Care:
// - Maintain proper irrigation, fertilization, and regular field monitoring.
// """,
//       "Bacterial Leaf Blight": """
// Cause:
// - Xanthomonas oryzae pv. oryzae (bacteria).

// Symptoms:
// - Yellowing from leaf tips, drying edges, wilting.

// Management:
// - Use resistant rice varieties.
// - Ensure proper drainage and avoid overcrowding.
// """,
//       "Brown Spot": """
// Cause:
// - Cochliobolus miyabeanus (fungus).

// Symptoms:
// - Brown circular spots on leaves.
// - Can lead to reduced grain quality and yield.

// Management:
// - Apply fungicides when necessary.
// - Improve soil nutrients, especially nitrogen and potassium.
// """,
//       "Leaf Blast": """
// Cause:
// - Magnaporthe oryzae (fungus).

// Symptoms:
// - Diamond-shaped lesions with gray centers and dark borders.

// Management:
// - Plant resistant varieties.
// - Avoid excessive nitrogen fertilizer.
// """,
//       "Leaf scald": """
// Cause:
// - Microdochium oryzae (fungus).

// Symptoms:
// - Large irregular lesions with gray centers and brown margins.

// Management:
// - Practice good field sanitation.
// - Use resistant varieties where available.
// """,
//       "Sheath Blight": """
// Cause:
// - Rhizoctonia solani (fungus).

// Symptoms:
// - Green-gray lesions on leaf sheaths.
// - Rapid spread under humid conditions.

// Management:
// - Ensure proper plant spacing.
// - Apply fungicides if infection is severe.
// """,
//     };

//     String details = diseaseDetails[diseaseLabel] ?? "Details unavailable.";

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Text(
//             diseaseLabel,
//             style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(child: Text(details)),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 "Close",
//                 style: TextStyle(
//                   color: primaryGreen,
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
void _showPestOrDiseaseDetails(BuildContext context, String classification) {
  // Map aligned with the provided 15 classes
  Map<String, String> pestDetails = {
    "Africanized Honey Bees (Killer Bees)": "Type: Insect\n\nNotes: Highly aggressive. Require professional management and extreme caution near hives.",
    "Aphids": "Type: Pest\n\nSymptoms: Stunted growth, yellowing leaves, sticky honeydew.\n\nManagement: Use insecticidal soaps or natural predators like ladybugs.",
    "Armyworms": "Type: Pest\n\nSymptoms: Significant leaf chewing/defoliation.\n\nManagement: Monitor for egg masses; use biological controls like Bt (Bacillus thuringiensis).",
    "Brown Marmorated Stink Bugs": "Type: Pest\n\nSymptoms: Piercing-sucking damage on fruit and leaves.\n\nManagement: Hand-picking, pheromone traps, and exclusion netting.",
    "Cabbage Loopers": "Type: Pest\n\nSymptoms: Irregular holes in foliage.\n\nManagement: Row covers and microbial insecticides (Bt).",
    "Citrus Canker": "Type: Disease (Bacterial)\n\nSymptoms: Raised, corky lesions with yellow halos on leaves and fruit.\n\nManagement: Prune infected parts; avoid overhead irrigation; use copper-based bactericides.",
    "Colorado Potato Beetles": "Type: Pest\n\nSymptoms: Severe defoliation by both larvae and adults.\n\nManagement: Crop rotation and timely application of targeted insecticides.",
    "Corn Borers": "Type: Pest\n\nSymptoms: Small holes in stalks; broken tassels.\n\nManagement: Sanitation (destroying crop residue); planting resistant hybrids.",
    "Corn Earworms": "Type: Pest\n\nSymptoms: Damage to silk and kernels at the tip of the ear.\n\nManagement: Oil application to silk; use resistant varieties.",
    "Fall Armyworms": "Type: Pest\n\nSymptoms: Rapid skeletonization of leaves.\n\nManagement: Scout early; apply insecticides during early larvae stages.",
    "Fruit Flies": "Type: Pest\n\nSymptoms: Small puncture marks on fruit; larvae tunneling inside.\n\nManagement: Use bait traps and practice good orchard sanitation.",
    "Spider Mites": "Type: Pest\n\nSymptoms: Fine webbing and stippling (yellow dots) on leaves.\n\nManagement: Keep plants well-watered; increase humidity; use miticides if necessary.",
    "Thrips": "Type: Pest\n\nSymptoms: Silvery, streaked leaves; distorted growth.\n\nManagement: Use sticky traps and reflective mulches.",
    "Tomato Hornworms": "Type: Pest\n\nSymptoms: Massive defoliation; large dark droppings.\n\nManagement: Hand-pick; encourage parasitic wasps.",
    "Western Corn Rootworms": "Type: Pest\n\nSymptoms: Larvae feed on roots, leading to lodged plants.\n\nManagement: Crop rotation is the most effective prevention.",
  };

  String details = pestDetails[classification] ?? "Specific management details for $classification are currently under review.";

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          classification,
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(child: Text(details)),
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
