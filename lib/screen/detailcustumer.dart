import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustumerPage extends StatefulWidget {
  final String nid;

  const CustumerPage({super.key, required this.nid});

  @override
  State<CustumerPage> createState() => _CustumerPageState();
}

class _CustumerPageState extends State<CustumerPage> {
  CollectionReference users = FirebaseFirestore.instance.collection('user');
  CollectionReference room = FirebaseFirestore.instance.collection('roomA');
  String _fullName = "";

  Future<void> confirmReservation() async {
    await users
        .doc(widget.nid)
        .update({'status': 'เช่าอยู่'}).then((value) async {
      debugPrint("Reservation Confirmed");
      DocumentSnapshot userDoc = await users.doc(widget.nid).get();
      String roomNumber = userDoc['room'];
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
        _showDialog('ยืนยันการจอง', 'จองสำเร็จแล้ว');
      }
    }).catchError((error) {
      debugPrint("Failed to confirm reservation: $error");
    });
  }

  Future<void> cancelReservation() async {
    await _deleteUserAndUpdateUI('ยกเลิกการจอง', 'ยกเลิกสำเร็จแล้ว');
  }

  Future<void> leaveDorm() async {
    await _deleteUserAndUpdateUI('ยืนยันการออกหอพัก', 'บันทึกสำเร็จ');
    await room.doc(widget.nid).update({'status': 'ว่าง'});
  }

  Future<void> _deleteUserAndUpdateUI(String title, String content) async {
    await users.doc(widget.nid).delete().then((value) {
      debugPrint("$title successful");
      _showDialog(title, content);
    }).catchError((error) {
      debugPrint("Failed to perform action: $error");
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
              title: Text(_fullName),
              backgroundColor: Colors.pink[200],
            ),
            body: const Center(
              child: Text("Something went wrong"),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          _fullName = '${data['name']} ${data['lastname']}';
          DateTime checkinDate = data['checkin'].toDate();
          String formattedDate = DateFormat('dd/MM/yyyy').format(checkinDate);
          return Scaffold(
            appBar: AppBar(
              title: Text(_fullName),
              backgroundColor: Colors.pink[200],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _buildInfoRow(
                                'ชื่อ', '${data['name']} ${data['lastname']}'),
                            const SizedBox(height: 10),
                            _buildInfoText('ห้อง', data['room']),
                            _buildInfoText('เข้าหอ', formattedDate),
                            _buildInfoText('ติดต่อ', data['contact']),
                            _buildInfoText('เลขบัตรประจำตัวประชาชน',
                                data['id card number']),
                            const SizedBox(height: 20),
                            if (data['status'] == 'กำลังจอง') ...[
                              _buildActionButton(
                                  'ยืนยันการจอง',
                                  confirmReservation,
                                  Colors.pink[300],
                                  Colors.black),
                              const SizedBox(height: 10),
                              _buildActionButton(
                                  'ยกเลิกการจอง',
                                  cancelReservation,
                                  Colors.pink[100],
                                  Colors.black),
                            ],
                            if (data['status'] == 'เช่าอยู่') ...[
                              _buildActionButton("ออกหอ", leaveDorm,
                                  Colors.pink[200], Colors.black),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_fullName),
            backgroundColor: Colors.pink[200],
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink[800]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink[800]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed,
      Color? backgroundColor, Color textColor) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          shadowColor: Colors.grey.withOpacity(0.5),
          elevation: 7,
        ),
        child: Text(
          label,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
