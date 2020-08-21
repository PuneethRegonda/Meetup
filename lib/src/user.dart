class User {
  String name;
  String uid;
  bool profileFilled;
  List interest;
  Map<String, dynamic> friends;
  Map<String, dynamic> requests;

  User(
      {this.uid,
      this.name,
      this.interest,
      this.profileFilled = false,
      this.friends,
      this.requests});

  static User fromJSON(Map<String, dynamic> map, String id) {
    if (map != null) {
      List list = map['interests'];
      return User(
        name: map['name'] != null ? map['name'] : "null",
        uid: id,
        interest: list != null ? list : null,
        profileFilled: list != null && list.isNotEmpty,
        friends: map['friends']!=null? map['friends']:null,
        requests: map['requests']!=null?map['requests']:null,
      );
    }

    return null;
  }

  @override
  String toString() {
    return "$name $uid $friends $profileFilled ";
  }


}
