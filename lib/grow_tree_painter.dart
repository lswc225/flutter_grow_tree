import 'dart:math';
import 'dart:developer' as dev;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class GrowTreePainterUpgrade extends CustomPainter {
  final double percent;

  Paint _paint = Paint()
    ..strokeWidth = 1
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  List<Point> rangePoints = [];
  List<Point> leafPoints = [];

  // scale factor
  double CROWN_RADIUS_FACTOR;

  double STAND_FACTOR;

  double BRANCHES_FACTOR;

  GrowTreePainterUpgrade({this.percent, branchList, leafList}) {
    // scale factor
    CROWN_RADIUS_FACTOR = 0.35;
    STAND_FACTOR = (CROWN_RADIUS_FACTOR / 0.28);
    BRANCHES_FACTOR = 1.3 * STAND_FACTOR;

    var endIndex = (percent * branchList.length).toInt();
    var range = branchList.getRange(0, endIndex);
    rangePoints.addAll(range);

    var endLeafIndex = (percent * leafList.length).toInt();
    var leafRange = leafList.getRange(0, endLeafIndex);
    leafPoints.addAll(leafRange);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var resolutionFactor = size.height / 1250;
    double snapshotWidth = 816 * STAND_FACTOR * resolutionFactor;
    double branchesWidth = 375 * BRANCHES_FACTOR * resolutionFactor;
    double branchesHeight = 490 * BRANCHES_FACTOR * resolutionFactor;
    double branchesDx = (snapshotWidth - branchesWidth) / 2 - 40 * STAND_FACTOR;
    double branchesDy = size.height - branchesHeight;

    canvas.save();
    canvas.translate(branchesDx, branchesDy);
    _paint.color = Colors.brown;

    for (var point in rangePoints) {
      canvas.save();

      canvas.scale(BRANCHES_FACTOR * resolutionFactor,
          BRANCHES_FACTOR * resolutionFactor);
      canvas.translate(point.growX, point.growY);
      canvas.drawCircle(Offset.zero, point.radius, _paint);

      canvas.restore();

      leafPoints.forEach((element) {
        if (element.growX.toInt() == point.growX.toInt() &&
            element.growY.toInt() == point.growY.toInt()) {
          element.isShow = false;
        }
      });
    }

    _paint.color = Colors.green;
    for (var point in leafPoints) {
      if (point.isShow ?? false == false) {
        continue;
      }
      canvas.save();

      canvas.scale(BRANCHES_FACTOR * resolutionFactor,
          BRANCHES_FACTOR * resolutionFactor);
      canvas.translate(point.growX, point.growY);
      Path path = Path();
      path.relativeQuadraticBezierTo(-18, 4, 0, 20);
      path.relativeQuadraticBezierTo(18, -14, 0, -20);
      canvas.rotate(point.rotateAngle);
      canvas.drawPath(path, _paint);

      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Point {
  double radius;
  double growX;
  double growY;
  double rotateAngle;
  bool isShow;

  Point(this.radius, this.growX, this.growY, {this.rotateAngle});
}

class TreeMaker {
  // id, parentId, bezier control points(3 points, in 6 columns), max radius，length
  List<List<int>> datas = [
    [0, -1, 217, 490, 252, 60, 182, 10, 30, 100],
    [1, 0, 222, 310, 137, 227, 22, 210, 13, 100],
    [3, 0, 232, 255, 282, 166, 362, 155, 12, 100],
    [5, 0, 221, 91, 219, 58, 216, 27, 3, 40],
    [6, 0, 228, 207, 95, 57, 10, 54, 9, 80],
    [9, 0, 228, 167, 290, 62, 360, 31, 6, 100],
    [2, 1, 132, 245, 116, 240, 76, 205, 2, 40],
    [4, 3, 260, 210, 330, 219, 343, 236, 3, 80],
    [7, 6, 109, 96, 65, 63, 53, 15, 2, 40],
    [8, 6, 180, 155, 117, 125, 77, 140, 4, 60],
    [10, 9, 272, 103, 328, 87, 330, 81, 2, 80]
  ];

  List<Point> getPoints() {
    int n = datas.length;

    List<Point> points = [];
    for (int i = 0; i < n; i++) {
      List<int> data = datas[i];

      var radius = data[8].toDouble();
      var maxLen = data[9].toDouble();
      var cp1 = Offset(data[2].toDouble(), data[3].toDouble());
      var cp2 = Offset(data[4].toDouble(), data[5].toDouble());
      var cp3 = Offset(data[6].toDouble(), data[7].toDouble());

      for (double j = 1; j <= maxLen; j += 0.6) {
        radius *= 0.985;
        if (radius <= 0.5) {
          radius = 0.5;
        }
        var t = j / maxLen;
        double c0 = (1 - t) * (1 - t);
        double c1 = 2 * t * (1 - t);
        double c2 = t * t;
        var growX = c0 * cp1.dx + c1 * cp2.dx + c2 * cp3.dx;
        var growY = c0 * cp1.dy + c1 * cp2.dy + c2 * cp3.dy;

        points.add(Point(radius, growX, growY));
      }
    }

    return points;
  }

  List<Point> getLeafPoints() {
    int n = datas.length;

    List<Point> points = [];
    for (int i = 0; i < n; i++) {
      List<int> data = datas[i];

      var radius = data[8].toDouble();
      var maxLen = data[9];
      var cp1 = Offset(data[2].toDouble(), data[3].toDouble());
      var cp2 = Offset(data[4].toDouble(), data[5].toDouble());
      var cp3 = Offset(data[6].toDouble(), data[7].toDouble());

      for (double j = 1; j <= maxLen; j += 7) {
        radius *= 0.9;
        if (radius <= 5) {
          radius = 5;
        }
        var t = j / maxLen;

        if (t > 0.3) {
          if (i == 0 && t < 0.7) {
            continue;
          }
          double c0 = (1 - t) * (1 - t);
          double c1 = 2 * t * (1 - t);
          double c2 = t * t;
          var growX = c0 * cp1.dx + c1 * cp2.dx + c2 * cp3.dx;
          var growY = c0 * cp1.dy + c1 * cp2.dy + c2 * cp3.dy;
          var angle = Random().nextInt((2 * pi).toInt()).toDouble();

          points.add(Point(radius, growX, growY, rotateAngle: angle));
        }
      }
    }

    return points;
  }
}
