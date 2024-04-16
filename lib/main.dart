// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'scan_controller.dart';
import 'sensor_info.dart';
import 'speechrec.dart';

late List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const MenuApp());
}

class MenuApp extends StatefulWidget {
  const MenuApp({super.key});

  @override
  _MenuAppState createState() => _MenuAppState();
}

class _MenuAppState extends State<MenuApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Menu',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Montserrat',
      ),
      home: const MenuScreen(),
      routes: {
        '/sensor_info': (context) => const SensorInfo(),
        '/speech_recognition': (context) => SpeechScreen(),
        '/camera_view': (context) => CameraView(
              key: UniqueKey(),
              controller: _controller,
            ),
      },
    );
  }
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HomeControl',
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontFamily: '', // Custom font
            fontWeight: FontWeight.bold, // Make it bold
            letterSpacing: 2.0, // Add some letter spacing
            shadows: [
              Shadow(
                blurRadius: 5.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
              ),
            ),
          ),
          // Suncloud image
          Positioned(
            top: -120, // Move it further upwards
            right: 20,
            child: Transform.scale(
              scale: 0.45, // Scale down by 25%
              child: Transform(
                transform:
                    Matrix4.rotationY(180 * 3.1415927 / 180), // Flip vertically
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: 0.3, // 30% opacity
                  child: Image.asset(
                    'assets/suncloud.png',
                    fit: BoxFit.fitWidth, // Fit the image width
                  ),
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.27), // Added SizedBox to create space
                MenuButton(
                  text: 'Sensor Info',
                  icon: Icons.sensors,
                  onPressed: () {
                    Navigator.pushNamed(context, '/sensor_info');
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Camera View',
                  icon: Icons.camera_alt,
                  onPressed: () async {
                    Navigator.pushNamed(
                      context,
                      '/camera_view',
                    );
                  },
                ),
                const SizedBox(height: 20),
                MenuButton(
                  text: 'Speech Recognition',
                  icon: Icons.mic,
                  onPressed: () {
                    Navigator.pushNamed(context, '/speech_recognition');
                  },
                ),
              ],
            ),
          ),
          // Background image with 50% opacity
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/home.png', // Adjust path as necessary
                fit: BoxFit.scaleDown, // Scale down the image to fit
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 249, 221),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFFFBB03B)),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4145A),
          ),
        ),
      ],
    );
  }
}

class CameraView extends StatelessWidget {
  const CameraView({Key? key, required this.controller}) : super(key: key);

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Camera View'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
              ),
            ),
          ),
        ),
        
        extendBodyBehindAppBar: false,
        body: GetBuilder<ScanController>(
          init: ScanController(),
          builder: (controller) {
            return Stack(
              children: [
                // Camera Preview
                controller.isCameraInitialized.value
                    ? CameraPreview(controller.cameraController)
                    : const Center(child: Text("Loading")),
                // Detected Object Text Overlay
                Positioned(
                  bottom: 0,
                  left: 16,
                  child: Obx(() => Text(
                        controller.detectedObject.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
