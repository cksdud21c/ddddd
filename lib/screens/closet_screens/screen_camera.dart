import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();

}

class _CameraExampleState extends State<CameraExample> {
  File? _image;
  ImagePicker picker = ImagePicker();

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future getImage(ImageSource imageSource) async {
    var image = await picker.pickImage(source: imageSource);
    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장
    });
    showImage();
  }
  Future<Map<String, dynamic>> sendPictureToServer(String id) async {
    File imageFile = File(_image!.path);
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    Uri url = Uri.parse('http://34.66.37.198:5000/imgprocess');

    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode([
        {'image': '$base64Image', 'ID': id}
      ]),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String imageUrl = responseData['imageUrl'];
      String category = responseData['category'];
      return {'imageUrl': imageUrl, 'category': category};
    } else {
      throw Exception('Failed to send image value to server');
    }
  }
  void showImageDialog(String imageUrl, String category) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = category;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'If you like the category and image, click OK. To retake, click Cancel. To edit the category, select from the dropdown and press OK.',
                      ),
                      SizedBox(height: 16),
                      DropdownButton<String>(
                        value: selectedCategory,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: <String>[
                          'Outer',
                          'Top',
                          'Bottom',
                          'Shoes',
                          'Acc',
                          'NoLabel',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        // Set dropdown button's width to match the image width
                        // by using an IntrinsicWidth widget
                        dropdownColor: Colors.white,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  String OKsign = await sendOkSignToServer(selectedCategory);
                  if (OKsign == "OK") {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/closet');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Communication error: Please close the app and restart it.'),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }







  // 이미지를 보여주는 위젯
  Widget showImage() {
    return Container(
        color: const Color(0xffd0cece),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Center(
            child: _image == null
                ? Text('No image selected.')
                : Image.file(File(_image!.path))));
  }

  @override
  Widget build(BuildContext context) {
    var auth = FirebaseAuth.instance;
    var user = auth.currentUser;
    var e  =user!.email;
    // 화면 세로 고정
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 6, 67, 117),
          title: Text('옷 촬영'),
        ),
        backgroundColor: const Color(0xfff4f3f9),
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 25.0),
        showImage(),
        SizedBox(
          height: 50.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // 카메라 촬영 버튼
            FloatingActionButton(
              child: Icon(Icons.add_a_photo),
              tooltip: 'Pick Image',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('TIP'),
                      content: Text('Please make the whole picture of the clothes come out :)'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            getImage(ImageSource.camera);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            // 갤러리에서 이미지를 가져오는 버튼
            FloatingActionButton(
              child: Icon(Icons.wallpaper),
              tooltip: 'pick Image',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('TIP'),
                      content: Text('Please make the whole picture of the clothes come out :)'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            getImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.navigate_next),//다음버튼
              onPressed: () async {
                if (_image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No image')),
                  );
                } else {//이미지가 비어있지 않으면
                  // Display a progress indicator indicating that it is being analyzed
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('analyzing image...'),
                          ],
                        ),
                      );
                    },
                  );

                  Map<String, dynamic> result = await sendPictureToServer(e!);
                  Navigator.of(context).pop();//이미지처리가 완료되면 로딩팝업 닫기.

                  String imageUrl = result['imageUrl'];
                  String category = result['category']; //여기까지 완료
                  // Close the progress indicator
                  showImageDialog(imageUrl, category);
                }
              },
            ),



          ],
        )
      ],
      ),
    );
  }
}

// function to send image to Flask server
Future<String> sendOkSignToServer(String category) async {
  var url = Uri.parse('http://34.66.37.198:5000/ok');
  var data = {'category': category};
  var body = json.encode(data);
  var response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );
  if (response.statusCode == 200) {
    return "OK";
  } else {
    return "Fail";
  }
}