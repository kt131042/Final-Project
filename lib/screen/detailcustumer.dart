import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustumerPage extends StatelessWidget {
  final String custumerName;

  const CustumerPage({super.key, required this.custumerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(custumerName),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('user')
            .doc(custumerName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            DateTime checkinDate = data['checkin'].toDate();
            String formattedDate = DateFormat('dd/MM/yy').format(checkinDate);
            return Center(
              child: Column(
                children: <Widget>[
                  Text('ชื่อ: ${data['name']}'),
                  Text('ห้อง: ${data['room']}'),
                  Text('เข้าหอ:  $formattedDate'),
                  Text('ติดต่อ: ${data['contact']}'),
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
