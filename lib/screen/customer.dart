import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jittirat/screen/addprofile.dart';
import 'package:jittirat/screen/detailcustomer.dart';

class Custumer extends StatefulWidget {
  const Custumer({super.key});

  @override
  State<Custumer> createState() => _CustumerState();
}

class _CustumerState extends State<Custumer> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool showReserved = false;
  String buttonText = 'กำลังจอง';

  void changeButtonText() {
    setState(() {
      if (buttonText == 'กำลังจอง') {
        buttonText = 'รายชื่อทั้งหมด';
      } else {
        buttonText = 'กำลังจอง';
      }
      showReserved = !showReserved;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer"),
        backgroundColor: Colors.pink[300],
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddProfile()));
              },
              child: const Text("Add")),
        ],
      ),
      body: Container(
        color: const Color(0xFFfcd1da),
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0), // ขยับเนื้อหาลงมาที่นี่
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                  ),
                  SizedBox(
                      child: ElevatedButton(
                    onPressed: changeButtonText,
                    child: Text(buttonText),
                  )),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("user")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading");
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document =
                              snapshot.data!.docs[index];
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          if (showReserved && data['status'] != 'กำลังจอง') {
                            return Container(); // Return an empty container for non-reserved users when showReserved is true
                          }
                          return ListTile(
                            leading: data['status'] == 'กำลังจอง'
                                ? const Icon(Icons.pending_actions)
                                : data['status'] == 'เช่าอยู่'
                                    ? const Icon(Icons.home)
                                    : null, // Add a home icon for users with status 'เช่าอยู่'
                            title: ElevatedButton(
                              child: Text('${index + 1}. ${data['name']}'),
                              // Display the index before the name
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustumerPage(
                                        custumerName: data['name']),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
