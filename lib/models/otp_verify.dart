class OtpVerify {
  bool? success;
  OtpData? data;
  String? msg;

  OtpVerify({this.success, this.data, this.msg});

  OtpVerify.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? OtpData.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class OtpData {
  int? id;
  String? name;
  String? email;
  String? emailVerifiedAt;
  String? phone;
  String? phoneCode;
  int? verify;
  int? otp;
  String? dob;
  String? gender;
  String? image;
  int? status;
  dynamic doctorId;
  String? deviceToken;
  String? createdAt;
  String? updatedAt;
  String? token;
  String? fullImage;
  int? isFilled;

  OtpData({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phone,
    this.phoneCode,
    this.verify,
    this.otp,
    this.dob,
    this.gender,
    this.image,
    this.status,
    this.doctorId,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.fullImage,
    this.isFilled,
  });

  OtpData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    verify = json['verify'];
    otp = json['otp'];
    dob = json['dob'];
    gender = json['gender'];
    image = json['image'];
    status = json['status'];
    doctorId = json['doctor_id'];
    deviceToken = json['device_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    token = json['token'];
    fullImage = json['fullImage'];
    isFilled = json['is_filled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['verify'] = verify;
    data['otp'] = otp;
    data['dob'] = dob;
    data['gender'] = gender;
    data['image'] = image;
    data['status'] = status;
    data['doctor_id'] = doctorId;
    data['device_token'] = deviceToken;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['token'] = token;
    data['fullImage'] = fullImage;
    data['is_filled'] = isFilled;
    return data;
  }
}
