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
  String _lastname = '';
  String _nid = '';
  String _contact = '';
  int _tv = 0;
  int _fridge = 0;
  DateTime _selectedDate = DateTime(2024);
  final List<String> _room = [];

  Future<void> addData() async {
    try {
      // เพิ่มข้อมูลผู้ใช้ใหม่
      await firestore.collection('user').doc(_nid).set({
        'name': _name,
        'lastname': _lastname,
        'room': _room,
        'id_card': _nid,
        'contact': _contact,
        'checkin': _selectedDate,
        'tv': _tv,
        'fridge': _fridge,
        'status': 'กำลังจอง'
      });

      // ตรวจสอบและอัปเดตสถานะของห้องที่จอง
      for (String roomId in _room) {
        DocumentReference roomRef = firestore.collection('room').doc(roomId);
        DocumentSnapshot roomSnapshot = await roomRef.get();
        if (roomSnapshot.exists) {
          await roomRef.update({
            'status': 'กำลังจอง',
          });
        } else {
          debugPrint("Room ID $roomId not found in collection 'room'");
        }
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('สำเร็จ'),
              content: const Text('บันทึกข้อมูลสำเร็จ'),
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
      }
    } catch (error) {
      debugPrint("Failed to add data: $error");
      if (mounted) {
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
      }
    }
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
    const textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(),
    );

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
                const Text("ชื่อ"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'กรอกชื่อ',
                  ),
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
                const SizedBox(height: 15),
                const Text("นามสกุล"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'กรอกนามสกุล',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกนามสกุล';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _lastname = value!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("เลขบัตรประจำตัวประชาชน"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'กรอกเลขบัตรประจำตัวประชาชน',
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเลขบัตรประจำตัวประชาชน';
                    }
                    return null;
                  },
                  onSaved: (String? value) {
                    _nid = value!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("เบอร์โทรติดต่อ"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                    hintText: 'กรอกเบอร์โทร',
                  ),
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
                const SizedBox(height: 15),
                const Text("หมายเลขห้อง"),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _room.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _room.length) {
                      return TextFormField(
                        decoration: textFieldDecoration.copyWith(
                          hintText: 'กรอกหมายเลขห้อง',
                        ),
                        onSaved: (String? value) {
                          if (value != null && value.isNotEmpty) {
                            setState(() {
                              _room.add(value);
                            });
                          }
                        },
                      );
                    }
                    return ListTile(
                      title: Text('ห้อง: ${_room[index]}'),
                    );
                  },
                ),
                const SizedBox(height: 15),
                const Text("วันเข้าหอ"),
                ListTile(
                  title: Text(
                      'Picked Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 15),
                const Text("เครื่องใช้ไฟฟ้าเพิ่มเติม"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ทีวี"),
                    Checkbox(
                        value: tvisChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            tvisChecked = value!;
                            _tv = tvisChecked ? 1 : 0;
                          });
                        }),
                    const SizedBox(width: 100),
                    const Text("ตู้เย็น"),
                    Checkbox(
                        value: fridgeChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            fridgeChecked = value!;
                            _fridge = fridgeChecked ? 1 : 0;
                          });
                        }),
                  ],
                ),
                const SizedBox(height: 15),
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
          ),
        ),
      ),
    );
  }
}
