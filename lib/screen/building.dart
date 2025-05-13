import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'roomdetail.dart'; // นำเข้าหน้า RoomDetail

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
                childAspectRatio: 1.5,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final data = room.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        "อาคาร: ${data['building']}, ห้อง: ${data['room_id']}"),
                    subtitle: Text(
                        "สถานะ: ${data['status'].isEmpty ? 'ว่าง' : data['status']}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RoomDetail(roomId: data['room_id']),
                        ),
                      );
                    },
                  ),
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
}
