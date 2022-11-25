import 'package:flutter/material.dart';

class Leaderboardscreen extends StatefulWidget {
  final List<Map> leaderboard;
  const Leaderboardscreen(this.leaderboard);

  @override
  State<Leaderboardscreen> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboardscreen> {
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
                alignment: Alignment.center,
                child: Column(children: [
                  ListView.builder(
                      itemCount: widget.leaderboard.length,
                      itemBuilder: (context, index) {
                        var data = widget.leaderboard[index].values;
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
                                color: Colors.grey,
                                fontSize: 20,
                              )),
                        );
                      }),
                  Text(
                      '${widget.leaderboard[0].values.elementAt(0).toString()} is the winner!',
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 30,
                          fontWeight: FontWeight.bold))
                ])),
          ])),
    );
  }
}
