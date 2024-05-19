import 'package:flutter/material.dart';
import 'package:jittirat/model/userform.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({super.key});

  @override
  State<AddProfile> createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final formkey = GlobalKey<FormState>();
  CustumerProfile userProfile = CustumerProfile();
  bool? tvisChecked = true;
  bool? frezzeisChecked = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มผู้เช่าใหม่"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
            key: formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ชื่อ-สกุล"),
                  TextFormField(
                    onSaved: (String? name) {
                      userProfile.name = name!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("เบอร์โทรติดต่อ"),
                  TextFormField(),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("ห้อง"),
                  TextFormField(),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("เครื่องใช้ไฟฟ้าเพิ่มเติม"),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ทีวี"),
                      Checkbox(
                          value: tvisChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              tvisChecked = value;
                            });
                          }),
                      const SizedBox(
                        width: 100,
                      ),
                      const Text("ตู้เย็น"),
                      Checkbox(
                          value: frezzeisChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              frezzeisChecked = value;
                            });
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {}, child: const Text("บันทึก"))),
                ],
              ),
            )),
      ),
    );
  }
}
