import 'main.dart';
import 'package:flutter/material.dart';
import 'carList.dart';
import 'mapPage.dart';
import 'clientpage.dart';
import 'line.dart';
import 'poly.dart';
import 'utils.dart';

//**********MAP PAGE***********

//List result = ["S58", "S47", "A56", "A55"];

var mapConvert =
    MapConvert.fromCsv(mapWidth: 1000.0, mapHeight: 1000.0, padding: 100.0);
List<MapLine> mapLineList = MapLine.fromCsv(mapConvert);
List<MapArc> mapArcsList = MapArc.fromCsv(mapConvert);


//extract all the arc index from the given information, it consumes a string List
List takearc(List res) {
  List arc = [];
  for (var element in res) {
    if (element[0] == 'A') {
      arc.add(element);
    }
  }
  return arc;
}


//extract all the line index from the given information, it consumes a string List
List takeline(List res) {
  List arc = [];
  List line = [];
  for (var element in res) {
    if (element[0] == 'S') {
      line.add(element);
    }
  }
  return line;
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.value}) : super(key: key);

  final List<String> value;
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    //the pad size and map size
  final double _sheetH = 230.0;
  final double _mapP = 100.0;
  final double _mapW = 1000.0;
  final double _mapH = 1000.0;
  final TransformationController _tc = TransformationController();

  // state
  double tapX = 0;//The x-axis coordinate of the position clicked by the user
  double tapY = 0;//The y-axis coordinate of the position clicked by the user
  double startTapX = 0;//The x-axis coordinate of the start position
  double startTapY = 0;//The y-axis coordinate of the start position
  double endTapX = 0;////The x-axis coordinate of the end position
  double endTapY = 0;//The y-axis coordinate of the end position

  List<MapLine> drawLines = [];//the set for storing the line info
  List<MapArc> drawArcs = [];//the set for storing the arc info

  List<MapLine> mapLineList = [];//the set for storing the line info
  List<MapArc> mapArcsList = [];//the set for storing the arc info
  int tapTimes = 0;//how many times the user tapped

    
    //initialze the page
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var mapConvert =
        MapConvert.fromCsv(mapWidth: _mapW, mapHeight: _mapW, padding: _mapP);

    mapLineList = MapLine.fromCsv(mapConvert);
    mapArcsList = MapArc.fromCsv(mapConvert);

    _tc.value = Matrix4.identity()
      ..translate(-(_mapW + _mapP * 2) / 4, -(_mapH + _mapP * 2) / 4);
    tapX = _mapW / 2;
    tapY = _mapH / 2;
  }

  // void SeprateList(value) {
  //   for (var element in value) {
  //     if (element[0] == "S") {
  //       for (var index1 in mapLineList) {
  //         if (element[0] == index1.name) {
  //           drawLines.add(index1);
  //         }
  //       }
  //     } else {
  //       for (var index in mapArcsList) {
  //         if (element[0] == index.name) {
  //           drawArcs.add(index);
  //         }
  //       }
  //     }
  //   }
  // }

    
    //for build the current pathpage scene
  @override
  Widget build(BuildContext context) {
    String abc = ("${widget.value}");
    // void print1(String abc) {
    //   print("111111111111111111111111111111111");
    //   print(abc.substring(2, 6));
    // }

    // print1(abc);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 87, 85, 85),
        //  title: Text("${widget.value[0].substring(18)}"),
        title: Text("Path Result"),
        elevation: 0.0,
        leading: IconButton(//go back to mappage button
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          tooltip: 'Back',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapPage(
                  title: 'Map Page',
                ),
              ),
            );
          },
        ),
        actions: <Widget>[
          IconButton(//confirm button
              icon: const Icon(Icons.check, color: Colors.black),
              tooltip: 'confirm',
              onPressed: () {})
        ],
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: EdgeInsets.only(bottom: _sheetH),
          child: InteractiveViewer(
            constrained: false,
            minScale: 0.01,
            maxScale: 2,
            transformationController: _tc,
            child: Padding(
              padding: EdgeInsets.all(_mapP),
              child: GestureDetector(
                  child: Stack(
                children: [
                  Container(
                      width: _mapW,
                      height: _mapH,
                      child: null,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/citymap.png"),
                              fit: BoxFit.cover))),
                  Positioned(//put the start point pin
                    top: startTapY - 25,
                    left: startTapX - 25,
                    child: Image.asset(
                      'assets/map_pin.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  Positioned(//put the end point pin
                    top: endTapY - 25,
                    left: endTapX - 25,
                    child: Image.asset(
                      'assets/map_pin_end.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: OpenPainter(result1: abc),
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
}

//get the information from the Clientpage
class OpenPainter extends CustomPainter {
  String result1;
  OpenPainter({this.result1});

    //According to the information from the server, draw the arc and line on the map
  @override
  void paint(Canvas canvas, Size size) {
    int start;
    int end;
    // List path1 = result1.split('-');
      //For Line information
    for (var j = 0; j < result1.length; j++) {
      if (result1[j] == '\n') {
        start = j + 2;
        end = result1.length - 2;
      }
    }

    String path = result1.substring(start, end);
    List listresult = path.split(',');
    for (var i = 0; i < 4; i++) {
      print("this is the list of the result!!!!!");
      print(listresult[i]);
    }
    List L = takeline(listresult);
    List A = takearc(listresult);
    print("=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
    print(result1.substring(21, 36));
    // print(path1[0]);
    // print(path1[1]);
    print(start);
    print(end);
    var paint = Paint();
    paint.color = Colors.red;
    paint.strokeWidth = 5;
    paint.style = PaintingStyle.stroke;
    for (var E in L) {
      for (var e1 in mapLineList) {
        if (e1.name == E) {
          canvas.drawLine(
            Offset(e1.nodes[0].x, e1.nodes[0].y),
            Offset(e1.nodes[1].x, e1.nodes[1].y),
            paint,
          );
        }
      }
    }
      
      //For drawing the arc 
    // canvas.drawLine(
    //   Offset(477.49999999999994, 489.99999999999994),
    //   Offset(477.49999999999994, 323.3333333333333),
    //   paint,
    // );
    var paint1 = Paint();
    paint1.color = Colors.blue;
    paint1.style = PaintingStyle.stroke;
    // paint
    paint1.strokeWidth = 5;
    paint1.strokeCap = StrokeCap.round;
    for (var E in A) {
      for (var e1 in mapArcsList) {
        if (e1.name == E) {
          var startPoint = Offset(e1.nodes[0].x, e1.nodes[0].y);
          double cpx = 0;
          double cpy = 0;
          if (e1.type == ArcType.cw) {
            // Clockwise
            cpx = e1.nodes[0].x;
            cpy = e1.nodes[1].y;
          } else {
            cpx = e1.nodes[1].x;
            cpy = e1.nodes[0].y;
          }
          // var controlPoint1 = Offset(size.width / 2, size.height / 2);
          var controlPoint1 = Offset(cpx, cpy);
          // var controlPoint2 = Offset(3 * size.width / 4, size.height / 3);
          var endPoint = Offset(e1.nodes[1].x, e1.nodes[1].y);

          var path = Path()
            ..moveTo(startPoint.dx, startPoint.dy)
            ..quadraticBezierTo(
                controlPoint1.dx,
                controlPoint1.dy,
                // controlPoint1.dx, controlPoint1.dy,
                endPoint.dx,
                endPoint.dy)
            ..lineTo(endPoint.dx, endPoint.dy);

          // canvas.drawArc(Rect.fromPoints(startPoint, endPoint), 0, 45, false, paint);
          // path.close();
          // canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint)
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
