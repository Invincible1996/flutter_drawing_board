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

  ///存放所有坐标
  List<PointIndexModel> pointListWithIndex = [PointIndexModel(0, [])];

  ///原始数据 用来实现反撤销的功能
  List<PointIndexModel> originList = [PointIndexModel(0, [])];

  /// 用index来记录每一帧的绘制
  int curIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          child: CustomPaint(
            painter: MyPainter(pointListWithIndex),
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                // if (event.kind != PointerDeviceKind.touch) return;
                if (pointListWithIndex.isEmpty) {
                  pointListWithIndex.add(PointIndexModel(0, []));
                  originList.add(PointIndexModel(0, []));
                }
                setState(() {});
              },
              onPointerMove: (PointerMoveEvent event) {
                // if (event.kind != PointerDeviceKind.touch) return;
                pointListWithIndex[curIndex].list.add(event.localPosition);
                originList[curIndex].list.add(event.localPosition);
                setState(() {});
              },
              onPointerUp: (PointerUpEvent event) {
                // if (event.kind != PointerDeviceKind.touch) return;
                curIndex++;
                pointListWithIndex.add(PointIndexModel(curIndex, []));
                originList.add(PointIndexModel(curIndex, []));
                setState(() {});
              },
              child: Container(
                color: Colors.transparent,
                // child: ListView.builder(
                //   itemBuilder: (context, index) => Container(
                //     margin: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                //     width: 300,
                //     height: 150,
                //     color: Colors.lightGreen[100 * index],
                //   ),
                // ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: Container(
            width: MediaQuery.of(context).size.width * .65,
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.title),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      logger.v(pointListWithIndex.length);
                      var removeIndex = pointListWithIndex.length - 2;
                      if (pointListWithIndex.length > 1) {
                        pointListWithIndex.removeAt(removeIndex);
                        curIndex--;
                      } else {
                        logger.v(pointListWithIndex.length);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('无法撤销'),
                          duration: Duration(milliseconds: 500),
                        ));
                      }
                    });
                  },
                  icon: Icon(Icons.undo),
                ),
                IconButton(
                  onPressed: () {
                    if (originList.length != pointListWithIndex.length) {
                      var removeIndex = pointListWithIndex.length - 1;
                      curIndex++;
                      pointListWithIndex.insert(removeIndex, originList[removeIndex]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('无法还原'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.redo),
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
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        )
      ],
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
