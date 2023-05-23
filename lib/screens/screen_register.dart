// screens/screen_register.dart
// 회원가입 화면
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/models/model_auth.dart';
import 'package:untitled/models/model_register.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 6, 67, 117),
          title: Text('회원가입'),
        ),
        body: Container(
          child: ListView(
            children: [
              EmailInput(),
              PasswordInput(),
              PasswordConfirmInput(),
              OldInput(),
              SexInput(),
              Padding(padding: EdgeInsets.all(10)),
              RegistButton()
            ],
          ),
        ),
      ),
    );
  }
}//회원가입화면 위젯

class EmailInput extends StatelessWidget {
  final e_controller = TextEditingController();//텍스트필드값 지우기 컨트롤러
  //이렇게 이걸 밖으로 빼놔야 텍스트필드 입력오류가 사라졋음.
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        onChanged: (email) {
          register.setEmail(email);//email값 변경
        },
        keyboardType: TextInputType.emailAddress,
        controller: e_controller,
        decoration: InputDecoration(
          labelText: '이메일',
          suffixIcon: IconButton(
            onPressed: () => e_controller.clear(),
            //suffixIcon(우측 X 아이콘)을 눌렀을 경우 clear
            icon: Icon(Icons.clear),
          ),
          hintText: 'MoodMatch@google.com',
        ),
      ),
    );
  }
}//이메일 입력 위젯
class PasswordInput extends StatelessWidget {
  final pController = TextEditingController();//텍스트 필드 값 지우기 컨트롤러
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        onChanged: (password) {
          register.setPassword(password);//password값 변경
        },
        obscureText: true,
        keyboardType: TextInputType.name,
        controller: pController,
        decoration: InputDecoration(
          labelText: '비밀번호 입력',
          hintText: '6자리 이상 입력해주세요',
          suffixIcon: IconButton(
            onPressed: () => pController.clear(),
            //suffixIcon(우측 X 아이콘)을 눌렀을 경우 clear
            icon: Icon(Icons.clear),
          ),
          errorText: register.password != register.passwordConfirm ? 'Password incorrect' : null,
        ),
      ),
    );
  }
}
class PasswordConfirmInput extends StatelessWidget {
  final pccontroller = TextEditingController();//텍스트필드값 지우기 컨트롤러
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false); //listen : UI를 새로 그려줄 필요는 없습니다.`
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        onChanged: (password) {
          register.setPasswordConfirm(password);//passwordconfirm값 변경
        },
        obscureText: true,
        controller: pccontroller,
        decoration: InputDecoration(
          labelText: '비밀번호 확인',
          suffixIcon: IconButton(
            onPressed: () => pccontroller.clear(),
            //suffixIcon(우측 X 아이콘)을 눌렀을 경우 clear
            icon: Icon(Icons.clear),
          ),
          hintText: '동일한 비밀번호를 입력해주세요',
        ),
      ),
    );
  }
}//비밀번호 확인 입력 위젯

class SexInput extends StatefulWidget {
  @override
  State<SexInput> createState() => _SexInputState();
}

class _SexInputState extends State<SexInput> {
  final _sex = ['남성','여성'];
  String? _selectedSex;
  @override
  void initState(){
    super.initState();
    setState((){
      _selectedSex = _sex[0];
    });
  }
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false); //listen : UI를 새로 그려줄 필요는 없습니다.`
    return Container(
      padding: EdgeInsets.all(10),
      child:
        DropdownButtonFormField(
          value: _selectedSex,
          items: _sex.map(
                  (e) => DropdownMenuItem(value : e, child : Text(e),)
          ).toList(),
          onChanged: (value){
            setState((){
              _selectedSex = value!;
              register.setsex(value);
            });
          },
          decoration: InputDecoration(
            labelText: "성별"
          ),
        ),
    );
  }
}//성별 입력 위젯


class OldInput extends StatelessWidget {
  final ocontroller = TextEditingController();//텍스트필드값 지우기 컨트롤러
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false); //listen : UI를 새로 그려줄 필요는 없습니다.`

    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        onChanged: (old) {
          register.setold(old);//old값 변경
        },
        keyboardType: TextInputType.number,
        controller: ocontroller,
        decoration: InputDecoration(
          labelText: '나이 입력',
          suffixIcon: IconButton(
            onPressed: () => ocontroller.clear(),
            //suffixIcon(우측 X 아이콘)을 눌렀을 경우 clear
            icon: Icon(Icons.clear),
          ),
          hintText: '나이를 입력해주세요',
        ),
      ),
    );
  }
}//나이 입력 위젯


class RegistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final register = Provider.of<RegisterModel>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.7, //MedeiaQuery(앱 화면 크기를 알아냄.여기선 앱화면의 width)
      height: MediaQuery.of(context).size.height * 0.05,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: (register.password != register.passwordConfirm || register.email.isEmpty || register.password.isEmpty || register.old.isEmpty) ? null : () async {//버튼을 눌렀을 떄 동일 비밀번호가 아니면
          await authClient
              .registerWithEmail(register.email, register.password)
              .then((registerStatus) {
            if (registerStatus == AuthStatus.registerSuccess) {
              sendRegisterInfoToServer(register.email, register.password, register.sex, register.old);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('회원가입 성공')),
                );
              Navigator.pop(context);
              //Navigator.pop(context) : 화면이 스택구조로 쌓이게 되면 바로 전에 쌓인 화면으로 감.
              //즉, register전의 화면은 login화면이기 때문에 login화면에서 push로 넣어줘서 login이 담김.
              //따라서 현재에서 pop을 해주면 login화면으로 감.
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('회원가입 실패')),
                );
            }
          });
        },
        child: Text('회원가입'),
      ),
    );
  }
}//회원가입완료버튼 위젯
//..은 함수의 반환 객체를 뜻하는 다트 문법.
//쓰지 않으려면
// var scaffoldMessenger = ScaffoldMessenger.of(context)
// scaffoldMessenger.hideCurrentSnackBar()
// scaffoldMessenger.showSnackBar(SnackBar(content: Text('Regist Success!!')));
// 이거 써주면 됨.

// 텍스트 값을 Flask 서버에 보내는 함수(보내지는거 확인완료.근데 애뮬레이터에서 한글이 안쳐짐. 이건 해결해야함.)
Future<String> sendRegisterInfoToServer(String id, String pw, String sex, String age) async {
  var url = Uri.parse('http://34.66.37.198/signin');
  var data = {'ID': id, 'Password':pw, 'Sex':sex, 'Age':age};
  var body = json.encode(data);
  var response = await http.post(url, headers: {"Content-Type": "application/json"},
      body: body);
  if(response.statusCode == 200) {
    return response.body;
  }else{
    throw Exception('Failed to send Register Information to server');
  }
}