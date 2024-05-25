import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jittirat/screen/addprofile.dart';
import 'package:jittirat/screen/detailcustumer.dart';

class Custumer extends StatefulWidget {
  const Custumer({super.key});

  @override
  State<Custumer> createState() => _CustumerState();
}

class _CustumerState extends State<Custumer> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool showReserved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custumer"),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddProfile()));
                },
                child: const Text("Add")),
          ),
          SizedBox(
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showReserved = !showReserved;
                  });
                },
                child: const Text("กำลังจอง")),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("user").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      if (showReserved && data['status'] != 'จอง') {
                        return Container(); // Return an empty container for non-reserved users when showReserved is true
                      }
                      return ListTile(
                        title: ElevatedButton(
                          child: Text(data['name']),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CustumerPage(custumerName: data['name']),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
