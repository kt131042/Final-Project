import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerPage extends StatefulWidget {
  final String nid;

  const CustomerPage({super.key, required this.nid});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('user');
  final CollectionReference rooms =
      FirebaseFirestore.instance.collection('room');

  Future<void> confirmReservation() async {
    try {
      DocumentSnapshot userDoc = await users.doc(widget.nid).get();
      List<dynamic> roomsBooked = userDoc['room']; // ดึงห้องที่ผู้ใช้จองทั้งหมด

      for (String roomId in roomsBooked) {
        await rooms.doc(roomId).update({'status': 'เช่าอยู่'});
      }

      await users
          .doc(widget.nid)
          .update({'status': 'เช่าอยู่'}); // อัปเดตสถานะผู้ใช้

      setState(() {}); // รีเฟรชหน้า
      _showDialog(
          'ยืนยันการเข้าหอ', 'ห้องที่เลือกถูกเปลี่ยนเป็นห้องเช่าอยู่แล้ว');
    } catch (error) {
      debugPrint("Failed to confirm reservation: $error");
    }
  }

  Future<void> cancelReservation(String roomNumber) async {
    try {
      await rooms.doc(roomNumber).update({'status': 'ว่าง'});

      DocumentSnapshot userDoc = await users.doc(widget.nid).get();
      List<dynamic> roomsBooked = List.from(userDoc['room']);

      roomsBooked.remove(roomNumber);
      await users.doc(widget.nid).update({'room': roomsBooked});

      setState(() {}); // รีเฟรชหน้า
      _showDialog('ยกเลิกการจอง', 'ห้อง $roomNumber ถูกยกเลิกการจองแล้ว');
    } catch (error) {
      debugPrint("Failed to cancel reservation: $error");
    }
  }

  Future<void> leaveDorm(String roomNumber) async {
    try {
      await rooms.doc(roomNumber).update({'status': 'ว่าง'});

      DocumentSnapshot userDoc = await users.doc(widget.nid).get();
      List<dynamic> roomsRented = List.from(userDoc['room']);

      roomsRented.remove(roomNumber);
      await users.doc(widget.nid).update({'room': roomsRented});

      if (roomsRented.isEmpty) {
        await users.doc(widget.nid).update({'status': null});
      }

      setState(() {}); // รีเฟรชหน้า
      _showDialog('ออกหอเรียบร้อย', 'ห้อง $roomNumber ถูกออกจากหอพักแล้ว');
    } catch (error) {
      debugPrint("Failed to leave dorm: $error");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(widget.nid).get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("ข้อมูลลูกค้า"),
              backgroundColor: Colors.pink[200],
            ),
            body: const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล")),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String formattedDate =
              DateFormat('dd/MM/yyyy').format(data['checkin'].toDate());

          return Scaffold(
            appBar: AppBar(
              title: Text('${data['name']} ${data['lastname']}'),
              backgroundColor: Colors.pink[200],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildInfoBox(data, formattedDate),
                  const SizedBox(height: 16),
                  _buildRoomBoxes(data),
                  const SizedBox(height: 16),
                  if (data['status'] == 'กำลังจอง')
                    ElevatedButton(
                      onPressed: confirmReservation,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[300]),
                      child: const Text('ยืนยันการจองห้องทั้งหมด'),
                    ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("ข้อมูลลูกค้า"),
            backgroundColor: Colors.pink[200],
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildInfoBox(Map<String, dynamic> data, String formattedDate) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ชื่อ: ${data['name']} ${data['lastname']}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800])),
          const SizedBox(height: 10),
          Text('เข้าหอ: $formattedDate',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          const SizedBox(height: 10),
          Text('ติดต่อ: ${data['contact'] ?? 'ไม่มีข้อมูล'}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          const SizedBox(height: 10),
          Text('เลขบัตรประชาชน: ${data['id_card'] ?? 'ไม่มีข้อมูล'}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildRoomBoxes(Map<String, dynamic> data) {
    if (data['room'] is List && data['room'].isNotEmpty) {
      return Column(
        children: data['room'].map<Widget>((room) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ห้อง: $room',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800])),
                if (data['status'] == 'กำลังจอง')
                  ElevatedButton(
                    onPressed: () => cancelReservation(room),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[300]),
                    child: const Text('ยกเลิกการจอง'),
                  ),
                if (data['status'] == 'เช่าอยู่')
                  ElevatedButton(
                    onPressed: () => leaveDorm(room),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[300]),
                    child: const Text('ออกจากห้อง'),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return const Text('ไม่มีข้อมูลห้อง');
    }
  }
}
