import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_grow_tree/grow_tree_painter.dart';

class GrowTreePage extends StatefulWidget {
  GrowTreePage({Key key}) : super(key: key);

  @override
  _GrowTreePageState createState() => _GrowTreePageState();
}

class _GrowTreePageState extends State<GrowTreePage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  List<Point> leafList = [];
  List<Point> branchList = [];

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _animation = Tween(begin: .0, end: 1.0).animate(_controller);
    _controller.forward();
    var branch = new TreeMaker().getPoints();
    branchList.addAll(branch);
    var leafs = new TreeMaker().getLeafPoints();
    leafList.addAll(leafs);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: CustomPaint(
            painter: GrowTreePainterUpgrade(
                percent: _controller.value,
                branchList: branchList,
                leafList: leafList),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
