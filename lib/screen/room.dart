import 'package:flutter/material.dart';
import 'package:jittirat/screen/calbill.dart';

class Room extends StatefulWidget {
  const Room({super.key});

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Room test"),
      ),
      body: Column(
        children: [
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Calculator()));
                },
                child: const Text("คำนวณ")),
          ),
          const Text("data")
        ],
      ),
    );
  }
}
