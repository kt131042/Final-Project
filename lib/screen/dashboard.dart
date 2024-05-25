import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.pink[300],
      ),
      body: Container(
        color: const Color(0xFFfcd1da),
        child: const Padding(
          padding: EdgeInsets.only(top: 50.0), // ขยับเนื้อหาลงมาที่นี่
          child: Center(),
        ),
      ),
    );
  }
}
