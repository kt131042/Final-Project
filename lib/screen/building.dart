import 'package:flutter/material.dart';
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
        title: const Text("Room"),
      ),
      body: Container(
        color: const Color(0xFFfcd1da), // เปลี่ยนสีพื้นหลังที่นี่
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0), // ขยับเนื้อหาลงมาที่นี่
            child: Column(
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
