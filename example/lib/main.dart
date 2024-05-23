import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart'; // Importamos esta biblioteca para acceder a la vibración

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

class _TapTapTapDetectorState extends State<TapTapTapDetector> {
  final double threshold = 10.0;  // Umbral para considerar un "tap"
  final int maxInterval = 1000;   // Máximo intervalo entre taps en milisegundos
  List<int> tapTimestamps = [];   // Timestamps de los taps detectados

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration = event.y.abs();
      if(event.x.abs() > 10){
        print("X accelerometer: ${event.x.abs()}");
      }
      if(event.y.abs() > 10){
        print("Y accelerometer: ${event.y.abs()}");
      }
      if(event.z.abs() > 10){
        print("Z accelerometer: ${event.z.abs()}");
      }




      if (acceleration > threshold) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        tapTimestamps.add(currentTime);
        tapTimestamps = tapTimestamps.where((timestamp) => currentTime - timestamp <= maxInterval).toList();

        if (tapTimestamps.length >= 3) {
          tapTimestamps.clear();
          triggerVibration();
        }
      }
    });
  }

  void triggerVibration() {
    // Hacemos vibrar el teléfono utilizando la clase SystemChannels de la biblioteca Flutter
    SystemChannels.platform.invokeMethod<void>('HapticFeedback.vibrate');

    // Imprimimos un mensaje en la consola para verificar que la vibración se haya activado
    print("Vibrar! TapTapTap detectado.");
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
