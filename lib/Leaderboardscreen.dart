import 'dart:math';

import 'package:flutter/material.dart';

class Leaderboardscreen extends StatelessWidget {
  final scoreboard;
  Leaderboardscreen(this.scoreboard);
  void swap(List<Map> map, int x, int y) {
    var temp = map[x];
    map[x] = map[y];
    map[y] = temp;
  }

  void score() {
    int max_idx;
    for (int i = 0; i < scoreboard.length - 1; i++) {
      max_idx = i;
      for (var j = 0; j < scoreboard.length; j++) {
        if (int.parse(scoreboard[j]['points']) >
            int.parse(scoreboard[max_idx]['points'])) {
          max_idx = j;
        }
        if (max_idx != i) {
          swap(scoreboard, i, max_idx);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/pencil_colors.jpg'), fit: BoxFit.cover),
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/title.png'),
                      fit: BoxFit.fitWidth)),
              margin: EdgeInsets.only(
                  top: 40,
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  bottom: MediaQuery.of(context).size.height * 0.7),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.3),
                alignment: Alignment.center,
                child: Column(children: [
                  ListView.builder(
                      primary: true,
                      shrinkWrap: true,
                      itemCount: scoreboard.length,
                      itemBuilder: (context, index) {
                        var data = scoreboard[index].values;
                        return ListTile(
                          title: Text(
                            '${index + 1}. ${data.elementAt(0)}',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 23,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Text('score : ${data.elementAt(1)}.',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 4, 60, 6),
                                fontSize: 20,
                              )),
                        );
                      }),
                  Text(
                      '${scoreboard[0].values.elementAt(0).toString()} is the winner!',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 110, 48, 60),
                          fontSize: 30,
                          fontWeight: FontWeight.bold))
                ])),
          ])),
    );
  }
}
