import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetup/Animation/FadeAnimation.dart';
import 'package:meetup/screens/home.dart';
import 'package:meetup/screens/menu.dart';
import 'package:meetup/services/auth_service.dart';
import 'package:meetup/services/user_services.dart';
import 'package:meetup/src/assests.dart';
import 'package:meetup/src/result.dart';
import 'package:meetup/src/user.dart';

void main() => runApp(MaterialApp(
      title: Constants.appname,
      theme: ThemeData(
        textTheme: GoogleFonts.ubuntuCondensedTextTheme(),
        primaryColor: Constants.primaryColor,
        backgroundColor: Colors.white,
        // fontFamily:
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    ));

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  Widget getBody() {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Center(
            child: Text(Constants.appname,
                style: GoogleFonts.ubuntuCondensed().copyWith(
                  color: Constants.primaryColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                )),
          ),
        )));
  }

  void loadSession() async {
    UserServices userServices = UserServices();
    Result result = await userServices.loadSession();
    if (result.isSuccess) {
      User user = result.data;
      if (user.profileFilled)
        Future.delayed(const Duration(seconds: 3)).then((value) => {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (BuildContext con) => HomePage()),
                  (route) => false)
            });
      else
        Future.delayed(const Duration(seconds: 3)).then((value) => {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                      builder: (BuildContext con) => MenuScreen()),
                  (route) => false)
            });
    } else {
      Future.delayed(const Duration(seconds: 3)).then((value) => {
            Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (BuildContext con) => LoginPage()),
                (route) => false)
          });
    }
  }

  @override
  void initState() {
    loadSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getBody();
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String placeholderTXT = "Login", onTapTEXT = "Dont have an Account? Register";
  // ignore: non_constant_identifier_names
  bool IsLOGIN = true;
  AuthService _authService = AuthService();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _name = TextEditingController();

  void onLoginSubmit() async {
    if (IsLOGIN) {
      Result result = await _authService.signInWithEmailAndPassword(
          _email.text, _password.text);
      if (result.isSuccess) {
        User user = result.data;
        if (user.profileFilled) {
          UserServices().saveSession(result.data.uid);
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (BuildContext con) => HomePage()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (BuildContext con) => MenuScreen()),
              (route) => false);
        }
      } else
        showSnackBar("Something went wrong!");
    } else {
      Result res = await _authService.registerWithEmailAndPassword(
          _email.text, _password.text, _name.text);
      if (res.isSuccess) {
        UserServices().saveSession(res.data.uid);
        showSnackBar(
            "Resgistration Successful. Please Login with credentitals");
      } else {
        showSnackBar("Something went wrong!!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                            1.3,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeAnimation(
                            1.5,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            )),
                      ),
                      Positioned(
                        child: FadeAnimation(
                            1.6,
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Text(
                                  "MeetUp",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(
                          1.8,
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(143, 148, 251, .2),
                                      blurRadius: 20.0,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                !IsLOGIN
                                    ? Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[100]))),
                                        child: TextField(
                                          controller: _name,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Name",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[400])),
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[100]))),
                                  child: TextField(
                                    controller: _email,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: _password,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: onLoginSubmit,
                        child: FadeAnimation(
                            2,
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6),
                                  ])),
                              child: Center(
                                child: Text(
                                  placeholderTXT,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      InkWell(
                          onTap: () {
                            if (IsLOGIN) {
                              placeholderTXT = "Register";
                              onTapTEXT = "Already have an Account? Login";
                            } else {
                              onTapTEXT = "Dont have an Account? Register";
                              placeholderTXT = "Login";
                            }
                            setState(() {
                              IsLOGIN = !IsLOGIN;
                            });
                          },
                          child: FadeAnimation(
                              1.5,
                              Text(
                                onTapTEXT,
                                style: TextStyle(
                                    color: Color.fromRGBO(143, 148, 251, 1)),
                              ))),
                      // SizedBox(height: 45,),
                      // FadeAnimation(1.5, Text("Forgot Password?", style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void showSnackBar(String s) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(s),
      duration: Duration(seconds: 3),
    ));
  }
}
