import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoomDetail extends StatefulWidget {
  final String roomId;

  const RoomDetail({super.key, required this.roomId});

  @override
  State<RoomDetail> createState() => _RoomDetailState();
}

class _RoomDetailState extends State<RoomDetail> {
  Map<String, dynamic>? roomData;
  String? userStatusName;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // ดึงข้อมูลห้องจาก room collection
      DocumentSnapshot roomDoc = await FirebaseFirestore.instance
          .collection('room')
          .doc(widget.roomId)
          .get();

      if (!roomDoc.exists) {
        setState(() {
          roomData = null;
          userStatusName = null;
        });
        return;
      }

      roomData = roomDoc.data() as Map<String, dynamic>;

      // ดึงข้อมูล user collection ทั้งหมด
      QuerySnapshot userDocs =
          await FirebaseFirestore.instance.collection('user').get();

      for (var userDoc in userDocs.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('room') && userData['room'] is List) {
          List<dynamic> userRooms = userData['room'];

          // ตรวจสอบว่าห้องอยู่ใน array `room` ของผู้ใช้หรือไม่
          if (userRooms.contains(widget.roomId)) {
            String userRole =
                (roomData!['status'] == 'กำลังจอง') ? "ผู้เข้าจอง" : "ผู้เช่า";
            userStatusName =
                "$userRole ${userData['name']} ${userData['lastname']}";
            break;
          }
        }
      }

      setState(() {});
    } catch (error) {
      debugPrint("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: Text("รายละเอียดห้อง: ${widget.roomId}"),
        backgroundColor: Colors.pink[300],
      ),
      body: roomData == null
          ? const Center(child: Text("ไม่พบข้อมูลห้องนี้"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //  กรอบชื่อผู้เช่าหรือผู้เข้าจอง
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      userStatusName ?? "ไม่มีผู้ใช้ในห้องนี้",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[800]),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),

                  //  กรอบข้อมูลห้อง
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ตึก: ${roomData!['building']}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text("สถานะ: ${roomData!['status'] ?? 'ไม่มีข้อมูล'}",
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("เลขห้อง: ${roomData!['room_id']}",
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        Text("ตู้เย็นมี ${roomData!['fridge'] ?? 0} เครื่อง",
                            style: const TextStyle(fontSize: 18)),
                        Text("ทีวีมี ${roomData!['tv'] ?? 0} เครื่อง",
                            style: const TextStyle(fontSize: 18)),
                        Text(
                            "ประเภทห้อง: ${roomData!['type'] ?? 'ไม่มีข้อมูล'}",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
