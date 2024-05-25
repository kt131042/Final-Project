import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustumerPage extends StatefulWidget {
  final String custumerName;

  const CustumerPage({super.key, required this.custumerName});

  @override
  State<CustumerPage> createState() => _CustumerPageState();
}

class _CustumerPageState extends State<CustumerPage> {
  CollectionReference users = FirebaseFirestore.instance.collection('user');

  Future<void> confirmReservation() async {
    await users
        .doc(widget.custumerName)
        .update({'status': 'เช่าอยู่'}).then((value) async {
      debugPrint("Reservation Confirmed");
      String roomNumber = (await users.doc(widget.custumerName).get())['room'];
      String fridge = (await users.doc(widget.custumerName).get())['fridge'];
      String tv = (await users.doc(widget.custumerName).get())['tv'];
      String status = (await users.doc(widget.custumerName).get())['status'];
      String roomCollection = 'room${roomNumber[0].toUpperCase()}';
      await FirebaseFirestore.instance
          .collection(roomCollection)
          .doc(roomNumber)
          .update({
        'customer': widget.custumerName,
        'fridge': fridge,
        'tv': tv,
        'status': status
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ยืนยันการจอง'),
              content: const Text('จองสำเร็จแล้ว'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }).catchError((error) {
      debugPrint("Failed to cancel reservation: $error");
      return null;
    });
  }

  Future<void> cancelReservation() async {
    await users.doc(widget.custumerName).delete().then((value) {
      debugPrint("Reservation Cancelled");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ยกเลิกการจอง'),
            content: const Text('ยกเลิกสำเร็จแล้ว'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      debugPrint("Failed to cancel reservation: $error");
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.custumerName),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user')
            .doc(widget.custumerName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            DateTime checkinDate = data['checkin'].toDate();
            String formattedDate = DateFormat('dd/MM/yyyy').format(checkinDate);
            return Center(
              child: Column(
                children: <Widget>[
                  Text('ชื่อ: ${data['name']}'),
                  Text('ห้อง: ${data['room']}'),
                  Text('เข้าหอ:  $formattedDate'),
                  Text('ติดต่อ: ${data['contact']}'),
                  if (data['status'] == 'กำลังจอง') ...[
                    ElevatedButton(
                      onPressed: confirmReservation,
                      child: const Text('ยืนยันการจอง'),
                    ),
                    ElevatedButton(
                      onPressed: cancelReservation,
                      child: const Text('ยกเลิกการจอง'),
                    ),
                  ],
                ],
              ),
            );
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
