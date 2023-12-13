import 'dart:math';

import 'package:flutter/material.dart';
import 'package:situm_flutter/sdk.dart';
import 'package:vector_math/vector_math_64.dart';

// Fórmula para calcular la distancia euclidiana entre dos puntos
double calculateDistance(Location location1, Point point) {
  double x1 = location1.cartesianCoordinate.x;
  double y1 = location1.cartesianCoordinate.y;
  double x2 = point.cartesianCoordinate.x;
  double y2 = point.cartesianCoordinate.y;

  return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
}

Vector3 obtainRotationFromMatrix(Matrix3 rotationMatrix) {
  double r11 = rotationMatrix.storage[0];
  double r12 = rotationMatrix.storage[1];
  double r13 = rotationMatrix.storage[2];

  // ignore: unused_local_variable
  double r21 = rotationMatrix.storage[3];
  double r22 = rotationMatrix.storage[4];
  double r23 = rotationMatrix.storage[5];

  // ignore: unused_local_variable
  double r31 = rotationMatrix.storage[6];
  // ignore: unused_local_variable
  double r32 = rotationMatrix.storage[7];
  // ignore: unused_local_variable
  double r33 = rotationMatrix.storage[8];

  double rotationX = atan2(-r23, r22);
  double rotationY = atan2(r13, r11);
  double rotationZ = atan2(-r12, r11);

  return Vector3(rotationX, rotationY, rotationZ);
}

Vector3 applyTransformationMatrix(
    List<double> point, Matrix3 transformationMatrix) {
  return transformationMatrix * Vector3(point[0], point[1], 1);
}

Matrix3 computeTransformationMatrix(
    double angle, double dx, double dy, List<double> rotationOrigin) {
  // Create a translation matrix to rotate with respect to a given origin
  Matrix3 translationMatrix = Matrix3.columns(Vector3(1, 0, 0),
      Vector3(0, 1, 0), Vector3(-rotationOrigin[0], -rotationOrigin[1], 1));

  // Applies both (dx, dy) offset as well as rotation on Y
  Matrix3 transformationMatrix = Matrix3.columns(
      Vector3(cos(angle), sin(angle), 0),
      Vector3(-sin(angle), cos(angle), 0),
      Vector3(dx, dy, 1));

  // Create a translation back matrix to undo initial translation
  Matrix3 translationBackMatrix = Matrix3.columns(Vector3(1, 0, 0),
      Vector3(0, 1, 0), Vector3(rotationOrigin[0], rotationOrigin[1], 1));

  // Combine transformation matrices into a single transformation matrix
  Matrix3 relativeTransformationMatrix =
      translationBackMatrix * transformationMatrix * translationMatrix;

  return relativeTransformationMatrix;
}

void testTransformationMatrix() {
  // Example usage
  List<List<double>> originalPoints = [
    [168.8528742425964, 76.4548991879338],
    [78.730527802388, 160.87210985994304],
    [80.13393555615409, 78.49627594609343],
    [169.74518848088155, 22.34082514745507],
    [157.28252052874447, 161.5045273399072],
    [159.88739144573634, 21.861734484514734],
    [157.15683273141008, 115.96345180564369],
    [157.1216547878905, 101.48728722094953],
    [157.25300262616094, 131.4016039510251],
    [122.52218472813405, 29.33997495469535],
    [168.92065862799637, 92.9446501289153],
    [158.49094214302454, 76.85321391871193],
    [158.69225388409563, 92.97760437525864],
    [78.84604036531914, 23.77124993977146],
    [157.1678318663741, 146.817184075046]
  ];

  List<List<double>> transformedPoints = [];
  List<double> rotationOrigin = [20, 20];
  Matrix3 transformationMatrix =
      computeTransformationMatrix(pi / 4, 120, 34, rotationOrigin);

  for (List<double> point in originalPoints) {
    Vector3 transformedPoint =
        applyTransformationMatrix(point, transformationMatrix);
    transformedPoints.add([transformedPoint.x, transformedPoint.y]);
  }

  // Print the transformed points
  printALBA(transformedPoints.toString());
}

Future<List<Vector3>?> generateTransformedPositions(
    List<Point> points, Matrix3 transformationMatrix) async {
  List<Vector3> transformedPositions = [];

  for (var point in points) {
    List<double> position = [
      point.cartesianCoordinate.x,
      point.cartesianCoordinate.y
    ];
    Vector3 transformedPosition =
        applyTransformationMatrix(position, transformationMatrix);

    // Should probably fix this in the transformation matrix
    // Inverse y component to fit camera coordinate system
    // -z
    // |
    // |___ x
    transformedPosition.z = -transformedPosition.y;
    // Keep height constant
    transformedPosition.y = 1;

    // Agregar la posición transformada a la lista
    transformedPositions.add(transformedPosition);
  }

  return transformedPositions;
}

List<Vector3> generateInterpolatedPoints(
    List<Vector3> originalPoints, int numberOfInterpolations) {
  List<Vector3> interpolatedPoints = [];

  // Linear interpolation between each pair of points
  for (int i = 0; i < originalPoints.length - 1; i++) {
    Vector3 start = originalPoints[i];
    Vector3 end = originalPoints[i + 1];

    for (int j = 0; j <= numberOfInterpolations; j++) {
      double t = j / numberOfInterpolations;
      Vector3 interpolatedPoint = start * (1 - t) + end * t;
      interpolatedPoints.add(interpolatedPoint);
    }
  }

  return interpolatedPoints;
}

void printALBA(String msg) {
  debugPrint('***** ALBA $msg');
}
