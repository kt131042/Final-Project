import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailroomA extends StatelessWidget {
  final String roomName;

  const DetailroomA({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(roomName),
        ),
        body: Center(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('roomA')
                .doc(roomName)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 30,
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('หัวข้อ'),
                      ),
                      DataColumn(
                        label: Text('รายละเอียด'),
                      ),
                    ],
                    rows: <DataRow>[
                      DataRow(
                        cells: <DataCell>[
                          const DataCell(Text('ห้อง')),
                          DataCell(Text('${data['type']}')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          const DataCell(Text('สถานะ')),
                          DataCell(Text('${data['status']}')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          const DataCell(Text('ราคา')),
                          DataCell(Text('${data['price']}')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          const DataCell(Text('เครื่องใช้ไฟฟ้า')),
                          DataCell(Text('${data['fridge']} ${data['tv']}')),
                        ],
                      ),
                      DataRow(
                        cells: <DataCell>[
                          const DataCell(Text('ผู้เช่า')),
                          DataCell(Text('${data['customer']}')),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return const CircularProgressIndicator();
            },
          ),
        ));
  }
}
