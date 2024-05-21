import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  void createRecord() async {
    CollectionReference bill = FirebaseFirestore.instance.collection('room');
    CollectionReference electricityCosts =
        bill.doc('A101').collection('electricity_costs');

    Map<String, dynamic> data = {
      'month': 'May',
      'year': 2024,
      'units_used': 120,
      'cost_per_unit': 3.50,
      'total_cost': 420
    };

    await electricityCosts.doc('2024_05').set(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("คำนวณค่าเช่า")),
      body: Column(
        children: [
          const Text("data"),
          ElevatedButton(
              onPressed: () {
                createRecord();
              },
              child: const Text("บันทึก"))
        ],
      ),
    );
  }
}
