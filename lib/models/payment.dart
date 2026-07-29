class Payment {
  bool? success;
  List<Payments>? paymentData;

  Payment({this.success, this.paymentData});

  Payment.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      paymentData = [];
      json['data'].forEach((v) {
        paymentData!.add(Payments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (paymentData != null) {
      data['data'] = paymentData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Payments {
  int? id;
  int? userId;
  String? amount;
  User? user;

  Payments({this.id, this.userId, this.amount, this.user});

  Payments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'].toString();
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['amount'] = amount;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? fullImage;

  User({this.id, this.name, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['fullImage'] = fullImage;
    return data;
  }
}
