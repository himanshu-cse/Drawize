import 'dart:async';

import 'package:drawize/home_screen.dart';
import 'package:drawize/models/my_custom_painter.dart';
import 'package:drawize/models/touch_points.dart';
import 'package:drawize/scoreboard.dart';
import 'package:drawize/waiting_lobby_screen.dart';
import 'Leaderboardscreen.dart';

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
  List<Widget> textBlankWidget = [];
  final ScrollController _scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  List<Map> messages = [];
  int guessedUserCounter = 0;
  int _timeLeft = 60;
  late Timer _timer;
  var scaffoldkey = GlobalKey<ScaffoldState>();
  List<Map> scoreboard = [];
  bool Textinputclose = false;
  List<Map> Leaderboard = [];
  bool leaderboardscreen = false;

  @override
  void initState() {
    super.initState();
    connect();
  }

  void swap(List<Map> map, int x, int y) {
    var temp = map[x];
    map[x] = map[y];
    map[y] = temp;
  }

  void selectionsort(List<Map> map) {
    var i, j, min_idx, n;
    n = map.length;
    for (int i = 0; i < n - 1; i++) {}
  }

  void startTimer() {
    const onesec = Duration(seconds: 1);
    _timer = Timer.periodic(onesec, (Timer time) {
      if ((_timeLeft == 0) &&
          ((dataOfRoom['turn']['nickname'] == widget.data['nickname']))) {
        _socket.emit('change-turn', dataOfRoom['name']);
        setState(() {
          _timer.cancel();
        });
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void renderTextBlank(String text) {
    textBlankWidget.clear();
    for (int i = 0; i < text.length; i++) {
      textBlankWidget.add(const Text('_', style: TextStyle(fontSize: 30)));
    }
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
        print(roomData['word']);
        setState(() {
          renderTextBlank(roomData['word']);
          dataOfRoom = roomData;
        });
        // print(roomData);
        // print(dataOfRoom);
        // print('object');
        if (roomData['isJoin'] != true) {
          //start the timer
          startTimer();
          scoreboard.clear();
          for (int i = 0; i < roomData['players'].length; i++) {
            setState(() {
              scoreboard.add({
                'username': roomData['players'][i]['nickname'],
                'score': roomData['players'][i]['points'].toString(),
              });
            });
          }
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

      //listening to message callback
      _socket.on('msg', (messageData) {
        setState(() {
          messages.add(messageData);
          guessedUserCounter = messageData['guessedUserCounter'];
        });

        if ((guessedUserCounter == dataOfRoom['players'].length - 1) &&
            (dataOfRoom['turn']['nickname'] == widget.data['nickname'])) {
          _socket.emit('change-turn', dataOfRoom['name']);
        }

        _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 40,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      });

      // listening to turn change request

      _socket.on('change-turn', (data) {
        String oldWord = dataOfRoom['word'];
        // print('change-turn');
        // print(data['turnIndex']);
        showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  dataOfRoom = data;
                  renderTextBlank(data['word']);
                  Textinputclose = false;
                  guessedUserCounter = 0;
                  _timeLeft = 60;
                  points.clear();
                });
                Navigator.of(context).pop();
                _timer.cancel();
                startTimer();
              });
              return AlertDialog(
                title: Center(
                  child: Text('Word was $oldWord'),
                ),
              );
            });
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

      // listening for input close
      _socket.on('closeInput', (data) {
        _socket.emit('updatescore', widget.data['name']);
        setState(() {
          Textinputclose = true;
        });
      });

      // listening for update score
      _socket.on('updatescore', ((data) {
        scoreboard.clear();
        for (int i = 0; i < data['players'].length; i++) {
          setState(() {
            scoreboard.add({
              'username': data['players'][i]['nickname'],
              'score': data['players'][i]['points'].toString(),
            });
          });
        }
      }));

      //listening for notcorrectgame
      _socket.on(
          'notcorrectgame',
          (data) => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        message: data,
                      )),
              (route) => false));
    });
  }

  @override
  void dispose() {
    _socket.dispose();
    _timer.cancel();
    super.dispose();
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
      key: scaffoldkey,
      drawer: playerScoreboard(scoreboard),
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
                            child: dataOfRoom['turn']['nickname'] ==
                                    widget.data['nickname']
                                ? GestureDetector(
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
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        child: RepaintBoundary(
                                          child: CustomPaint(
                                            size: Size.infinite,
                                            painter: MyCustomPainter(
                                                pointsList: points),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.expand(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      child: RepaintBoundary(
                                        child: CustomPaint(
                                          size: Size.infinite,
                                          painter: MyCustomPainter(
                                              pointsList: points),
                                        ),
                                      ),
                                    ),
                                  )),
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
                        dataOfRoom['turn']['nickname'] !=
                                widget.data['nickname']
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: textBlankWidget,
                              )
                            : Center(
                                child: Column(children: [
                                  Text('${dataOfRoom['turn']['nickname']}'),
                                  (Text('${widget.data['nickname']}')),
                                  Text(
                                    dataOfRoom['word'],
                                    style: const TextStyle(fontSize: 30),
                                  )
                                ]),
                              ),
                        Container(
                          height: height * 0.3,
                          child: ListView.builder(
                              controller: _scrollController,
                              shrinkWrap: true,
                              itemCount: messages.length,
                              itemBuilder: ((context, index) {
                                var msg = messages[index].values;
                                return ListTile(
                                  title: Text(msg.elementAt(0),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    msg.elementAt(1),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                );
                              })),
                        )
                      ],
                    ),
                    dataOfRoom['turn']['nickname'] != widget.data['nickname']
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                readOnly: Textinputclose,
                                controller: controller,
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty) {
                                    Map map = {
                                      'username': widget.data['nickname'],
                                      'msg': value.trim(),
                                      'word': dataOfRoom['word'],
                                      'roomName': dataOfRoom['name'],
                                      'guessedUserCounter': guessedUserCounter,
                                      'totalTime': 60,
                                      'timetaken': 60 - _timeLeft,
                                    };
                                    _socket.emit('msg', map);
                                    controller.clear();
                                  }
                                },
                                autocorrect: false,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  filled: true,
                                  fillColor: const Color(0xffF5F5FA),
                                  hintText: 'Type your guess',
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                            ),
                          )
                        : Container(),
                    SafeArea(
                        child: IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                      onPressed: () => scaffoldkey.currentState!.openDrawer(),
                    ))
                  ],
                )
              : WaitingLobbyScreen(
                  lobbyName: dataOfRoom['name'],
                  noOfPlayers: dataOfRoom['players'].length,
                  occupancy: dataOfRoom['occupancy'],
                  isPartyLeader: widget.isPartyLeader,
                  players: dataOfRoom['players'],
                )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: FloatingActionButton(
          onPressed: () {},
          elevation: 7,
          backgroundColor: Colors.white,
          child: Text(
            '$_timeLeft',
            style: const TextStyle(color: Colors.black, fontSize: 10),
          ),
        ),
      ),
    );
  }
}
