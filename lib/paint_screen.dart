import 'package:drawize/models/my_custom_painter.dart';
import 'package:drawize/models/touch_points.dart';
import 'package:drawize/waiting_lobby_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PaintScreen extends StatefulWidget {
  final Map<String, String> data;
  final String screenFrom;
  final String nickname;
  final bool isPartyLeader;
  const PaintScreen(
      {super.key,
      required this.data,
      required this.screenFrom,
      required this.nickname,
      required this.isPartyLeader});

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

    //emitting data to index .js

    if (widget.screenFrom == 'createRoom') {
      _socket.emit('create-game', widget.data);
    } else {
      // print(widget.data);
      _socket.emit('join-game', widget.data);
    }

    //listen to socket
    _socket.onConnect((data) {
      print('connected!');

      //listening to new entry in room
      _socket.on('updateRoom', (roomData) {
        setState(() {
          dataOfRoom = roomData;
        });
        // print(roomData);
        // print(dataOfRoom);
        // print('object');
        if (roomData['isJoin'] != true) {
          //start the timer
        }
      });

      //listening to points changed in painting screen
      _socket.on('points', (point) {
        // print('takes');
        // print((point['details']['dx']).toDouble());
        if (point['details'] != null) {
          // print((point['details']['dx']).toDouble());
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
        }
      });

      //listening to color change request

      _socket.on('color-change', (colorString) {
        int value = int.parse(colorString, radix: 16);
        // print(value);
        Color otherColor = Color(value);
        // print(otherColor);
        setState(() {
          selectedColor = otherColor;
        });
      });

      //listening for stroke change

      _socket.on('stroke-width', (value) {
        // print(value);
        setState(() {
          strokeWidth = value.toDouble();
        });
      });

      //listening for clean-screen

      _socket.on('clear', (data) {
        // print(data);
        setState(() {
          points.clear();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void selectColor() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Choose Color '),
                content: SingleChildScrollView(
                    child: BlockPicker(
                        pickerColor: selectedColor,
                        onColorChanged: (color) {
                          String colorString = color.toString();
                          String valueString =
                              colorString.split('(0x')[1].split(')')[0];
                          // print(colorString);
                          // print(valueString);
                          Map map = {
                            'color': valueString,
                            'roomName': widget.data['name']
                          };
                          // print(map);
                          _socket.emit('color-change', map);
                        })),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'))
                ],
              ));
    }

    // print(dataOfRoom);

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade100,
      // ignore: unnecessary_null_comparison
      body: dataOfRoom != null
          ? dataOfRoom['isJoin'] != true
              ? Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width,
                          height: height * 0.55,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              // print(details.localPosition.dx);
                              _socket.emit('paint', {
                                'details': {
                                  'dx': details.localPosition.dx,
                                  'dy': details.localPosition.dy,
                                },
                                'roomName': widget.data['name'],
                              });
                            },
                            onPanStart: (details) {
                              // print(details.localPosition.dx);
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    size: Size.infinite,
                                    painter:
                                        MyCustomPainter(pointsList: points),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Row(children: [
                          IconButton(
                            icon: Icon(Icons.color_lens, color: selectedColor),
                            onPressed: () {
                              selectColor();
                            },
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
                                    'roomName': widget.data['name'],
                                  };
                                  // print(map);
                                  _socket.emit('stroke-width', map);
                                }),
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.layers_clear, color: selectedColor),
                            onPressed: () {
                              _socket.emit('clear-screen', widget.data['name']);
                              // print(widget.data['name']);
                            },
                          ),
                        ]),
                      ],
                    ),
                  ],
                )
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  isPartyLeader: widget.isPartyLeader,
                  players: dataOfRoom['players'],
                )
          : Center(
              child: const CircularProgressIndicator(),
            ),
    );
  }
}
