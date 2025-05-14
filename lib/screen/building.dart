import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'roomdetail.dart';

class Building extends StatefulWidget {
  const Building({super.key});

  @override
  State<Building> createState() => _BuildingState();
}

class _BuildingState extends State<Building> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String filter = 'ห้องทั้งหมด';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOME"),
        backgroundColor: Colors.pink[300],
        actions: [
          DropdownButton<String>(
            value: filter,
            onChanged: (String? newValue) {
              setState(() {
                filter = newValue!;
              });
            },
            items: <String>[
              'ห้องทั้งหมด',
              'ห้องที่ว่าง',
              'ห้องที่ถูกจอง',
              'ห้องที่เช่าอยู่'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFfcd1da),
        child: StreamBuilder<QuerySnapshot>(
          stream: _getFilteredRooms(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rooms = snapshot.data!.docs;

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final data = room.data() as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot?>(
                  future: _getLatestElectricityBill(data['room_id']),
                  builder: (context, billSnapshot) {
                    double unitConsume = 0;
                    if (billSnapshot.hasData &&
                        billSnapshot.data != null &&
                        billSnapshot.data!.exists) {
                      var billData =
                          billSnapshot.data!.data() as Map<String, dynamic>;
                      unitConsume =
                          (billData["unit_consume"] as num?)?.toDouble() ?? 0.0;
                    }

                    // คำนวณค่าห้อง เฉพาะห้องที่เช่าอยู่
                    double totalRoomPrice = 0;
                    if (data["status"] == "เช่าอยู่") {
                      double baseRoomPrice =
                          data["type"] == "แอร์" ? 2250 : 2050;
                      int tvCount = data["tv"] ?? 0;
                      int fridgeCount = data["fridge"] ?? 0;
                      double applianceCost =
                          (tvCount * 100) + (fridgeCount * 100);
                      totalRoomPrice =
                          baseRoomPrice + applianceCost + unitConsume;
                    }

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoomDetail(roomId: data['room_id']),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "อาคาร: ${data['building']}, ห้อง: ${data['room_id']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Text(
                                    "สถานะ: ${data['status'].isEmpty ? 'ว่าง' : data['status']}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "หน่วยไฟที่ใช้ไป: $unitConsume",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (data["status"] == "เช่าอยู่")
                                    Text(
                                      "ค่าห้องทั้งหมด: $totalRoomPrice บาท",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredRooms() {
    switch (filter) {
      case 'ห้องที่ว่าง':
        return _firestore
            .collection('room')
            .where('status', isEqualTo: 'ว่าง')
            .snapshots();
      case 'ห้องที่ถูกจอง':
        return _firestore
            .collection('room')
            .where('status', isEqualTo: 'กำลังจอง')
            .snapshots();
      case 'ห้องที่เช่าอยู่':
        return _firestore
            .collection('room')
            .where('status', isEqualTo: 'เช่าอยู่')
            .snapshots();
      default:
        return _firestore.collection('room').snapshots();
    }
  }

  Future<DocumentSnapshot?> _getLatestElectricityBill(String roomId) async {
    var query = await _firestore
        .collection("Electricity_Bills")
        .where("room_id", isEqualTo: roomId)
        .orderBy("month", descending: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first : null;
  }
}
