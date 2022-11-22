import 'package:drawize/models/my_custom_painter.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:drawize/models/touch_points.dart';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map data;
  final String screenFrom;
  PaintScreen({required this.data, required this.screenFrom});

  @override
  State<PaintScreen> createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  late IO.Socket _socket;
  // String dataRoom = "";

  Map dataOfRoom = {};
  List<TouchPoints> points = [];
  StrokeCap strokeType = StrokeCap.round;
  Color selectedColor = Colors.black;
  double opacity = 1;
  double strokeWidth = 2;

  @override
  void initState() {
    super.initState();
    connect();
  }

//socket.io client
  void connect() {
    _socket = IO.io('http://192.168.56.1:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false
    });
    _socket.connect();

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create_game', widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print('connected!');
      _socket.on('updateRoom', (roomData) {
        setState(() {
          dataOfRoom = roomData;
        });
        if (roomData['isJoin'] != true) {
          //start the timer
        }
      });

      _socket.on('points', (point) {
        setState(() {
          points.add(TouchPoints(
              points: Offset((point['details']['dx']).toDouble(),
                  (point['details']['dy']).toDouble()),
              paint: Paint()
                ..strokeCap = strokeType
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // void selectColor() {
    //   showDialog(context: context, builder: (context) => AlertDialog(
    //     title: const Text('Choose Color '),
    //     content: SingleChildScrollView(
    //       child: BlockPicker(pickerColor: selectedColor, onColorChanged: (color) {
    //         String colorString = color.toString();
    //         String valueString = colorString.split('(0x')[1].split(')')[0];
    //         print(colorString);
    //         print(valueString);
    //         Map map = {
    //           'color': valueString,
    //           'roomName': dataOfRoom['name']
    //         };
    //         _socket.emit('color-change', map);
    //       })
    //     ),
    //   ));
    // }

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width,
                height: height * 0.55,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanStart: (details) {
                    print(details.localPosition.dx);
                    _socket.emit('paint', {
                      'details': {
                        'dx': details.localPosition.dx,
                        'dy': details.localPosition.dy,
                      },
                      'roomName': widget.data['name'],
                    });
                  },
                  onPanEnd: (details) {
                    _socket.emit('paint', {
                      'details': null,
                      'roomName': widget.data['name'],
                    });
                  },
                  child: SizedBox.expand(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: MyCustomPainter(pointsList: points),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(children: [
                IconButton(
                  icon: Icon(Icons.color_lens, color: selectedColor),
                  onPressed: () {},
                ),
                Expanded(
                  child: Slider(
                      min: 1.0,
                      max: 10,
                      label: "Strokewidth $strokeWidth",
                      activeColor: selectedColor,
                      value: strokeWidth,
                      onChanged: (double value) {
                        Map map = {
                          'value': value,
                          'roomName': dataOfRoom['name']
                        };
                        _socket.emit('stroke-width', map);
                      }),
                ),
                IconButton(
                  icon: Icon(Icons.layers_clear, color: selectedColor),
                  onPressed: () {},
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
