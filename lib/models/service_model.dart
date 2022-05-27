
class ServiceModel {
  String? sellerUid;
  String? id;
  bool? active;
  String? englishTitle;
  String? arabicTitle;
  String? englishDescription;
  String? arabicDescription;
  String? phone;
  String? whatsapp;
  String? email;
  String? price;
  int? ratersCount;
  double? rate;
  List? images;
  String? englishKeyWords;
  String? arabicKeyWords;

  ServiceModel({
    this.sellerUid,
    this.id,
    this.active,
    this.englishTitle,
    this.arabicTitle,
    this.englishDescription,
    this.arabicDescription,
    this.phone,
    this.whatsapp,
    this.email,
    this.price,
    this.ratersCount,
    this.rate,
    this.images,
    this.englishKeyWords,
    this.arabicKeyWords,
  });

  ServiceModel.fromJson(Map<String, dynamic> json) {
    sellerUid = json["sellerUid"];
    id = json["id"];
    active = json["active"];
    englishTitle = json["englishTitle"];
    arabicTitle = json["arabicTitle"];
    englishDescription = json["englishDescription"];
    arabicDescription = json["arabicDescription"];
    phone = json["phone"];
    whatsapp = json["whatsapp"];
    email = json["email"];
    price = json["price"];
    ratersCount = json["ratersCount"];
    rate = json["rate"]+0.0;
    images = (json["images"]);
    englishKeyWords = json["englishKeyWords"];
    arabicKeyWords = json["arabicKeyWords"];
  }
  
  Map<String, dynamic> toMap() {
    return {
      "sellerUid": sellerUid,
      "id": id,
      "active": active,
      "englishTitle": englishTitle,
      "arabicTitle": arabicTitle,
      "englishDescription": englishDescription,
      "arabicDescription": arabicDescription,
      "phone": phone,
      "whatsapp": whatsapp,
      "email": email,
      "price": price,
      "ratersCount": ratersCount,
      "rate": rate,
      "images": images,
      "englishKeyWords": englishKeyWords,
      "arabicKeyWords": arabicKeyWords,
    };
  }
}
