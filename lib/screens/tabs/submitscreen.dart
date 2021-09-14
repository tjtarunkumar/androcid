import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:androcid/models/personmodel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SubmitScreen extends StatefulWidget {
  const SubmitScreen({Key? key}) : super(key: key);

  @override
  _SubmitScreenState createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  final ImagePicker _picker = ImagePicker();
  Person _formdata = Person(name: "", mobile: "", img: "");
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _nametextController = new TextEditingController();
  final TextEditingController _mobiletextController =
      new TextEditingController();

  @override
  void dispose() {
    _nametextController.dispose();
    _mobiletextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.all(15),
      child: Card(
        elevation: 5,
        child: Form(
          key: _formkey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_formdata.img != "") ...[
                Container(
                  padding: EdgeInsets.all(10),
                  height: 100,
                  child: GestureDetector(
                    onTap: _getimage,
                    child: Image.memory(base64Decode(_formdata.img)),
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(10),
                  height: 100,
                  child: GestureDetector(
                    onTap: _getimage,
                    child: Image.asset("assets/img/usericon.png"),
                  ),
                ),
              ],
              Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    controller: _nametextController,
                    validator: (String? _name) {
                      if (_name!.isEmpty) {
                        return "Empty";
                      }
                      return null;
                    },
                    onSaved: (String? _name) {
                      _formdata.name = _name!;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Name"),
                  )),
              Container(
                  padding: EdgeInsets.only(top: 8, left: 10, right: 10),
                  child: TextFormField(
                    controller: _mobiletextController,
                    validator: (String? _name) {
                      if (_name!.isEmpty) {
                        return "Empty";
                      }
                      return null;
                    },
                    onSaved: (String? _mobile) {
                      _formdata.mobile = _mobile!;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: "Mobile No"),
                  )),
              Center(
                child: OutlinedButton(
                  child: Text("Submit"),
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      _formkey.currentState!.save();
                      var url = Uri.parse(
                          'https://gnutechnocrats.com/androcid/add.php');
                      var response = await http.post(url, body: {
                        'name': _formdata.name,
                        'mobile': _formdata.mobile,
                        'img': _formdata.img
                      });
                      _nametextController.clear();
                      _mobiletextController.clear();
                      _formdata.img = "";
                      setState(() {});
                      if (response.body.isNotEmpty) {
                        json.decode(response.body);
                      }
                      final dynamic _resdata = json.decode(response.body);
                      if (_resdata['code'] == 400) {
                        _showMyDialog(
                            context: context,
                            title: _resdata['msg'],
                            error: _resdata['errors']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Person Saved Successfully')),
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(
      {required BuildContext context,
      required String title,
      required String error}) async {
    Map<String, dynamic> errors = json.decode(error);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            height: 100,
            child: ListView(
              children: [
                if (errors['name'] != null) ...[
                  ListTile(
                    title: Text("Name Field"),
                    subtitle: Text(errors['name']),
                  )
                ],
                if (errors['mobile'] != null) ...[
                  ListTile(
                    title: Text("Mobile Field"),
                    subtitle: Text(errors['mobile']),
                  )
                ],
                if (errors['img'] != null) ...[
                  ListTile(
                    title: Text("Image Field"),
                    subtitle: Text(errors['img']),
                  )
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _getimage() async {
    if (await Permission.storage.request().isGranted) {
      final XFile? _image =
          await _picker.pickImage(source: ImageSource.gallery);
      final Uint8List? _imgbyte = await _image?.readAsBytes();
      _formdata.img = base64Encode(_imgbyte!);
      setState(() {});
    }
  }
}
