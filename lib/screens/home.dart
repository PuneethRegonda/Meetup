import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meetup/main.dart';
import 'package:meetup/screens/chat.dart';
import 'package:meetup/screens/menu.dart';
import 'package:meetup/services/user_services.dart';
import 'package:meetup/src/assests.dart';
import 'package:meetup/src/result.dart';
import 'package:meetup/src/user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    // getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuScreen(edit: true)));
              }),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                return showDialog(
                      context: context,
                      child: AlertDialog(
                        title: Text('Do you want to exit this application?'),
                        content: Text('We hate to see you leave...'),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () {
                              print("you choose no");
                              Navigator.of(context).pop(false);
                            },
                            child: Text('No'),
                          ),
                          FlatButton(
                            onPressed: () {
                              logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false);
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              })
        ],
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.black,
          tabs: [
            new Tab(
              icon: new Icon(Icons.chat),
              child: Text("Chats",style: GoogleFonts.ubuntuCondensed(),),
            ),
            new Tab(
              icon: new Icon(Icons.group_add),
              child: Text("Common Interests",style: GoogleFonts.ubuntuCondensed()),
            ),
            new Tab(
              icon: new Icon(Icons.group),
              child: Text("Pending Requests",style: GoogleFonts.ubuntuCondensed()),
            ),
          ],
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        bottomOpacity: 1,
        title: Text(
          Constants.appname,
          style: GoogleFonts.ubuntuCondensed().copyWith(color: Colors.white,fontSize: 25.0,fontWeight: FontWeight.bold,letterSpacing: 0.4),
        ),
      ),
      body: TabBarView(
        children: [
          ChatTabPage(),
          CommonInterestTabPage(),
          PendingRequestTabPage()
        ],
        controller: _tabController,
      ),
    );
  }

  Future logout() async {
    await UserServices().logout();
  }
}

class CommonInterestTabPage extends StatefulWidget {
  @override
  _CommonInterestTabPageState createState() => _CommonInterestTabPageState();
}

class _CommonInterestTabPageState extends State<CommonInterestTabPage> {
  Future<Result> sendHelloReq(String friendUID, String friendName) async {
    Result result =
        await UserServices().sendFriendRequest(friendUID, friendName);
    print(result.message);

    setState(() {});
  }

  Future<Result> getCommonInterests() async {
    return await UserServices().getUsersWithCommonInterests();
  }

  Widget getUserCard(User user) {
    return ListTile(
        subtitle: Text(
          "Interests:" + user.interest.toString(),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        title: Text(user.name),
        trailing: ActionChip(
            backgroundColor: Constants.primaryColor,
            label: Text('Hello 🖐👋'),
            onPressed: () {
              print("sending hello req");
              setState(() {
                _future = getCommonInterests();
                sendHelloReq(user.uid, user.name);
              });
            }));
  }

  Future<Result> _future;
  @override
  void initState() {
    _future = getCommonInterests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Result> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: new Text('Loading...'));
          default:
            if (!snapshot.hasData) {
              return Center(
                child: Text("Something went wrong"),
              );
            }
            if (snapshot.data.isSuccess && snapshot.data.data != null) {
              return new ListView.builder(
                  itemCount: snapshot.data.data.length,
                  itemBuilder: (context, index) {
                    return getUserCard(snapshot.data.data[index]);
                  });
            } else {
              return Center(
                child: Text(snapshot.data.message),
              );
            }
        }
      },
    );
  }
}

class ChatTabPage extends StatefulWidget {
  @override
  _ChatTabPageState createState() => _ChatTabPageState();
}

class _ChatTabPageState extends State<ChatTabPage> {
  Future<Result> _future;
  Widget getChatCard(User user) {
    return ListTile(
      title: Text(user.name),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => ChatScreen(user)));
        print(user.name);
      },
    );
  }

  Future<Result> getFriends() async {
    return await UserServices().getFriends();
  }

  @override
  void initState() {
    _future = getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Result> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: new Text('Loading...'));
          default:
            if (!snapshot.hasData) {
              return Center(
                child: Text("Something went wrong"),
              );
            }
            if (snapshot.data.isSuccess && snapshot.data.data != null) {
              return new ListView.builder(
                  itemCount: snapshot.data.data.length,
                  itemBuilder: (context, index) {
                    return getChatCard(snapshot.data.data[index]);
                  });
            } else {
              return Center(
                child: Text(snapshot.data.message),
              );
            }
        }
      },
    );
  }
}

class PendingRequestTabPage extends StatefulWidget {
  @override
  _PendingRequestTabPageState createState() => _PendingRequestTabPageState();
}

class _PendingRequestTabPageState extends State<PendingRequestTabPage> {
  Future<Result> _future;

  Future acceptFriendRequest(String friendUID, friendName) async {
    print("accepting friend request");
    await UserServices().acceptFriendRequest(friendUID, friendName);
  }

  Future<Result> getPendingRequests() async {
    return await UserServices().getUserPendingRequests();
  }

  Widget getPendingRequestCard(User user) {
    return ListTile(
        subtitle: Text(
          "Interests:" + user.interest.toString(),
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        title: Text(user.name),
        trailing: ActionChip(
            backgroundColor: Colors.blue,
            label: Text('Accept request ✔'),
            onPressed: () {
              print("accepting req");
              setState(() {
                acceptFriendRequest(user.uid, user.name);
                _future = getPendingRequests();
              });
            }));
  }

  @override
  void initState() {
    _future = getPendingRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<Result> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: new Text('Loading...'));
          default:
            if (!snapshot.hasData) {
              print(snapshot.data);
              return Center(
                child: Text("Something went wrong"),
              );
            }
            if (snapshot.data.isSuccess && snapshot.data.data != null) {
              return new ListView.builder(
                  itemCount: snapshot.data.data.length,
                  itemBuilder: (context, index) {
                    return getPendingRequestCard(snapshot.data.data[index]);
                  });
            } else {
              return Center(
                child: Text(snapshot.data.message),
              );
            }
        }
      },
    );
  }
}
