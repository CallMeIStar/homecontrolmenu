import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class SensorInfo extends StatefulWidget {
  const SensorInfo({Key? key});

  @override
  State<SensorInfo> createState() => _SensorInfoState();
}

class _SensorInfoState extends State<SensorInfo> {
  late Future<Map<String, dynamic>> futureValue;
  late Timer timer;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool switchValue = false;
  double sliderValue = 5;

  void _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  Future<Map<String, dynamic>> fetchValue() async {
    final response = await http
        .get(Uri.parse('https://hsapi1234.azurewebsites.net/api/Value'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to load value');
    }
  }

  Future<List<Map<String, dynamic>>> gasValue() async {
    final response = await http.get(Uri.parse('http://192.168.3.251/gasValue'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      final List<Map<String, dynamic>> dataList1 =
          jsonData.cast<Map<String, dynamic>>();
      print(dataList1);
      return dataList1;
    } else {
      throw Exception('Failed to load value');
    }
  }

  Future<void> setFanStatus() async {
    final url = Uri.parse('http://192.168.3.140/setStatus');
    final headers = {'Content-Type': 'application/json'};
    String state = "";
    if (switchValue) {
      state = '1';
    } else {
      state = '0';
    }
    final body = json
        .encode({'fanStatus': state, 'servoStatus': sliderValue.toString()});
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // Handle success
      print('Fan status set successfully');
    } else {
      // Handle error
      throw Exception('Failed to set fan status');
    }
  }

  Icon getWifiIcon(int wifiStrength) {
    if (wifiStrength < 60) {
      return const Icon(Icons.wifi);
    } else if (wifiStrength >= 60 && wifiStrength < 80) {
      return const Icon(Icons.wifi_2_bar);
    } else {
      return const Icon(Icons.wifi_1_bar);
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Info'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Color(0xFFD4145A), Color(0xFFFBB03B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 249, 221),
                          border:
                              Border.all(color: Color.fromARGB(255, 70, 42, 0)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Living Room',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD4145A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              FutureBuilder<Map<String, dynamic>>(
                                future: futureValue,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final Map<String, dynamic> data =
                                        snapshot.data!;
                                    final double temperature =
                                        data['temperature'];
                                    final int humidity = data['humidity'];
                                    final String timestamp = data['timestamp'];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.thermostat_outlined),
                                            Text(
                                              "Temperature ${temperature.toStringAsFixed(2)} °C",
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Color(0xFFD4145A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.water_drop_outlined),
                                            Text(
                                              "Humidity ${humidity.toString()} %",
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                color: Color(0xFFD4145A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(),
                                      ],
                                    );
                                  } else {
                                    return const Text('');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 249, 221),
                          border:
                              Border.all(color: Color.fromARGB(255, 70, 42, 0)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SizedBox(
                          height: 200,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'Kitchen',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD4145A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 249, 221),
                    border: Border.all(color: Color.fromARGB(255, 70, 42, 0)),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Miscellaneous',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4145A),
                          ),
                        ),
                      ),
                      ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
