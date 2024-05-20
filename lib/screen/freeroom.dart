import 'package:flutter/material.dart';

class Freeroom extends StatefulWidget {
  const Freeroom({super.key});

  @override
  State<Freeroom> createState() => _FreeroomState();
}

class _FreeroomState extends State<Freeroom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ห้องที่ว่าง"),
      ),
      body: const Column(
        children: [
          Text("data"),
        ],
      ),
    );
  }
}
