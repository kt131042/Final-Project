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
  CollectionReference users = FirebaseFirestore.instance.collection('user');
  CollectionReference rooms = FirebaseFirestore.instance.collection('room');

  Future<void> confirmReservation(String roomNumber) async {
    await rooms
        .doc(widget.nid)
        .update({'status': 'เช่าอยู่'}).then((value) async {
      debugPrint("Reservation Confirmed for room $roomNumber");

      DocumentSnapshot userDoc = await users.doc(widget.nid).get();
      String fridge = userDoc['fridge'];
      String tv = userDoc['tv'];
      String nid = userDoc['id card number'];
      String status = userDoc['status'];
      String roomCollection = 'room${roomNumber[0].toUpperCase()}';

      await FirebaseFirestore.instance
          .collection(roomCollection)
          .doc(roomNumber)
          .update({
        'id card number': nid,
        'customer': widget.nid,
        'fridge': fridge,
        'tv': tv,
        'status': status,
      });

      if (mounted) {
        _showDialog('ยืนยันการจอง', 'จองห้อง $roomNumber สำเร็จแล้ว');
      }
    }).catchError((error) {
      debugPrint("Failed to confirm reservation: $error");
    });
  }

  Future<void> leaveDorm(String roomNumber) async {
    await users.doc(widget.nid).delete().then((value) async {
      await FirebaseFirestore.instance
          .collection('room')
          .doc(roomNumber)
          .update({
        'status': 'ว่าง',
        'customer': '',
        'id card number': '',
        'fridge': 0,
        'tv': 0,
      });

      if (mounted) {
        _showDialog('ออกหอเรียบร้อย', 'ข้อมูลของคุณถูกลบออกจากระบบแล้ว');
      }
    }).catchError((error) {
      debugPrint("Failed to leave dorm: $error");
    });
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
                backgroundColor: Colors.pink[200]),
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
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
              title: const Text("ข้อมูลลูกค้า"),
              backgroundColor: Colors.pink[200]),
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
          const SizedBox(height: 10),
          Text('สถานะทั่วไป: ${data['status'] ?? 'ไม่มีข้อมูล'}',
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
                const SizedBox(height: 8),
                Text('สถานะของห้อง: ${data['status'] ?? 'ไม่พบข้อมูล'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w400)),
                const SizedBox(height: 10),
                if (data['status'] == 'กำลังจอง')
                  ElevatedButton(
                    onPressed: () => confirmReservation(room),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.pink[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    ),
                    child: const Text('ยืนยันการจอง'),
                  ),
                if (data['status'] == 'เช่าอยู่')
                  ElevatedButton(
                    onPressed: () => leaveDorm(room),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                    ),
                    child: const Text('ยืนยันการออกหอ'),
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
