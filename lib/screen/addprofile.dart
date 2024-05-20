import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddProfile extends StatefulWidget {
  const AddProfile({super.key});

  @override
  State<AddProfile> createState() => _AddProfileState();
}

class _AddProfileState extends State<AddProfile> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool tvisChecked = false;
  bool fridgeChecked = false;
  String _name = '';
  String _room = '';
  String _contact = '';
  String _checkin = '';
  String _tv = '';
  String _fridge = '';

  Future<void> addData() {
    return firestore
        .collection('user')
        .add({
          'name': _name,
          'rooom': _room,
          'contact': _contact,
          'checkin': _checkin,
          'tv': _tv,
          'fridge': _fridge,
        })
        .then((value) => debugPrint("Data Added"))
        .catchError((error) => debugPrint("Failed to add data: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มผู้เช่าใหม่"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ชื่อ-สกุล"),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อ';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("เบอร์โทรติดต่อ"),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเบอร์โทรศัพท์';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      _contact = value!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("หมายเลขห้อง"),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกหมายเลขห้อง';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      _room = value!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text("วันเข้าหอ"),
                  TextFormField(
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกวันเข้าหอ';
                      }
                      return null;
                    },
                    onSaved: (String? value) {
                      _checkin = value!;
                    },
                  ),
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
                              tvisChecked = value!;
                              _tv = tvisChecked ? "ทีวี" : "";
                            });
                          }),
                      const SizedBox(
                        width: 100,
                      ),
                      const Text("ตู้เย็น"),
                      Checkbox(
                          value: fridgeChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              fridgeChecked = value!;
                              _fridge = fridgeChecked ? "ตู้เย็น" : "";
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              addData();
                            }
                          },
                          child: const Text("บันทึก"))),
                ],
              ),
            )),
      ),
    );
  }
}
