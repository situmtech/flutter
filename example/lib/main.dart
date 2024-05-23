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

class _TapTapTapDetectorState extends State<TapTapTapDetector> {

  final int peakInterval = 1000; // Máximo intervalo entre los 3 taps en milisegundos
  final int tapCountThreshold = 3; // Número mínimo de taps para desencadenar la vibración
  List<List<dynamic>> accelerationBuffer = [];


  // void smoothAccelerometerData() {
  //   int windowSize = 3; // Tamaño de la ventana para el filtro de media móvil
  //   List<List<dynamic>> smoothedBuffer = [];
  //
  //   for (int i = 0; i < accelerationBuffer.length; i++) {
  //     if (i < windowSize - 1) {
  //       // No hay suficientes datos para suavizar, simplemente agregamos el dato original
  //       smoothedBuffer.add(accelerationBuffer[i]);
  //     } else {
  //       double sum = 0.0;
  //       for (int j = i - windowSize + 1; j <= i; j++) {
  //         sum += accelerationBuffer[j][0]; // Sumar los valores de aceleración
  //       }
  //       double smoothedValue = sum / windowSize; // Calcular el promedio
  //       int timestamp = accelerationBuffer[i][1]; // Conservar el timestamp original
  //       smoothedBuffer.add([smoothedValue, timestamp]); // Agregar el valor suavizado al nuevo buffer
  //     }
  //   }
  //   accelerationBuffer = List.from(smoothedBuffer);
  // }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration = event.y.abs();
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      accelerationBuffer.add([acceleration, currentTime]);

      // smoothAccelerometerData();
      // Mantener el tamaño del búfer dentro del límite
      _trimBuffer();

      // for (var entry in accelerationBuffer) {
      //   print("Acceleration value Y: ${entry[0]}");
      // }

      // Detectar picos en el búfer de aceleración
      if (_hasPeak(accelerationBuffer)) {
        triggerVibration();
      }
    });
  }

  bool _hasPeak(List<List<dynamic>> data) {
    int tapCount = 0;
    int timestampFirstPeak = 0;
    int timestampLastPeak = 0;

    for (int i = 10; i < data.length - 10; i++) {

      if (data[i][0] > 2*data[i - 10][0] && 2*data[i + 10][0] <  data[i][0]) {

        if (timestampFirstPeak == 0 && tapCount == 0) {
          timestampFirstPeak = data[i][1];
        }
        if (timestampLastPeak == 0 && tapCount == 2) {
          timestampLastPeak = data[i][1];
        }
        tapCount++;
        //print ("Tap count:   ${tapCount}");
      }
    }

    return tapCount >= tapCountThreshold && (timestampLastPeak - timestampFirstPeak) < peakInterval;
  }

  //Actualiza el buffer de datos para tener
  // un buffer de 2000 ms de datos del acelerometro
  void _trimBuffer() {
    if (accelerationBuffer.isEmpty) return;

    int firstTimestamp = accelerationBuffer.first[1];
    int lastTimestamp = accelerationBuffer.last[1];

    while (lastTimestamp - firstTimestamp > peakInterval) {
      setState(() {
        accelerationBuffer.removeAt(0);
      });
      if (accelerationBuffer.isEmpty) break;
      firstTimestamp = accelerationBuffer.first[1];
    }
  }

  void triggerVibration() {
    print("Vibra!!!!!!!!!!!!!!!!1 TapTapTap detectado.");
    // Vibrate.vibrate();
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


