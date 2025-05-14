import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jittirat/screen/calbill.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<String> getLatestMonth() async {
    var query = await firestore
        .collection("Electricity_Bills")
        .orderBy("month", descending: true)
        .limit(1)
        .get();

    return query.docs.isNotEmpty ? query.docs.first.get("month") : "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DASHBOARD"),
        backgroundColor: Colors.pink[300],
      ),
      body: FutureBuilder<String>(
        future: getLatestMonth(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          String latestMonth = snapshot.data ?? "N/A";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //  แสดง 3 อันดับห้องที่ใช้ไฟมากที่สุด
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("Electricity_Bills")
                      .where("month", isEqualTo: latestMonth)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var rooms = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return {
                        "room_id": data["room_id"],
                        "unit_consume":
                            (data["unit_consume"] as num?)?.toDouble() ?? 0.0,
                      };
                    }).toList();

                    //  คำนวณ 3 อันดับห้องที่ใช้ไฟมากที่สุด
                    rooms.sort((a, b) =>
                        b["unit_consume"].compareTo(a["unit_consume"]));
                    var topRooms = rooms.take(3).toList();

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: const Text("🏆 ห้องที่ใช้ไฟมากที่สุด (Top 3)"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: topRooms.map((room) {
                            return Text(
                                "ห้อง ${room["room_id"]} ใช้ไฟ ${room["unit_consume"]} หน่วย");
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                //  แสดงผลรวมของการใช้ไฟฟ้าในเดือนล่าสุด
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("Electricity_Bills")
                      .where("month", isEqualTo: latestMonth)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    double totalUnits =
                        snapshot.data!.docs.fold(0, (prev, doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return prev + (data["unit_consume"] as num?)!.toDouble();
                    });

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: const Text("⚡ หน่วยไฟทั้งหมดของเดือนล่าสุด"),
                        subtitle: Text("$totalUnits หน่วย"),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // แสดงรายชื่อผู้เช่าล่าสุด 3 คน
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection("user")
                      .orderBy("checkin", descending: true)
                      .limit(3)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    var users = snapshot.data!.docs;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: const Text("👤 ผู้เช่าล่าสุด (3 คน)"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: users.map((doc) {
                            var data = doc.data() as Map<String, dynamic>;
                            return Text("${data["name"]} ${data["lastname"]}");
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                //  ปุ่มคำนวณค่าไฟ
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[400],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalBill()),
                    );
                  },
                  child: const Text(
                    "คำนวณค่าไฟ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
