import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

// Clase base abstracta para los detectores de taps
abstract class TapDetector {
  void start();
  void stop();
}

class TapDetectorAlgorithm1 extends TapDetector {
  static const String TAG = 'TapDetector';

  static const int DEFAULT_NUM_TAPS = 3;
  static const int DEFAULT_SENSIBILITY = 8;

  static const int MIN_NUM_TAPS = 1;
  static const int MIN_SENSIBILITY = 0;
  static const int MAX_SENSIBILITY = 10;

  static const int INIT = 0;
  static const int PEAK = 1;
  static const int VALLEY = 2;
  static const int TAP_DETECTED = 3;

  final int requiredTaps;
  int currentTaps;
  final int sensibility;
  final double threshold;
  final List<double> hpZAxisAccWindow = [];
  final List<double> hpXAxisAccWindow = [];
  final List<double> hpYAxisAccWindow = [];
  double cumdt = 0;
  double tapcumdt = 0;
  List<double> prevAcc = [0, 0, 0];
  List<double> prevAccHP = [0, 0, 0];

  static const List<List<int>> transition = [
    [PEAK, PEAK, TAP_DETECTED],
    [VALLEY, TAP_DETECTED, PEAK]
  ];

  static const int PEAK_INDEX = 0;
  static const int VALLEY_INDEX = 1;
  int currentState = INIT;

  static const double RC = 0.015915494309189534;
  final double localThresh;
  double peakV = 0;
  double valleyV = 0;
  static const double MAX_TIME_BETWEEN_TAPS = 0.35;

  bool isRunning = false;
  late StreamSubscription<AccelerometerEvent> _subscription;
  int accTime = 0;

  TapDetectorAlgorithm1({required this.requiredTaps, required this.sensibility})
      : threshold = 2 * (10 - sensibility) + 10,
        localThresh = (2 * (10 - sensibility) + 10) / 3,
        currentTaps = 0;

