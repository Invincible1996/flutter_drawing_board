library drawing_board;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
  ),
);

class DrawingBoard extends StatefulWidget {
  @override
  _DrawingBoardState createState() => _DrawingBoardState();
}

class _DrawingBoardState extends State<DrawingBoard> {
  List<Offset?> pointList = [];

  List<PointIndexModel> pointListWithIndex = [PointIndexModel(0, [])];

  var map = {};

  int curIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: Colors.grey,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      logger.v(pointListWithIndex.length);
                      var removeIndex = pointListWithIndex.length - 2;
                      if (pointListWithIndex.length > 1) {
                        pointListWithIndex.removeAt(removeIndex);
                        curIndex--;
                      }
                      logger.v(pointListWithIndex.length);
                    });
                  },
                  icon: Icon(Icons.redo),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.undo),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      pointListWithIndex.clear();
                      pointListWithIndex.add(PointIndexModel(0, []));
                      curIndex = 0;
                    });
                  },
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: MyPainter(pointListWithIndex),
              child: Listener(
                onPointerDown: (PointerDownEvent event) {
                  // if (event.kind != PointerDeviceKind.touch) return;
                  if (pointListWithIndex.isEmpty) {
                    pointListWithIndex.add(PointIndexModel(0, []));
                  }
                  setState(() {});
                },
                onPointerMove: (PointerMoveEvent event) {
                  // if (event.kind != PointerDeviceKind.touch) return;
                  // pointList.add(event.localPosition);
                  pointListWithIndex[curIndex].list.add(event.localPosition);
                  setState(() {});
                },
                onPointerUp: (PointerUpEvent event) {
                  // if (event.kind != PointerDeviceKind.touch) return;
                  curIndex++;
                  pointListWithIndex.add(PointIndexModel(curIndex, []));
                  setState(() {});
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<PointIndexModel> pointList;

  MyPainter(this.pointList);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    for (int i = 0; i < pointList.length; i++) {
      List<Offset?> curPoints = pointList[i].list;
      for (int i = 0; i < curPoints.length - 1; i++) {
        if (curPoints[i] != null && curPoints[i + 1] != null) {
          canvas.drawLine(curPoints[i]!, curPoints[i + 1]!, paint);
          // canvas.drawCircle(curPoints[i]!, paint.strokeWidth / 2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PointIndexModel {
  int? index;
  List<Offset?> list;

  PointIndexModel(this.index, this.list);
}
