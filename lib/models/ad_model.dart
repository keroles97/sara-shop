class AdModel {
  String? clickedLink;
  String? publicLink;

  AdModel({this.clickedLink, this.publicLink});

  AdModel.fromJson(Map<String, dynamic> json) {
    clickedLink = json["clickedLink"];
    publicLink = json["publicLink"];
  }
}
