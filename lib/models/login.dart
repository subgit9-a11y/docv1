class LoginResponse {
  bool? success;
  Data? data;
  String? msg;
  String? token;
  String? refreshToken;
  String? expiresIn;

  LoginResponse(
      {this.success,
      this.data,
      this.msg,
      this.token,
      this.refreshToken,
      this.expiresIn});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
    token = json['token'];
    refreshToken = json['refresh_token'];
    expiresIn = json['expires_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (token != null) {
      data['token'] = token;
    }
    if (refreshToken != null) {
      data['refresh_token'] = refreshToken;
    }
    if (expiresIn != null) {
      data['expires_in'] = expiresIn;
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  dynamic id;
  String? name;
  String? email;
  String? phone;
  String? phoneCode;
  int? verify;
  int? otp;
  String? image;
  String? deviceToken;
  String? language;
  String? createdAt;
  String? updatedAt;
  int? isFilled;
  String? token;
  String? fullImage;
  List<Roles>? roles;

  Data(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.phoneCode,
      this.verify,
      this.otp,
      this.image,
      this.deviceToken,
      this.language,
      this.createdAt,
      this.updatedAt,
      this.isFilled,
      this.token,
      this.fullImage,
      this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    phoneCode = json['phone_code'];
    verify = json['verify'];
    otp = json['otp'];
    image = json['image'];
    deviceToken = json['device_token'];
    language = json['language'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isFilled = json['is_filled'];
    token = json['token'];
    fullImage = json['fullImage'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles!.add(Roles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['phone_code'] = phoneCode;
    data['verify'] = verify;
    data['otp'] = otp;
    data['image'] = image;
    data['device_token'] = deviceToken;
    data['language'] = language;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_filled'] = isFilled;
    data['token'] = token;
    data['fullImage'] = fullImage;
    if (roles != null) {
      data['roles'] = roles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Roles {
  int? id;
  String? name;
  String? guardName;
  String? createdAt;
  String? updatedAt;
  Pivot? pivot;

  Roles(
      {this.id,
      this.name,
      this.guardName,
      this.createdAt,
      this.updatedAt,
      this.pivot});

  Roles.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    guardName = json['guard_name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['guard_name'] = guardName;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? modelId;
  int? roleId;
  String? modelType;

  Pivot({this.modelId, this.roleId, this.modelType});

  Pivot.fromJson(Map<String, dynamic> json) {
    modelId = json['model_id'];
    roleId = json['role_id'];
    modelType = json['model_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['model_id'] = modelId;
    data['role_id'] = roleId;
    data['model_type'] = modelType;
    return data;
  }
}