  @override
  void start() {
    stop();
    print('$TAG: Started Tap Detector with requiredTaps=$requiredTaps and sensibility=$sensibility');
    _subscription = accelerometerEvents.listen((event) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      print("Executing algorithm 1");
      if (accTime != 0) {
        double dT = (currentTime - accTime) / 1000;
        handleAcc(event, dT);
      }
      accTime = currentTime;
      //_saveAccelerometerData(event, currentTime);
    });
    isRunning = true;
  }

  @override
  void stop() {
    if (!isRunning) return;
    print('$TAG: Stopped Tap Detector');
    _subscription.cancel();
    isRunning = false;
  }

  void sendTapDetection() {
    print('$TAG: TapTapTap has been detected');
    const MethodChannel platform = MethodChannel('com.example.app/tapDetection');
    platform.invokeMethod('tapDetected');
  }

  void handleAcc(AccelerometerEvent event, double dt) {
    List<double> acc = [event.x, event.y, event.z];
    if (hpZAxisAccWindow.isEmpty) {
      prevAcc = List.from(acc);
    }

    highPassFilter(acc, dt);

    hpXAxisAccWindow.add(prevAccHP[0]);
    hpYAxisAccWindow.add(prevAccHP[1]);
    hpZAxisAccWindow.add(prevAccHP[2]);
    cumdt += dt;
    tapcumdt += dt;

    if (hpZAxisAccWindow.length < 3) return;

    if (hpZAxisAccWindow[1] > localThresh && hpZAxisAccWindow[1] > hpZAxisAccWindow[0] && hpZAxisAccWindow[1] > hpZAxisAccWindow[2]) {
      peakV = math.max(peakV, hpZAxisAccWindow[1]);
      if (currentState == INIT) {
        cumdt = 0;
      }
      currentState = transition[PEAK_INDEX][currentState];
    } else if (hpZAxisAccWindow[1] < -localThresh && hpZAxisAccWindow[1] < hpZAxisAccWindow[0] && hpZAxisAccWindow[1] < hpZAxisAccWindow[2]) {
      valleyV = math.min(valleyV, hpZAxisAccWindow[1]);
      if (currentState == INIT) {
        cumdt = 0;
      }
      currentState = transition[VALLEY_INDEX][currentState];
    }

    if (currentState == TAP_DETECTED) {
      double difference = peakV - valleyV;
      if ((difference > threshold) && (maxAbsoluteValueInList(hpXAxisAccWindow) < (peakV * 0.8)) && (maxAbsoluteValueInList(hpYAxisAccWindow) < (peakV * 0.8))) {
        if (currentTaps == 0 || (tapcumdt > 0.1 && tapcumdt < MAX_TIME_BETWEEN_TAPS)) {
          currentTaps++;
        } else {
          currentTaps = 1;
        }
      }
      print('$TAG: $currentTaps taps detected');
      Vibrate.vibrate();
      tapcumdt = 0;
      cumdt = 0;
      currentState = INIT;
      peakV = 0;
      valleyV = 0;
    }

    if (currentTaps >= requiredTaps) {
      sendTapDetection();
      currentTaps = 0;
      cumdt = 0;
      currentState = INIT;
      peakV = 0;
      valleyV = 0;
    }

    if (tapcumdt > MAX_TIME_BETWEEN_TAPS) {
      currentTaps = 0;
      tapcumdt = 0;
    }

    if ((currentState == PEAK || currentState == VALLEY) && cumdt > 0.15) {
      cumdt = 0;
      currentState = INIT;
      peakV = 0;
      valleyV = 0;
    }

    if (hpZAxisAccWindow.length > 3) hpZAxisAccWindow.removeAt(0);
    if (hpXAxisAccWindow.length > 3) hpXAxisAccWindow.removeAt(0);
    if (hpYAxisAccWindow.length > 3) hpYAxisAccWindow.removeAt(0);
  }

  void highPassFilter(List<double> acc, double dt) {
    double alpha = RC / (RC + dt);
    prevAccHP[0] = alpha * prevAccHP[0] + (alpha) * (acc[0] - prevAcc[0]);
    prevAccHP[1] = alpha * prevAccHP[1] + (alpha) * (acc[1] - prevAcc[1]);
    prevAccHP[2] = alpha * prevAccHP[2] + (alpha) * (acc[2] - prevAcc[2]);
    prevAcc = List.from(acc);
  }

  double maxAbsoluteValueInList(List<double> list) {
    double max = 0;
    for (double value in list) {
      max = math.max(max, value.abs());
    }
    return max;
  }


  // Future<void> _saveAccelerometerData(AccelerometerEvent event, int timestamp) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = '${directory.path}/accelerometer_data.csv';
  //   //   print("path_ :  ${path}");
  //   final file = File(path);
  //
  //   String data = '$timestamp, ${event.x}, ${event.y}, ${event.z}\n';
  //   await file.writeAsString(data, mode: FileMode.append);
  // }
}

class TapDetectorAlgorithm2 extends TapDetector {
  final int peakInterval = 1000; // Máximo intervalo entre los 3 taps en milisegundos
  final int tapCountThreshold = 3; // Número mínimo de taps para desencadenar la vibración
  List<List<dynamic>> accelerationBuffer = [];
  late StreamSubscription<AccelerometerEvent> _streamSubscription;
  final int windowSize = 5;

