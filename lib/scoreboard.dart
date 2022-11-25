import 'package:flutter/material.dart';

class playerScoreboard extends StatelessWidget {
  final List<Map> userData;
  const playerScoreboard(
    this.userData,
  );

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Center(
      child: Container(
        height: double.maxFinite,
        child: ListView.builder(
            itemCount: userData.length,
            itemBuilder: ((context, index) {
              var data = userData[index].values;
              return ListTile(
                title: Text(
                  '${data.elementAt(0)} :',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(data.elementAt(1),
                    style: const TextStyle(color: Colors.grey, fontSize: 20)),
              );
            })),
      ),
    ));
  }
}
