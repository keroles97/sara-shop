class MessageModel {
  String? senderUid;
  String? body;
  Object? date;

  MessageModel({
    this.senderUid,
    this.body,
    this.date,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    senderUid = json["senderUid"];
    body = json["body"];
    date = json["date"].toString();
  }

  Map<String, dynamic> toMap() {
    return {
      "senderUid": senderUid,
      "body": body,
      "date": date,
    };
  }
}