  @override
  void start() {
    _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {

      List<double> rawAcceleration = [event.x, event.y, event.z];
      List<double> smoothedAcceleration = [
        _applyMovingAverageFilter(rawAcceleration.map((e) => e).toList(), windowSize),
        _applyMovingAverageFilter(rawAcceleration.map((e) => e).toList(), windowSize),
        _applyMovingAverageFilter(rawAcceleration.map((e) => e).toList(), windowSize)
      ];
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      accelerationBuffer.add([smoothedAcceleration, currentTime]);
      _trimBuffer();
      if (_hasPeak(accelerationBuffer)) {
        triggerVibration();
      }
      _saveAccelerometerData(smoothedAcceleration, currentTime);
    });
  }

  @override
  void stop() {
    _streamSubscription.cancel();
  }

  double _calculateMagnitude(List<double> acceleration) {
    return math.sqrt(acceleration[0] * acceleration[0] +
        acceleration[1] * acceleration[1] +
        acceleration[2] * acceleration[2]);
  }

  bool _hasPeak(List<List<dynamic>> data) {
    int tapCount = 0;

    for (int i = 10; i < data.length - 10; i++) {
      double magnitude = _calculateMagnitude(data[i][0]);
      double prevMagnitude = _calculateMagnitude(data[i - 10][0]);
      double nextMagnitude = _calculateMagnitude(data[i + 10][0]);

      if (magnitude > 2 * prevMagnitude && magnitude > 2 * nextMagnitude) {
        tapCount++;
      }
    }

    return tapCount >= tapCountThreshold;
  }

  double _applyMovingAverageFilter(List<double> data, int windowSize) {
    if (data.isEmpty) return 0.0;

    List<double> smoothedData = List<double>.filled(data.length, 0.0);
    int halfWindowSize = windowSize ~/ 2;

    for (int i = 0; i < data.length; i++) {
      int start = math.max(0, i - halfWindowSize);
      int end = math.min(data.length - 1, i + halfWindowSize);

      double sum = 0.0;
      int count = 0;

      for (int j = start; j <= end; j++) {
        sum += data[j];
        count++;
      }

      smoothedData[i] = sum / count;
    }

    return smoothedData.last; // Devuelve el último valor para la ventana actual
  }

  void _trimBuffer() {
    if (accelerationBuffer.isEmpty) return;

    int firstTimestamp = accelerationBuffer.first[1];
    int lastTimestamp = accelerationBuffer.last[1];
    print("Executing algorithm 2");
    while (lastTimestamp - firstTimestamp > peakInterval) {
      accelerationBuffer.removeAt(0);
      if (accelerationBuffer.isEmpty) break;
      firstTimestamp = accelerationBuffer.first[1];
    }
  }

  void triggerVibration() {
    Vibrate.vibrate();
  }

  Future<void> _saveAccelerometerData(List<double> event, int timestamp) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/accelerometer_data.csv';
    final file = File(path);

    String data = '$timestamp, ${event[0]}, ${event[1]}, ${event[2]}\n';
    await file.writeAsString(data, mode: FileMode.append);
  }

}

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
  late TapDetector _tapDetector;
  String _selectedAlgorithm = 'Algorithm 2';
  final List<String> _algorithms = ['Algorithm 1', 'Algorithm 2'];

  @override
  void initState() {
    super.initState();
    _tapDetector = TapDetectorAlgorithm1(requiredTaps: 3, sensibility: 8); // Algoritmo por defecto
    _tapDetector.start();
  }

  @override
  void dispose() {
    _tapDetector.stop();
    super.dispose();
  }

  void _onAlgorithmChanged(String? value) {
    if (value != null) {
      setState(() {
        _tapDetector.stop(); // Detener el algoritmo actual
        _selectedAlgorithm = value;

        // Cambiar al nuevo algoritmo
        if (_selectedAlgorithm == 'Algorithm 1') {
          _tapDetector = TapDetectorAlgorithm1(requiredTaps: 3, sensibility: 8);
        } else {
          _tapDetector = TapDetectorAlgorithm2();
        }
        _tapDetector.start(); // Iniciar el nuevo algoritmo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TapTapTap Detector'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Realiza un "taptaptap" para que el teléfono detecte los taps.'),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedAlgorithm,
              onChanged: _onAlgorithmChanged,
              items: _algorithms.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
// import 'dart:math';
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: TapTapTapDetector(),
//     );
//   }
// }
//
// class TapTapTapDetector extends StatefulWidget {
//   @override
//   _TapTapTapDetectorState createState() => _TapTapTapDetectorState();
// }
//
// class _TapTapTapDetectorState extends State<TapTapTapDetector> {
//
//   final int peakInterval = 1000; // Máximo intervalo entre los 3 taps en milisegundos
//   final int tapCountThreshold = 3; // Número mínimo de taps para desencadenar la vibración
//   List<List<dynamic>> accelerationBuffer = [];
//
//
//   // void smoothAccelerometerData() {
//   //   int windowSize = 3; // Tamaño de la ventana para el filtro de media móvil
//   //   List<List<dynamic>> smoothedBuffer = [];
//   //
//   //   for (int i = 0; i < accelerationBuffer.length; i++) {
//   //     if (i < windowSize - 1) {
//   //       // No hay suficientes datos para suavizar, simplemente agregamos el dato original
//   //       smoothedBuffer.add(accelerationBuffer[i]);
//   //     } else {
//   //       double sum = 0.0;
//   //       for (int j = i - windowSize + 1; j <= i; j++) {
//   //         sum += accelerationBuffer[j][0]; // Sumar los valores de aceleración
//   //       }
//   //       double smoothedValue = sum / windowSize; // Calcular el promedio
//   //       int timestamp = accelerationBuffer[i][1]; // Conservar el timestamp original
//   //       smoothedBuffer.add([smoothedValue, timestamp]); // Agregar el valor suavizado al nuevo buffer
//   //     }
//   //   }
//   //   accelerationBuffer = List.from(smoothedBuffer);
//   // }
//
//   @override
//   void initState() {
//     super.initState();
//     accelerometerEvents.listen((AccelerometerEvent event) {
//       double acceleration = _calculateMagnitude(event.x, event.y, event.z);
//       int currentTime = DateTime.now().millisecondsSinceEpoch;
//       accelerationBuffer.add([acceleration, currentTime]);
//       //print("${event.x.abs()} + ${event.y.abs()} +${event.z.abs()}");
//       // smoothAccelerometerData();
//
//       // Mantener el tamaño del búfer dentro del límite
//       _trimBuffer();
//
//       // for (var entry in accelerationBuffer) {
//       //   print("Acceleration value Y: ${entry[0]}");
//       // }
//
//       // Detectar picos en el búfer de aceleración
//       if (_hasPeak(accelerationBuffer)) {
//         triggerVibration();
//       }
//     });
//   }
//
//
//   double _calculateMagnitude(double x, double y, double z) {
//     return sqrt(x * x + y * y + z * z);
//   }
//
//   bool _hasPeak(List<List<dynamic>> data) {
//     int tapCount = 0;
//
//     // for (int i = 0; i < data.length ; i++) {
//     //   print(data[i][0] );
//     // }
//
//     for (int i = 10; i < data.length - 10; i++) {
//       if (data[i][0] > 2*data[i - 10][0] && 2*data[i + 10][0] <  data[i][0]) {
//         tapCount++;
//         print ("Tap count:   ${tapCount}");
//       }
//     }
//     return tapCount >= tapCountThreshold;
//   }
//
//   //Actualiza el buffer de datos para tener
//   // un buffer de 2000 ms de datos del acelerometro
//   void _trimBuffer() {
//     if (accelerationBuffer.isEmpty) return;
//
//     int firstTimestamp = accelerationBuffer.first[1];
//     int lastTimestamp = accelerationBuffer.last[1];
//
//     while (lastTimestamp - firstTimestamp > peakInterval) {
//       setState(() {
//         accelerationBuffer.removeAt(0);
//       });
//       if (accelerationBuffer.isEmpty) break;
//       firstTimestamp = accelerationBuffer.first[1];
//     }
//   }
//
//   void triggerVibration() {
//     print("Vibra!!!!!!!!!!!!!!!!1 TapTapTap detectado.");
//     Vibrate.vibrate();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TapTapTap Detector'),
//       ),
//       body: Center(
//         child: Text('Realiza un "taptaptap" para que el teléfono vibre'),
//       ),
//     );
//   }
// }
//
//
