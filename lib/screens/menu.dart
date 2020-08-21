import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meetup/screens/info.dart';
import 'package:meetup/src/assests.dart';
import 'package:meetup/screens/home.dart';
import 'package:meetup/services/user_services.dart';
import 'package:meetup/src/interests.dart';
import 'package:meetup/src/result.dart';

class MenuScreen extends StatefulWidget {
  final bool edit;

  const MenuScreen({this.edit = false});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _menuScafoldkey =
      new GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> _interestsSnapshots = [];
  static int count = 0;
  List<bool> selectedList = List.generate(Interests.length, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _menuScafoldkey,
        appBar: AppBar(
          title: Text(Constants.interests),
          centerTitle: true,
          actions: [_getSubmitButton()],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('interests').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: new Text('Loading...'));
              default:
                _interestsSnapshots = snapshot.data.documents;
                return new ListView.builder(
                    itemCount: _interestsSnapshots.length,
                    itemBuilder: (context, index) => _getInterestCard(index));
            }
          },
        ));
  }

  Widget _getInterestCard(int index) {
    return CheckboxListTile(
        secondary: IconButton(
            icon: Icon(
              Icons.info,
              color: Constants.primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      InfoScreen(_interestsSnapshots[index].data)));
            }),
        checkColor: Colors.black,
        activeColor: Constants.primaryColor,
        value: getValue(index),
        onChanged: (bool newValue) {
          if (!(widget.edit &&
              UserServices()
                  .isUserInterested(_interestsSnapshots[index].documentID))) {
            setState(() {
              newValue ? count++ : count--;
              selectedList[index] = newValue;
            });
          }
        },
        title: Text(_interestsSnapshots[index]['title']));
  }

  _getSubmitButton() {
    return count > 0
        ? IconButton(
            onPressed: _onInterestSubmit,
            icon: Icon(Icons.send),
          )
        : Container();
  }

  _onInterestSubmit() async {
    if (widget.edit) {
      return showDialog(
            context: context,
            child: AlertDialog(
              title: Text('Do you want update your Interests'),
              content: Text(
                  'This can help you find more friends with common interests.'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    print("you choose no");
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                FlatButton(
                  onPressed: () async {
                    Result result = await UserServices()
                        .submitInterests(selectedList, _interestsSnapshots);
                    if (result != null && result.isSuccess) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(builder: (context) => HomePage()),
                          (route) => false);
                    } else
                      showSnackBar(result.message);
                  },
                  child: Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      Result result = await UserServices()
          .submitInterests(selectedList, _interestsSnapshots);
      if (result != null && result.isSuccess) {
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => HomePage()),
            (route) => false);
      } else
        showSnackBar(result.message);
    }
  }

  void showSnackBar(String s) {
    _menuScafoldkey.currentState.showSnackBar(SnackBar(
      content: Text(s),
      duration: Duration(seconds: 3),
    ));
  }

  bool getValue(int index) {
    if (widget.edit &&
        UserServices()
            .isUserInterested(_interestsSnapshots[index].documentID)) {
      selectedList[index] = true;
      print(_interestsSnapshots[index]['title'].toString());
    }
    return selectedList[index];
  }
}
