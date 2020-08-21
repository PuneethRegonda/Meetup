class Result{
  bool isSuccess=false;
  dynamic data;
  String message;
  Result({this.isSuccess=false,this.data,this.message=""});

  @override
  String toString() {
    return "$isSuccess , ${data.toString()}, $message";
  }

}