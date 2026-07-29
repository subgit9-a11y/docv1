class DoctorProfile {
  bool? success;
  Data? data;
  String? msg;

  DoctorProfile({this.success, this.data, this.msg});

  DoctorProfile.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? id;
  int? treatmentId;
  int? categoryId;
  int? expertiseId;
  String? hospitalId;
  int? userId;
  String? image;
  String? desc;
  String? education;
  String? certificate;
  String? appointmentFees;
  String? videoAppointmentFees;
  String? experience;
  String? timeslot;
  String? name;
  String? dob;
  String? gender;
  String? startTime;
  String? endTime;
  String? since;
  int? status;
  String? basedOn;
  int? isPopular;
  String? commissionAmount;
  int? customTimeslot;
  int? isFilled;
  int? patientVCall;

  String? language;
  String? createdAt;
  String? updatedAt;
  String? email;
  String? phone;
  String? agoraToken;
  String? channelName;
  String? fullImage;
  Hospital? hospital;

  Data(
      {this.id,
      this.treatmentId,
      this.categoryId,
      this.expertiseId,
      this.hospitalId,
      this.userId,
      this.image,
      this.desc,
      this.education,
      this.certificate,
      this.appointmentFees,
      this.videoAppointmentFees,
      this.experience,
      this.timeslot,
      this.name,
      this.dob,
      this.gender,
      this.startTime,
      this.endTime,
      this.since,
      this.status,
      this.basedOn,
      this.isPopular,
      this.commissionAmount,
      this.customTimeslot,
      this.isFilled,
      this.patientVCall,
      this.language,
      this.createdAt,
      this.updatedAt,
      this.email,
      this.phone,
      this.agoraToken,
      this.channelName,
      this.fullImage,
      this.hospital});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    treatmentId = json['treatment_id'];
    categoryId = json['category_id'];
    expertiseId = json['expertise_id'];
    hospitalId = json['hospital_id'];
    userId = json['user_id'];
    image = json['image'];
    desc = json['desc'];
    education = json['education'];
    certificate = json['certificate'];
    appointmentFees = json['appointment_fees'];
    videoAppointmentFees = json['video_appointment_fees'];
    experience = json['experience'];
    timeslot = json['timeslot'];
    name = json['name'];
    dob = json['dob'];
    gender = json['gender'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    since = json['since'];
    status = json['status'];
    basedOn = json['based_on'];
    isPopular = json['is_popular'];
    commissionAmount = json['commission_amount'];
    customTimeslot = json['custom_timeslot'];
    isFilled = json['is_filled'];
    patientVCall = json['patient_vcall'];
    language = json['language'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    email = json['email'];
    phone = json['phone'];
    agoraToken = json['agora_token'];
    channelName = json['channel_name'];
    fullImage = json['fullImage'];
    hospital = json['hospital'] != null
        ? Hospital.fromJson(json['hospital'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['treatment_id'] = treatmentId;
    data['category_id'] = categoryId;
    data['expertise_id'] = expertiseId;
    data['hospital_id'] = hospitalId;
    data['user_id'] = userId;
    data['image'] = image;
    data['desc'] = desc;
    data['education'] = education;
    data['certificate'] = certificate;
    data['appointment_fees'] = appointmentFees;
    data['video_appointment_fees'] = videoAppointmentFees;
    data['experience'] = experience;
    data['timeslot'] = timeslot;
    data['name'] = name;
    data['dob'] = dob;
    data['gender'] = gender;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['since'] = since;
    data['status'] = status;
    data['based_on'] = basedOn;
    data['is_popular'] = isPopular;
    data['commission_amount'] = commissionAmount;
    data['custom_timeslot'] = customTimeslot;
    data['is_filled'] = isFilled;
    data['patient_vcall '] = patientVCall;
    data['language'] = language;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['email'] = email;
    data['phone'] = phone;
    data['agora_token'] = agoraToken;
    data['channel_name'] = channelName;
    data['fullImage'] = fullImage;
    if (hospital != null) {
      data['hospital'] = hospital!.toJson();
    }
    return data;
  }
}

class Hospital {
  int? id;
  String? name;
  String? address;

  Hospital({this.id, this.name, this.address});

  Hospital.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    return data;
  }
}
