import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jittirat/screen/building/detailroom_c.dart';
import 'package:jittirat/screen/calbill.dart';

class RoomC extends StatefulWidget {
  const RoomC({super.key});

  @override
  State<RoomC> createState() => _RoomState();
}

class _RoomState extends State<RoomC> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> keysToShow = ['room', 'status', 'type'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: const Text("Jittirat 3"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Calculator()));
                    },
                    child: const Text("คำนวณค่าไฟ")),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("roomC").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.black),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      return ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                  'ห้อง: ${data['room']} | สถานะ: ${data['status']} | ประเภท: ${data['type']} |'),
                            ),
                            ElevatedButton(
                              child: const Text('รายละเอียด'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailroomC(roomName: data['room']),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}
