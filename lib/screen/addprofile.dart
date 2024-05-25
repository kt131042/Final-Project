import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String _tv = '';
  String _fridge = '';
  DateTime _selectedDate = DateTime(2024);

  Future<void> addData() {
    return firestore.collection('user').doc(_name).set({
      'name': _name,
      'room': _room,
      'contact': _contact,
      'checkin': _selectedDate,
      'tv': _tv,
      'fridge': _fridge,
      'status': 'กำลังจอง'
    }).then((value) {
      debugPrint("Data Added");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('สำเร็จ'),
            content: const Text('บรรทีกข้อมูลสำเร็จ'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      debugPrint("Failed to add data: $error");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to add data: $error'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
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
                  ListTile(
                    title: Text(
                        'Picked Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
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
