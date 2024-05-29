import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



// Clase base abstracta para los detectores de taps
abstract class TapDetector {
  void start();
  void stop();
}

class AlgorithmConfig {
  int _sensibility;

  AlgorithmConfig(this._sensibility);

  int get sensibility => _sensibility;

  set sensibility(int value) {
    _sensibility = value;
  }
}

class TapDetectorAlgorithm1 extends TapDetector {
  static const String TAG = 'TapDetector';

  static const int DEFAULT_NUM_TAPS = 3;
  static const int MIN_NUM_TAPS = 1;
  static const int MIN_SENSIBILITY = 0;
  static const int MAX_SENSIBILITY = 10;

  static const int INIT = 0;
  static const int PEAK = 1;
  static const int VALLEY = 2;
  static const int TAP_DETECTED = 3;

  final int requiredTaps;
  int currentTaps = 3;
  final AlgorithmConfig config;
  late double threshold;
  late double localThresh;
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
  double peakV = 0;
  double valleyV = 0;
  static const double MAX_TIME_BETWEEN_TAPS = 0.35;

  bool isRunning = false;
  late StreamSubscription<AccelerometerEvent> _subscription;
  int accTime = 0;

  TapDetectorAlgorithm1({required this.requiredTaps, required this.config}) : currentTaps = 0 {
    _updateThreshold();
  }

  void _updateThreshold() {
    threshold = 2 * (10 - config.sensibility) + 10;
    localThresh = threshold / 3;
  }

  @override
  void start() {
    stop();
    print('$TAG: Started Tap Detector with requiredTaps=$requiredTaps and sensibility=${config.sensibility}');
    _subscription = accelerometerEvents.listen((event) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      threshold = 2 * (10 - config.sensibility) + 10;
      localThresh = threshold / 3;


      print("Executing algorithm 1 with sensibility: ${config.sensibility}  threshold: ${localThresh}");

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
}


class TapDetectorAlgorithm2 extends TapDetector {
  final int peakInterval = 1500; // Máximo intervalo entre los 3 taps en milisegundos
  final int tapCountThreshold = 3; // Número mínimo de taps para desencadenar la vibración
  List<List<dynamic>> accelerationBuffer = [];
  late StreamSubscription<AccelerometerEvent> _streamSubscription;
  final int windowSize = 10;
  final AlgorithmConfig config;
  double smoothingFactor = 2.0;

  TapDetectorAlgorithm2({required this.config});

  @override
  void start() {
    _streamSubscription = accelerometerEvents.listen((AccelerometerEvent event) {

      List<List<double>> rawAcceleration = [[event.x, event.y, event.z]];
      List<double> smoothedAcceleration = [
        applyCustomSmoothingFilterLastValue(rawAcceleration.map((e) => e[0]).toList(), windowSize, smoothingFactor),
        applyCustomSmoothingFilterLastValue(rawAcceleration.map((e) => e[1]).toList(), windowSize, smoothingFactor),
        applyCustomSmoothingFilterLastValue(rawAcceleration.map((e) => e[2]).toList(), windowSize, smoothingFactor)
      ];

      int currentTime = DateTime.now().millisecondsSinceEpoch;
      accelerationBuffer.add([smoothedAcceleration, currentTime]);
      print("Executing algorithm 2 with sensibility ${config.sensibility}");
      _trimBuffer();
      if (_hasPeak(accelerationBuffer)) {
        triggerVibrationAndSendAlert();
      }
      _saveAccelerometerData(smoothedAcceleration, currentTime);
      saveRaw(rawAcceleration, currentTime);


    });
  }
  Future<void> saveRaw(List<List<double>> rawAcceleration, int currentTime) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/accelerometer_data_raw.csv';
    final file = File(path);
    String data = '$currentTime, ${rawAcceleration[0][0]}, ${rawAcceleration[0][1]}, ${rawAcceleration[0][2]}\n';
    await file.writeAsString(data, mode: FileMode.append);
  }
  @override
  void stop() {
    _streamSubscription.cancel();
  }

  double calcularModulo(List<double> vector) {
    if (vector.length != 3) {
      throw ArgumentError("El vector debe tener exactamente tres posiciones");
    }

    double modulo = 0;
    for (var componente in vector) {
      modulo += componente * componente;
    }
    return math.sqrt(modulo);
  }

  bool _hasPeak(List<List<dynamic>> data) {
    int tapCount = 0;
    for (int i = 1; i < data.length - 1; i++) {
      //Componente z es la perpendicular al telefono
      if((data[i][0][1]>data[i][0][2]) || (data[i][0][0]>data[i][0][2])){ //El teléfono está en vertical.

        double magnitude = data[i][0][2];
        double prevMagnitude = data[i - 1][0][2];
        double nextMagnitude = data[i + 1][0][2];


        print(" ${prevMagnitude}  ${magnitude}  ${nextMagnitude}  ${config.sensibility}  ${tapCount}");
        // print("${(magnitude - prevMagnitude)} ${(magnitude - nextMagnitude)}  ${tapCount}");
        // print("");

        if ((magnitude - prevMagnitude) > config.sensibility  || (magnitude - nextMagnitude) > config.sensibility ) {
          tapCount++;
        }

      }

    }

    return tapCount >= tapCountThreshold;
  }

  double applyCustomSmoothingFilterLastValue(List<double> data, int windowSize, double smoothingFactor) {
    if (data.isEmpty) {
      return 0.0;
    }

    List<double> smoothedData = List<double>.filled(data.length, 0.0);
    int halfWindowSize = windowSize ~/ 2;

    for (int i = 0; i < data.length; i++) {
      int start = math.max(0, i - halfWindowSize);
      int end = math.min(data.length - 1, i + halfWindowSize);

      double sum = 0.0;
      double weightSum = 0.0;

      for (int j = start; j <= end; j++) {
        double weight = math.pow(smoothingFactor, (j - i).abs()).toDouble();
        sum += data[j] * weight;
        weightSum += weight;
      }

      smoothedData[i] = sum / weightSum;
    }

    return smoothedData.last;
  }

  void _trimBuffer() {
    if (accelerationBuffer.isEmpty) return;

    int firstTimestamp = accelerationBuffer.first[1];
    int lastTimestamp = accelerationBuffer.last[1];
    while (lastTimestamp - firstTimestamp > peakInterval) {
      accelerationBuffer.removeAt(0);
      if (accelerationBuffer.isEmpty) break;
      firstTimestamp = accelerationBuffer.first[1];
    }
  }

  Future<void> triggerVibrationAndSendAlert() async {
    Vibrate.vibrate();
    // URL del endpoint
    final url = Uri.parse('https://dashboard.situm.com/api/v1/alarms');
    final Map<String, dynamic> data = {
      "type": "DANGER",
      "building_id": 12469,
      "x": 20.25,
      "y": 20.47,
      "floor_id": 38718
    };
    String accessToken ="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzZjA5ZGQ1YS00MmY1LTRkYTAtOTZlNS0zNzBhMWZmNjlmMzIiLCJlbWFpbCI6ImNvcmVAc2l0dW0uY29tIiwib3JnYW5pemF0aW9uX3V1aWQiOiIxZDc1NGVmZi0wOWEyLTQzNWMtODJkNS03MjcwY2IxOTM3ODAiLCJyb2xlIjoiQURNSU5fT1JHIiwiaWF0IjoxNzE2ODk4MzM4LCJpbXBlcnNvbmF0ZSI6IjkwM2UwNGNiLWJjZjktNDgzZC1iMWMxLWU1ZTJmZDRjZTgxNyIsImV4cCI6MTcxNjk4NDczOH0.15MgXV3Ip4ZxM3VmV7u0dlQKndISKmwpI4CsMHJqRzI";
// Hacer la solicitud POST con el encabezado de autorización
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken', // Agrega el token de acceso aquí
      },
      body: jsonEncode(data), // Convertir los datos a JSON
    );

