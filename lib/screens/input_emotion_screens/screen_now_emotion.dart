import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/shared_screens/bottombar.dart';
import 'package:untitled/screens/shared_screens/menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Now_emotion_Page extends StatelessWidget {
  const Now_emotion_Page({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 67, 117),
        title: Text(title+': 현재 감정'),
      ),
      endDrawer : SafeArea(
          child:
          Menu()
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: (() {
                sendNowEmotionToServer('neg');
                Navigator.of(context).pushNamed('/hope_emotion');
              }),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //Image.asset('assets/images/gromit.png'),
                    const ListTile(
                      title: Text("부정"),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                    )
                  ],
                ),
              ),
            ),

            GestureDetector(
              onTap: (() {
                sendNowEmotionToServer('neu');
                Navigator.of(context).pushNamed('/hope_emotion');
              }),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //Image.asset('assets/images/gromit.png'),
                    const ListTile(
                      title: Text("중립"),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                    )
                  ],
                ),
              ),
            ),

            GestureDetector(
              onTap: (() {
                sendNowEmotionToServer('pos');
                Navigator.of(context).pushNamed('/hope_emotion');
              }),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    //Image.asset('assets/images/gromit.png'),
                    const ListTile(
                      title: Text("긍정"),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottombar(),
    );
  }
}

// 텍스트 값을 Flask 서버에 보내는 함수(보내지는거 확인완료.근데 애뮬레이터에서 한글이 안쳐짐. 이건 해결해야함.)
Future<String> sendNowEmotionToServer(String ne) async {
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  final e  =user!.email;
  var url = Uri.parse('http://34.66.37.198:5000/emobutton');
  var data = {'now_emotion': ne, 'ID': e};
  var body = json.encode(data);
  var response = await http.post(url, headers: {"Content-Type": "application/json"},
      body: body);
  if(response.statusCode == 200) {
    throw response.body;
  }else{
    throw Exception('Failed to send now emotion to server');
  }
}
