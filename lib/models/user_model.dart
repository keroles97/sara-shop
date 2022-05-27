class UserModel {
  String? name;
  String? email;
  String? uId;
  String? token;
  bool active = false;
  double rate = 0.0;
  int ratersCount = 0;

  UserModel({
    this.name,
    this.email,
    this.uId,
    this.token,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    email = json["email"];
    uId = json["uId"];
    token = json["token"];
    active = json["active"];
    rate = json["rate"];
    ratersCount = json["ratersCount"];
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "uId": uId,
      "token": token,
      "active": active,
      "rate": rate,
      "ratersCount": ratersCount,
    };
  }
}
