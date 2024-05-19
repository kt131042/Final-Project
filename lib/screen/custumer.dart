import 'package:flutter/material.dart';
import 'package:jittirat/screen/addprofile.dart';

class Custumer extends StatefulWidget {
  const Custumer({super.key});

  @override
  State<Custumer> createState() => _CustumerState();
}

class _CustumerState extends State<Custumer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custumer"),
      ),
      body: Column(
        children: [
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProfile()));
                },
                child: const Text("Add")),
          ),
          const Text("data")
        ],
      ),
    );
  }
}
