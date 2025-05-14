import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalBill extends StatefulWidget {
  const CalBill({super.key});

  @override
  State<CalBill> createState() => _CalBillState();
}

class _CalBillState extends State<CalBill> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController monthController = TextEditingController();
  final Map<String, TextEditingController> unitControllers = {};

  @override
  void initState() {
    super.initState();

    monthController.text = DateFormat('yyyy-MM').format(DateTime.now());
  }

  void saveElectricityData(String roomId) async {
    if (!mounted) return;

    double? unit = double.tryParse(unitControllers[roomId]!.text);
    if (unit == null || unit <= 0) return;

    // ดึงข้อมูลค่าหน่วยก่อนหน้า เฉพาะห้องที่ถูกกด Save
    var prevData = await firestore
        .collection("Electricity_Bills")
        .where("room_id", isEqualTo: roomId)
        .orderBy("month", descending: true)
        .limit(1)
        .get();

    double preUnit = prevData.docs.isNotEmpty
        ? (prevData.docs.first.get("current_unit") as num).toDouble()
        : 0;

    // คำนวณค่าใช้ไฟ
    double unitConsume = unit - preUnit;
    double amount = unitConsume * 5.0; // ค่าไฟต่อหน่วย (5 บาท)

    // บันทึกข้อมูลลง Firebase เฉพาะห้องที่ถูกกด Save
    await firestore
        .collection("Electricity_Bills")
        .doc("${roomId}_${monthController.text}")
        .set({
      "room_id": roomId,
      "month": monthController.text,
      "pre_unit": preUnit,
      "current_unit": unit,
      "unit_consume": unitConsume,
      "amount": amount,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("บันทึกค่าไฟห้อง $roomId สำเร็จ!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("คำนวณค่าไฟ"),
        backgroundColor: Colors.pink[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: monthController,
              decoration: const InputDecoration(
                labelText: "เดือน (YYYY-MM)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("room")
                    .where("status", isEqualTo: "เช่าอยู่")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var rooms = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      var data = rooms[index].data() as Map<String, dynamic>;
                      String roomId = data["room_id"];

                      if (!unitControllers.containsKey(roomId)) {
                        unitControllers[roomId] = TextEditingController();
                      }

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text("ห้อง $roomId"),
                          subtitle: TextField(
                            controller: unitControllers[roomId],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "กรอกหน่วยไฟ",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.save, color: Colors.green),
                            onPressed: () => saveElectricityData(roomId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
