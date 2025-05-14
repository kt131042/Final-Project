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

  String _name = '';
  String _lastname = '';
  String _nid = '';
  String _contact = '';
  final int _tv = 0;
  final int _fridge = 0;
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedRooms = {};

  Future<List<DocumentSnapshot>> _getAvailableRooms() async {
    QuerySnapshot snapshot = await firestore
        .collection('room')
        .where('status', isEqualTo: 'ว่าง')
        .get();
    return snapshot.docs;
  }

  Future<void> addData() async {
    try {
      await firestore.collection('user').doc(_nid).set({
        'name': _name,
        'lastname': _lastname,
        'room': _selectedRooms.toList(),
        'id_card': _nid,
        'contact': _contact,
        'checkin': _selectedDate,
        'tv': _tv,
        'fridge': _fridge,
        'status': 'กำลังจอง'
      });

      for (String roomId in _selectedRooms) {
        await firestore
            .collection('room')
            .doc(roomId)
            .update({'status': 'กำลังจอง'});
      }

      _showSuccessDialog();
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
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

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pink[50],
          title: const Text('Error'),
          content: Text(errorMessage),
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ชื่อ"),
                TextFormField(
                  decoration:
                      textFieldDecoration.copyWith(hintText: 'กรอกชื่อ'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'กรุณากรอกชื่อ' : null,
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 15),
                const Text("นามสกุล"),
                TextFormField(
                  decoration:
                      textFieldDecoration.copyWith(hintText: 'กรอกนามสกุล'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'กรุณากรอกนามสกุล'
                      : null,
                  onSaved: (value) => _lastname = value!,
                ),
                const SizedBox(height: 15),
                const Text("เลขบัตรประจำตัวประชาชน"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'กรอกเลขบัตรประชาชน'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเลขบัตรประชาชน';
                    } else if (!RegExp(r'^[0-9]{13}$').hasMatch(value)) {
                      return 'เลขบัตรประชาชนต้องเป็นตัวเลข 13 หลัก';
                    }
                    return null;
                  },
                  onSaved: (value) => _nid = value!,
                ),
                const SizedBox(height: 15),
                const Text("เบอร์โทรติดต่อ"),
                TextFormField(
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'กรอกเบอร์โทรศัพท์'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกเบอร์โทรศัพท์';
                    } else if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                      return 'เบอร์โทรศัพท์ต้องเป็นตัวเลข 10 หลัก และขึ้นต้นด้วย 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _contact = value!,
                ),
                const SizedBox(height: 15),
                const Text("เลือกห้องที่ต้องการจอง"),
                FutureBuilder<List<DocumentSnapshot>>(
                  future: _getAvailableRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("ไม่มีห้องว่าง"));
                    }

                    return Wrap(
                      spacing: 10,
                      children: snapshot.data!.map((doc) {
                        String roomId = doc['room_id'];
                        return ChoiceChip(
                          label: Text(roomId),
                          selected: _selectedRooms.contains(roomId),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRooms.add(roomId);
                              } else {
                                _selectedRooms.remove(roomId);
                              }
                            });
                          },
                          selectedColor: Colors.pink[300],
                        );
                      }).toList(),
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[200]),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        addData();
                      }
                    },
                    child: const Text("บันทึก"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
