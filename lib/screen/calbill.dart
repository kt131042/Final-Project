import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final CollectionReference _roomsCollection =
      FirebaseFirestore.instance.collection('roomA');
  List<Map<String, dynamic>> _roomsData = [];
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchRoomsData();
  }

  void _fetchRoomsData() async {
    QuerySnapshot snapshot = await _roomsCollection.get();
    setState(() {
      _roomsData = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
      // Initialize a TextEditingController for each room
      for (var room in _roomsData) {
        _controllers[room['id']] = TextEditingController();
      }
    });
  }

  Future<void> saveMonthlyElectricityBill(
      String roomID, int year, int month, double electricityBill) async {
    DocumentReference roomRef =
        FirebaseFirestore.instance.collection('roomA').doc(roomID);
    DocumentReference billRef = roomRef.collection('bills').doc('$year-$month');

    return billRef.set({
      'electricityBill': electricityBill,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("คำนวณค่าไฟ")),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: _roomsData.length,
          itemBuilder: (context, index) {
            String roomId = _roomsData[index]['id'];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _controllers[roomId],
                decoration: InputDecoration(
                  labelText: 'Enter electricity bill for Room $roomId',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  double billAmount = double.tryParse(value!) ?? 0;
                  // Save the entered value to Firebase or handle it as needed
                  saveMonthlyElectricityBill(roomId, DateTime.now().year,
                      DateTime.now().month, billAmount);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
