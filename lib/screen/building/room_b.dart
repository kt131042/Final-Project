import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jittirat/screen/building/detailroom_b.dart';
import 'package:jittirat/screen/calbill.dart';

class RoomB extends StatefulWidget {
  const RoomB({super.key});

  @override
  State<RoomB> createState() => _RoomState();
}

class _RoomState extends State<RoomB> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> keysToShow = ['room', 'status', 'type'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        title: const Text("Jittirat 2"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Calculator(),
                ),
              );
            },
            child: const Text('คำนวณค่าไฟ'),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("roomB").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 45,
                  horizontalMargin: 5,
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('ห้อง'),
                    ),
                    DataColumn(
                      label: Text('สถานะ'),
                    ),
                    DataColumn(
                      label: Text('ประเภท'),
                    ),
                    DataColumn(
                      label: Text(''),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return DataRow(
                      cells: <DataCell>[
                        DataCell(Text('${data['room']}')),
                        DataCell(Text('${data['status']}')),
                        DataCell(Text('${data['type']}')),
                        DataCell(ElevatedButton(
                          child: const Text('รายละเอียด'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailroomB(roomName: data['room']),
                              ),
                            );
                          },
                        )),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}
