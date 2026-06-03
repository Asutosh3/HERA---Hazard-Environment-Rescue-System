import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String ip = "10.161.92.249"; // CHANGE LATER

  // Sensor + GPS
  String temperature = "--";
  String humidity = "--";
  String gas = "--";
  String latitude = "--";
  String longitude = "--";

  String currentCommand = "stop";
  bool ledOn = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    // Fetch sensor data every 2 sec
    Stream.periodic(const Duration(seconds: 2)).listen((_) {
      fetchSensorData();
    });
  }

  // ================= FETCH DATA =================
  void fetchSensorData() async {
    try {
      final res = await await http.get(Uri.parse("http://$ip/data"));
      final data = jsonDecode(res.body);

      setState(() {
        temperature = data["temperature"].toString();
        humidity = data["humidity"].toString();
        gas = data["gas"].toString();
        latitude = data["lat"].toString();
        longitude = data["lon"].toString();
      });
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // ================= SEND COMMAND =================
  void sendCommand(String command) async {
    try {
      await http.get(Uri.parse("http://$ip/move?dir=$command"));
    } catch (e) {
      print("Command error: $e");
      print("Calling: http://$ip/move?dir=$command");
    }
  }

  // ================= JOYSTICK =================
  void handleJoystick(double x, double y) {

    String newCommand = "stop";

    // DEAD ZONE
    if (x.abs() >= 0.2 || y.abs() >= 0.2) {

      // 🔴 FIXED INVERSION HERE
      double angle = atan2(-y, x) * (180 / pi);

      if (angle >= -45 && angle <= 45) {
        newCommand = "right";
      } else if (angle > 45 && angle < 135) {
        newCommand = "forward";
      } else if (angle >= 135 || angle <= -135) {
        newCommand = "left";
      } else {
        newCommand = "backward";
      }
    }

    if (newCommand != currentCommand) {
      setState(() {
        currentCommand = newCommand;
      });

      sendCommand(newCommand);
    }
  }

  // ================= STOP =================
  void stopRover() async {
    setState(() {
      currentCommand = "stop";
    });

    try {
      await http.get(Uri.parse("http://$ip/stop"));
    } catch (e) {
      print("Stop error: $e");
    }
  }

  // ================= LED =================
  void toggleLED() async {
    setState(() {
      ledOn = !ledOn;
    });

    try {
      await await http.get(Uri.parse("http://$ip/led?state=${ledOn ? "on" : "off"}"));
    } catch (e) {
      print("LED error: $e");
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Rover Controller"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: SafeArea(
        child: Column(
          children: [

            // 🔴 VIDEO
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text("Video Stream Coming Soon",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 8),

            // 🔴 SENSOR DATA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                sensorBox("Temp", temperature),
                sensorBox("Hum", humidity),
                sensorBox("Gas", gas),
              ],
            ),

            const SizedBox(height: 5),

            // 🔴 GPS
            Text(
              "Lat: $latitude | Lon: $longitude",
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12),
            ),

            const SizedBox(height: 8),

            // 🔴 LED BUTTON
            SizedBox(
              height: 35,
              child: ElevatedButton(
                onPressed: toggleLED,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  ledOn ? Colors.green : Colors.grey[800],
                ),
                child: Text(ledOn ? "LED ON" : "LED OFF"),
              ),
            ),

            const SizedBox(height: 8),

            // 🔴 CONTROLS AREA
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // 🔴 DIRECTION INDICATOR
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      indicatorBox("forward"),
                      Row(
                        children: [
                          indicatorBox("left"),
                          const SizedBox(width: 10),
                          indicatorBox("right"),
                        ],
                      ),
                      indicatorBox("backward"),
                    ],
                  ),

                  // 🔴 JOYSTICK
                  buildJoystick(),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔴 EMERGENCY STOP
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: stopRover,
        child: const Icon(Icons.stop),
      ),
    );
  }

  // ================= SENSOR BOX =================
  Widget sensorBox(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // ================= INDICATOR =================
  Widget indicatorBox(String command) {
    bool active = currentCommand == command;

    return Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: active ? Colors.red : Colors.grey[900],
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          command.substring(0, 1).toUpperCase(),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ================= JOYSTICK =================
  Widget buildJoystick() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Joystick(
        mode: JoystickMode.all,
        base: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red, width: 2),
          ),
        ),
        stick: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        listener: (details) {
          handleJoystick(details.x, details.y);
        },
        onStickDragEnd: () {
          stopRover();
        },
      ),
    );
  }
}