    // Verificar la respuesta
    if (response.statusCode == 201) {
      print('Post creado con éxito: ${response.body}');
    } else {
      print('Error al crear el post: ${response.statusCode}');
    }
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
  deleteSavedFile().then((_) {
    runApp(MyApp());
  });
}

Future<void> deleteSavedFile() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/accelerometer_data.csv');
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    print('Error al borrar el archivo: $e');
  }
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
  final List<String> _algorithms = ['Algorithm 2', 'Algorithm 1'];
  late TextEditingController _thresholdController;
  late AlgorithmConfig _config;

  @override
  void initState() {
    super.initState();
    // Inicializa la configuración con valores diferentes para cada algoritmo
    _config = AlgorithmConfig(_selectedAlgorithm == 'Algorithm 2' ? 7 : 8);
    _tapDetector = _selectedAlgorithm == 'Algorithm 2'
        ? TapDetectorAlgorithm2(config: _config)
        : TapDetectorAlgorithm1(requiredTaps: 3, config: _config);
    _tapDetector.start();
    _thresholdController = TextEditingController();
  }

  @override
  void dispose() {
    _tapDetector.stop();
    _thresholdController.dispose();
    super.dispose();
  }

  void _onAlgorithmChanged(String? value) {
    if (value != null) {
      setState(() {
        _tapDetector.stop();
        _selectedAlgorithm = value;
        // Actualiza la configuración según el algoritmo seleccionado
        _config.sensibility = _selectedAlgorithm == 'Algorithm 2' ? 7 : 8;
        _tapDetector = _selectedAlgorithm == 'Algorithm 2'
            ? TapDetectorAlgorithm2(config: _config)
            : TapDetectorAlgorithm1(requiredTaps: 3, config: _config);
        _tapDetector.start();
      });
    }
  }

  void _onThresholdChanged(String value) {
    setState(() {
      _config.sensibility = int.parse(value);
    });
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
            SizedBox(height: 20),
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sensibilidad',
                hintText: 'Ingrese un valor numérico',
              ),
              onChanged: _onThresholdChanged,
            ),
          ],
        ),
      ),
    );
  }
}
