import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailroomB extends StatelessWidget {
  final String roomName;

  const DetailroomB({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('roomB').doc(roomName).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: Column(
                children: <Widget>[
                  Text('ห้อง: ${data['type']}'),
                  Text('สถานะ: ${data['status']}'),
                  Text('ราคา: ${data['price']}'),
                  Text('เครื่องใช้ไฟฟ้า: ${data['fridge']} ${data['tv']}'),
                  Text('ผู้เช่า: ${data['custumer']}'),
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
