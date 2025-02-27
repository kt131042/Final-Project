import 'package:flutter/material.dart';
import 'package:jittirat/screen/allroom.dart';
import 'package:jittirat/screen/building/room_a.dart';
import 'package:jittirat/screen/building/room_b.dart';
import 'package:jittirat/screen/building/room_c.dart';

class Building extends StatefulWidget {
  const Building({super.key});

  @override
  State<Building> createState() => _BuildingState();
}

class _BuildingState extends State<Building> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: const Text("ห้องว่าง"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Allroom(),
                ),
              );
            },
            child: const Text('ห้องทั้งหมด'),
          )
        ],
      ),
      body: Container(
        color: const Color(0xFFfcd1da),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomA(),
                      ),
                    );
                  },
                  child: const Text("ตึกจิตติรัตน์ 1"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomB(),
                      ),
                    );
                  },
                  child: const Text("ตึกจิตติรัตน์ 2"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomC(),
                      ),
                    );
                  },
                  child: const Text("ตึกจิตติรัตน์ 3"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
