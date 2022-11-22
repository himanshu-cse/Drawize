import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'join_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                        fit:BoxFit.fitWidth)),
                margin: EdgeInsets.only(
                    top: 40,
                    left: MediaQuery.of(context).size.width*0.2,
                    right: MediaQuery.of(context).size.width*0.2,
                    bottom: MediaQuery.of(context).size.height * 0.7),
              ),
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*.6),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateRoomScreen(),
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(color: Colors.white)),
                            minimumSize: MaterialStateProperty.all(Size(
                                MediaQuery.of(context).size.width*.3, 50))),
                        child: const Text(
                          style: TextStyle(fontSize: 20),
                          "Create",
                        )),
                    const SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const JoinRoomScreen(),
                          ),
                        ),
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(color: Colors.white)),
                            minimumSize: MaterialStateProperty.all(Size(
                                MediaQuery.of(context).size.width*.2, 50))),
                        child: const Text(
                          style: TextStyle(fontSize: 20),
                          "Join",
                        ))
                  ],
                ),

              ),
            ])));
  }
}
