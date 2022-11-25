import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "dart:math";

class WaitingLobbyScreen extends StatefulWidget {
  final int occupancy;
  final int noOfPlayers;
  final String lobbyName;
  final bool isPartyLeader;
  final players;
  const WaitingLobbyScreen(
      {super.key,
      required this.occupancy,
      required this.noOfPlayers,
      required this.lobbyName,
      required this.isPartyLeader,
      required this.players});

  @override
  State<WaitingLobbyScreen> createState() => _WaitingLobbyScreenState();
}

class _WaitingLobbyScreenState extends State<WaitingLobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final String background;
    final MaterialColor colorCopy;
    final Color colorPrimary;
    var wordlist = [
      "Seek N Destroy",
      "Pennywise The Clown",
      "Big Damn Hero",
      "Drunk to Win",
      "Blunt Machete",
      "Black Belt",
      "Night Rider",
      "Brilliant Gamer",
      "Execute Electrocute",
      "I Play Farm Heroes"
    ];
    var imgList = [
      'assets/S2.png',
      'assets/S1.png',
      'assets/S3.png',
      'assets/S4.png',
      'assets/S5.png',
      'assets/S6.png',
      'assets/S7.png',
      'assets/S8.png',
      'assets/S9.png'
    ];

    if (widget.isPartyLeader) {
      background = 'assets/yellow1.jpg';
      colorCopy = Colors.blue;
      colorPrimary = Colors.white;
    } else {
      background = 'assets/blue1.jpg';
      colorCopy = Colors.yellow;
      colorPrimary = Colors.blueGrey;
    }

    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image:
            DecorationImage(image: AssetImage(background), fit: BoxFit.cover),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.03,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      'Waiting for ${widget.occupancy - widget.noOfPlayers} players to join',
                      style: const TextStyle(
                          fontSize: 30, color: Color.fromRGBO(136, 0, 21, 1)),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Image.asset(
                      'assets/gg.gif',
                      scale: 5,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.2,
                          right: MediaQuery.of(context).size.width * 0.2),
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.transparent),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: const Color(0xffF5F5FA),
                          hintText: 'roomID : ${widget.lobbyName}',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        //copy room code
                        Clipboard.setData(
                            ClipboardData(text: widget.lobbyName));
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('copied!'),
                        ));
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorPrimary,
                        backgroundColor: colorCopy,
                      ),
                      child: const Icon(Icons.content_copy),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.1),
              const Text(
                'Players: ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                primary: true,
                shrinkWrap: true,
                itemCount: widget.noOfPlayers,
                itemBuilder: (context, index) {
                  return ListTile(
                      leading: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                          maxWidth: 64,
                          maxHeight: 64,
                        ),
                        child: Image.asset(imgList[index % imgList.length],
                            fit: BoxFit.scaleDown),
                      ),
                      title: Text(
                          '${index + 1}. ${widget.players[index]['nickname']}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        (wordlist[index % wordlist.length]),
                      ));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
