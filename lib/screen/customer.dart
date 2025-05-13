import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jittirat/screen/addprofile.dart';
import 'package:jittirat/screen/detailcustomer.dart';

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool showReserved = false;

  void changeButtonStatus(bool isReserved) {
    setState(() {
      showReserved = isReserved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("CUSTOMER"),
        backgroundColor: Colors.pink[300],
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProfile()),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text("ลงทะเบียน"),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFfcd1da),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => changeButtonStatus(true),
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        showReserved ? Colors.pink[400] : Colors.pink[200],
                      ),
                    ),
                    child: const Text('กำลังจอง'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => changeButtonStatus(false),
                    style: buttonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        !showReserved ? Colors.pink[400] : Colors.pink[200],
                      ),
                    ),
                    child: const Text('รายชื่อผู้เช่าอยู่'),
                  ),
                ],
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("user")
                      .where('status',
                          isEqualTo: showReserved ? 'กำลังจอง' : 'เช่าอยู่')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("ไม่มีข้อมูลในขณะนี้"));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: ListTile(
                              leading: Icon(
                                (data['status'] ?? '') == 'กำลังจอง'
                                    ? Icons.pending_actions
                                    : (data['status'] ?? '') == 'เช่าอยู่'
                                        ? Icons.home
                                        : Icons.person,
                                color: (data['status'] ?? '') == 'กำลังจอง'
                                    ? Colors.orange
                                    : (data['status'] ?? '') == 'เช่าอยู่'
                                        ? Colors.green
                                        : Colors.blueGrey,
                              ),
                              title: Text(
                                '${data['name']} ${data['lastname']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink[300]),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomerPage(nid: data['id_card']),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
