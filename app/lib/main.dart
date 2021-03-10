import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(
      home: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  final picker = ImagePicker();

  TextEditingController _nameController = TextEditingController();

  File file;

  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 1980,
      maxHeight: 1080,
      imageQuality: 50,
    );
    file = File(pickedFile.path);

    print("PickedFile");
    //_upload();

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageGallery() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 1980,
      maxHeight: 1080,
      imageQuality: 50,
    );

    file = File(pickedFile.path);
    print("PickedFile");
    //_upload();
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _upload() {
    print('Inside _upload\n');
    String base64Image = base64Encode(file.readAsBytesSync());
    print('Base64image:     ' + base64Image);
    uploadFile(base64Image);
  }

  Map responseJson;

  void nul() {
    setState(() {
      responseJson = null;
      _image = null;
      isLoading = false;
      msg = null;
    });
  }

  bool isLoading = false;
  var msg;

  void uploadFile(filePath) async {
//    String fileName = basename(filePath.path);
//    print("File base name: $fileName");
    setState(() {
      isLoading = true;
    });
    print("Number of hours: " + _nameController.text);

    try {
      print('Inside try');
      FormData formData = new FormData.fromMap({
        "time": _nameController.text,
        "file_data": filePath,
//        "file": MultipartFile.fromFile(filePath.path, filename: fileName),
      });

      //, contentType: new MediaType('image', 'jpg')
      print('parsed formData');
      //var uri = Uri.parse("http://127.0.0.1:5000");
      Response<Map> response = await Dio().post(
        "http://ec2-34-207-90-136.compute-1.amazonaws.com:8080",
        data: formData,
      );

      print('getting response');
      print("File Upload Response: $response");

      setState(() {
        responseJson = response.data;
        isLoading = false;
      });

      print('json created');
      //print(responseJson['End Time']);
    } catch (e) {
      print("Exception : $e");
      setState(() {
        msg = 'Some Error Occurred! Please Try again';
        isLoading = false;
      });
    }
  }

  Widget data() {
    return Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Receipt No.: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                responseJson["Receipt No."],
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                height: 6.0,
              ),
              Text(
                'Reg No.: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                responseJson["Reg No."],
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                height: 6.0,
              ),
              Text(
                'Start Time: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                responseJson['Start Time'],
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(
                height: 6.0,
              ),
              Text(
                'End Time: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                responseJson["End Time"],
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text('ParkBill'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.amberAccent,
              ),
              child: TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.amberAccent),
                decoration: InputDecoration(
                  hintText: "Parking Hours",
                  labelText: "Time",
                  border: OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.amberAccent)),
                  labelStyle: new TextStyle(
                    color: Colors.amberAccent,
                  ),
                  prefixIcon: Icon(Icons.timer),
                  suffixText: 'Hrs',
                  suffixStyle: const TextStyle(color: Colors.amberAccent),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          //],
          //),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton.icon(
                onPressed: getImageGallery,
                icon: Icon(Icons.folder),
                label: Text('Choose From Gallery'),
                color: Colors.amberAccent,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton.icon(
                onPressed: getImage,
                icon: Icon(Icons.camera),
                label: Text('Shoot Now'),
                color: Colors.amberAccent,
                padding: EdgeInsets.fromLTRB(42, 5, 42, 5),
              ),
            ],
          ),
          _image == null
              ? Text('No image selected!',
                  style: TextStyle(
                    color: Colors.amberAccent,
                  ))
              : Text('Please Press Submit',
                  style: TextStyle(
                    color: Colors.amberAccent,
                  )),
          Text(' '),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton.icon(
                onPressed: _upload,
                icon: Icon(Icons.send),
                label: Text('Submit'),
                color: Colors.amberAccent,
                padding: EdgeInsets.fromLTRB(52, 5, 52, 5),
              ),
            ],
          ),
          //data(),
          Text(' '),
          isLoading == false
              ? Text('')
              : Center(
                  child: CircularProgressIndicator(),
                ),
          responseJson == null ? Text('') : data(),
          Text(' '),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton.icon(
                onPressed: nul,
                icon: Icon(Icons.delete),
                label: Text('Clear'),
                color: Colors.amberAccent,
                padding: EdgeInsets.fromLTRB(57, 5, 57, 5),
              ),
            ],
          ),
          msg == null
              ? Text('')
              : Text(msg,
                  style: TextStyle(
                    color: Colors.redAccent,
                  )),
          //_finalres,
        ],
      ),
    );
  }
}
