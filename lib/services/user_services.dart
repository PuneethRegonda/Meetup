import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:meetup/src/assests.dart';
import 'package:meetup/src/result.dart';
import 'package:meetup/src/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserServices {
  static SharedPreferences _prefs;
  static User _user;
  // static UserServices _services;
  UserServices() {
    startSession();
    print("start session");
  }

  startSession() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
  }

  saveSession(String id) async {
    print("Saving Session");
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    _prefs.setBool(Constants.isLogged, true);
    _prefs.setString(Constants.id, id);
  }

  loadSession() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    Result result = Result();
    if (_prefs.containsKey(Constants.isLogged) &&
        _prefs.getBool(Constants.isLogged)) {
      bool loggedIn = _prefs.getBool(Constants.isLogged);
      result.data = await fetchUser(_prefs.get(Constants.id));
      result.isSuccess = loggedIn;
    } else
      _prefs.setBool(Constants.isLogged, false);
    return result;
  }

  Future fetchUser(String id) async {
    if (_user == null) {
      print("fetching user details");

      DocumentSnapshot userMap =
          await Firestore.instance.collection('users').document(id).get();

      print(userMap.data);
      _user = User.fromJSON(userMap.data, id);
    }
    return _user;
  }

  Future submitInterests(
      List<bool> selectedList, List<DocumentSnapshot> snapshots) async {
    Result result = Result();

    try {
      List<String> interests = [];

      for (int index = 0; index < selectedList.length; index++) {
        if (selectedList[index]) interests.add(snapshots[index].documentID);
      }

      // http.Response response =
      //     await http.patch(url, body: json.encode({"interests": interests}));

      await Firestore.instance
          .collection('users')
          .document(_user.uid)
          .updateData({
        "interests": FieldValue.arrayUnion(interests)
      }).whenComplete(() => result.isSuccess = true);

      DocumentSnapshot userMap = await Firestore.instance
          .collection('users')
          .document(_user.uid)
          .get();

      print(userMap.data);
      _user = User.fromJSON(userMap.data, _user.uid);

      for (int index = 0; index < selectedList.length; index++) {
        if (selectedList[index])
          await Firestore.instance
              .collection('interests')
              .document(snapshots[index].documentID)
              .updateData({
            "people": FieldValue.arrayUnion([_user.uid])
          });
      }

      // result.isSuccess = response.statusCode == 200;
      if (result.isSuccess) {
        // result.data = json.decode(response.body);
        result.message = "Successfuly updated Interests";
      } else {
        result.message = "Something went wrong!";
      }
      print("returning result ${result.toString()}");
      return result;
    } catch (e) {
      return result;
    }
  }

  Future getUsersWithCommonInterests() async {
    List<User> users = [];
    // set of uids and then get people arrays of user interests documents
    Set<String> usersUIDs = Set();

    for (dynamic interest in _user.interest) {
      DocumentSnapshot snapshot = await Firestore.instance
          .collection('interests')
          .document(interest.toString())
          .get();

      // print("${snapshot.documentID} : ${snapshot.data}");
      List people = snapshot.data['people'];
      usersUIDs.addAll(people.map((e) => e.toString()));
    }

    usersUIDs.remove(_user.uid);

    if (_user.friends != null && _user.friends.isNotEmpty) {
      usersUIDs.removeAll(_user.friends.keys);
      // Set.from(_user.friends.keys.map((e) => usersUIDs.remove(e.toString())));
    }

    if (_user.requests != null && _user.requests.isNotEmpty) {
      usersUIDs.removeAll(_user.requests.keys);
    }

    print("commonUsers $usersUIDs");

    Result result = Result();
    // result.data = usersUIDs.toList();
    result.isSuccess = usersUIDs.isNotEmpty;
    // user UID are present
    if (!result.isSuccess)
      result.message = "No Friends found with Common Interest";
    else {
      // fetch user details.
      for (String uid in usersUIDs) {
        DocumentSnapshot snapshot =
            await Firestore.instance.collection('users').document(uid).get();
        if (snapshot.exists) {
          Map<String, dynamic> m = snapshot.data;
          m.remove('requests');
          users.add(User.fromJSON(m, uid));
        }
      }
    }
    result.data = users;
    print(result);
    return result;
  }

  Future sendFriendRequest(String friendUID, String friendName) async {
    String userUID = _user.uid;
    String roomID = "";
    if (userUID.compareTo(friendUID).isNegative) {
      roomID = userUID + "_" + friendUID;
    } else {
      roomID = (friendUID + "_" + userUID);
    }
    Result result = Result();
    await Future.wait([
      Firestore.instance.collection('chats').document(roomID).setData({
        'chat_init': false,
        'req_UID': _user.uid,
        'ac_UID': friendUID,
        'req_person': _user.name,
        'ac_person': friendName,
        'date': DateTime.now().toUtc()
      }),
      Firestore.instance.collection('users').document(friendUID).setData({
        "requests": {_user.uid: _user.name}
      }, merge: true)
    ]).whenComplete(() async {
      result.isSuccess = true;
      String id = _user.uid;
      _user = null;
     await fetchUser(id);
    });
    if (result.isSuccess)
      result.message = "Hello Request Sent.";
    else
      result.message = "Something went wrong!!";

    return result;
  }

  Future acceptFriendRequest(String friendUID, friendName) async {
    String userUID = _user.uid;
    String roomID = "";
    if (userUID.compareTo(friendUID).isNegative) {
      roomID = userUID + "_" + friendUID;
    } else {
      roomID = (friendUID + "_" + userUID);
    }

    DocumentSnapshot friendDOC =
        await Firestore.instance.collection('users').document(friendUID).get();
    Map<String, dynamic> friendMAP = friendDOC.data;

    DocumentSnapshot userDOC =
        await Firestore.instance.collection('users').document(_user.uid).get();
    Map<String, dynamic> userMAP = userDOC.data;

    // print(friendMAP);
    // print(friendMAP['requests']);

    if (userMAP['requests'].containsKey(friendUID)) {
      userMAP['requests'].remove(friendUID);
    }
    if (friendMAP['requests'].containsKey(_user.uid)) {
      friendMAP['requests'].remove(_user.uid);
    }
    // userMAP['requests'].remove(friendUID);
    Result result = Result();
    await Future.wait([
      Firestore.instance
          .collection('chats')
          .document(roomID)
          .updateData({'chat_init': true, 'date': DateTime.now().toUtc()}),
      Firestore.instance.collection('users').document(_user.uid).updateData(
        {"requests": userMAP['requests']},
      ),
      Firestore.instance.collection('users').document(friendUID).updateData(
        {"requests": friendMAP['requests']},
      ),
      Firestore.instance.collection('users').document(_user.uid).setData({
        "friends": {friendUID: friendName}
      }, merge: true),
      Firestore.instance.collection('users').document(friendUID).setData({
        "friends": {_user.uid: _user.name}
      }, merge: true),
    ]).whenComplete(() async {
      result.isSuccess = true;
      String id = _user.uid;
      _user = null;
     await fetchUser(id);
    });
    if (result.isSuccess)
      result.message = "Friend Request Accepted";
    else
      result.message = "Something went wrong!!";

    return result;
  }

  Future getUserPendingRequests() async {
    List<User> users = [];
    if (_user.requests != null)
      for (String uid in _user.requests.keys) {
        DocumentSnapshot snapshot =
            await Firestore.instance.collection('users').document(uid).get();
        if (snapshot.exists) {
          Map<String, dynamic> m = snapshot.data;
          m.remove('requests');
          users.add(User.fromJSON(m, uid));
        }
      }
    Result result = Result();
    result.isSuccess = users.isNotEmpty;
    if (!result.isSuccess) result.message = "You have no Pending Requests";
    result.data = users;
    return result;
  }

  Future getFriends() async {
    List<User> users = [];
    if (_user.friends != null)
      for (String uid in _user.friends.keys) {
        DocumentSnapshot snapshot =
            await Firestore.instance.collection('users').document(uid).get();
        if (snapshot.exists) {
          Map<String, dynamic> m = snapshot.data;
          m.remove('requests');
          users.add(User.fromJSON(m, uid));
        }
      }
    Result result = Result();
    result.isSuccess = users.isNotEmpty;
    if (!result.isSuccess) result.message = "You have no Friends";

    result.data = users;
    return result;
  }

  String getRoomID(String friendUID) {
    String userUID = _user.uid;
    String roomID = "";
    if (userUID.compareTo(friendUID).isNegative) {
      roomID = userUID + "_" + friendUID;
    } else {
      roomID = (friendUID + "_" + userUID);
    }
    return roomID;
  }

  Future sendMessage(ChatMessage message, String friendUID) async {
    var documentReference = Firestore.instance
        .collection('chats')
        .document(getRoomID(friendUID))
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    await Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
  }

  User getUser() => _user;

  Future<bool> logout() async {
    await _prefs.setBool(Constants.isLogged, false);
    _user = null;

    print(_prefs.getBool(Constants.isLogged));

    return await _prefs.clear();
  }

  bool isUserInterested(String interestName) {
    return _user.interest.contains(interestName);
  }

}
