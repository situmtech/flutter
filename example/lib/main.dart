import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TapTapTapDetector(),
    );
  }
}

class TapTapTapDetector extends StatefulWidget {
  @override
  _TapTapTapDetectorState createState() => _TapTapTapDetectorState();
}
////v1 taptaptap
class _TapTapTapDetectorState extends State<TapTapTapDetector> {
  final double threshold = 10.0;  // Umbral para considerar un "tap"
  final int maxInterval = 1500;   // Máximo intervalo entre taps en milisegundos
  List<int> tapTimestamps = [];   // Timestamps de los taps detectados
  int _tapCount = 0;
  int lastTapTime = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration = event.y.abs();

      if(event.y.abs() > threshold){
        print("Y accelerometer: ${event.y.abs()}");
      }

      int currentTime = DateTime.now().millisecondsSinceEpoch;

      if (acceleration > threshold && (currentTime - lastTapTime) < maxInterval) {

        _tapCount ++;
        if (_tapCount >= 3) {
          _tapCount = 0;
          triggerVibration();
        }
      }

      lastTapTime = currentTime;

    });
  }

  void triggerVibration() {
    print("Vibrar! TapTapTap detectado.");
    Vibrate.vibrate();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TapTapTap Detector'),
      ),
      body: Center(
        child: Text('Realiza un "taptaptap" para que el teléfono vibre'),
      ),
    );
  }
}
