import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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
  final ip = 'ec2-34-226-153-146.compute-1.amazonaws.com';

  TextEditingController _nameController = TextEditingController();
//  static GlobalKey receipt = new GlobalKey();

  File file;
  var err;

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
    msg = '';
    try {
      String base64Image = base64Encode(file.readAsBytesSync());
      //print('Base64image:     ' + base64Image);
      uploadFile(base64Image);
    } catch (e) {
      err = 'Image not Selected';
      _showDialog(err);
    }
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
        "http://$ip:8080",
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
//        msg = 'Some error occured';
        isLoading = false;
      });
      err = 'Something went wrong!\nPlease try again.';
      _showDialog(err);
    }
  }

//  void _download() {
//    _getWidgetImage().then((img) {
//      final pdf = new PdfDocument();
//      final page = new PdfPage(pdf,
//          pageFormat:
//              PdfPageFormat(75.0 * PdfPageFormat.MM, 100.0 * PdfPageFormat.MM));
//      final g = page.getGraphics();
//      final font = new PdfFont(pdf);
//
//      PdfImage image = new PdfImage(pdf,
//          image: img.buffer.asUint8List(),
//          width: img.width,
//          height: img.height);
//      g.drawImage(
//          image, 100.0 * PdfPageFormat.MM, 0.0, 75.0 * PdfPageFormat.MM);
//
//      Printing.printPdf(document: pdf);
//    });
//  }

//  void _download() {
//    _getWidgetImage().then((img) {
//      PdfDocument document = PdfDocument();
//      document.pages
//          .add()
//          .graphics
//          .drawImage(img, Rect.fromLTWH(0, 0, 100, 100));
////      final directory = getExternalStorageDirectory();
////      final path = directory.path;
////
////      File('$path/Output.pdf').writeAsBytes(document.save());
//      File('Output.pdf').writeAsBytes(document.save());
//    });
//  }
//
//  Future _getWidgetImage() async {
//    try {
//      RenderRepaintBoundary boundary =
//          receipt.currentContext.findRenderObject();
//      ui.Image image = await boundary.toImage();
//
//      ByteData byteData =
//          await image.toByteData(format: ui.ImageByteFormat.png);
//      var pngBytes = byteData.buffer.asUint8List();
//      var bs64 = base64Encode(pngBytes);
//      debugPrint(bs64.length.toString());
//      return pngBytes;
//    } catch (exception) {
//      print('Exception in widget image: $exception');
//    }
//  }
  final pdf = pw.Document();
  writeOnPdf() {
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Header(
              level: 0,
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: <pw.Widget>[
                    pw.Text('ParkBill Receipt', textScaleFactor: 2),
                  ])),
          pw.Header(level: 2, text: 'Receipt No.:'),
          pw.Paragraph(text: responseJson["Receipt No."]),
          pw.Header(level: 2, text: 'Reg No.:'),
          pw.Paragraph(text: responseJson["Reg No."]),
          pw.Header(level: 2, text: 'Start Time:'),
          pw.Paragraph(text: responseJson["Start Time"]),
          pw.Header(level: 2, text: 'End Time:'),
          pw.Paragraph(text: responseJson["End Time"]),
          pw.Padding(padding: const pw.EdgeInsets.all(10)),
        ];
      },
    ));
  }

  Future savePdf() async {
    DateTime _now = DateTime.now();
    print(
        'timestamp: ${_now.hour}:${_now.minute}:${_now.second}.${_now.millisecond}');
    Directory documentDirectory = await getExternalStorageDirectory();
    //Directory documentDirectory = await getApplicationSupportDirectory();
    //final String dirPath = documentDirectory.path.toString().substring(0, 20);
    //await Directory(dirPath).create(recursive: true);
    String documentPath = documentDirectory.path;
    File file = File(
        "$documentPath/receipt${_now.year}_${_now.month}_${_now.day}_${_now.hour}_${_now.minute}.pdf");
    String fullPath =
        "$documentPath/receipt${_now.year}_${_now.month}_${_now.day}_${_now.hour}_${_now.minute}.pdf";
    print(fullPath);
    file.writeAsBytesSync(pdf.save());
  }

  void _showDialog(err_msg) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Alert!",
            textAlign: TextAlign.center,
          ),
          content: Container(
            decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.all(new Radius.circular(64.0))),
            child: new Text(
              err_msg,
              textAlign: TextAlign.left,
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                nul();
              },
            ),
          ],
        );
      },
    );
  }

  Widget data() {
    return Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        shadowColor: Colors.amberAccent,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
//                decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                    colors: [Colors.white70, Colors.white30],
//                    begin: Alignment.topCenter,
//                    end: Alignment.bottomCenter,
//                  ),
//                ),
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
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton.icon(
                        icon: Icon(Icons.file_download),
                        label: Text('Download'),
                        onPressed: () {
                          writeOnPdf();
                          savePdf();
                          Fluttertoast.showToast(
                              msg: "Downloaded",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white70,
                              textColor: Colors.black,
                              fontSize: 16.0);
                        },
                      ),
                    ],
                  ),
                ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      resizeToAvoidBottomPadding: false,
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
//          msg == null
//              ? Text('')
//              : Text(msg,
//                  style: TextStyle(
//                    color: Colors.redAccent,
//                  )),
          //_finalres,
        ],
      ),
    );
  }
}
