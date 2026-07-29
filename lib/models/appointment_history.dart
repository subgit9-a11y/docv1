class AppointmentHistory {
  bool? success;
  Data? data;

  AppointmentHistory({this.success, this.data});

  AppointmentHistory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<UpcomingAppointment>? upcomingAppointment;
  List<PastAppointment>? pastAppointment;

  Data({this.upcomingAppointment, this.pastAppointment});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['upcoming_appointment'] != null) {
      upcomingAppointment = <UpcomingAppointment>[];
      json['upcoming_appointment'].forEach((v) {
        upcomingAppointment!.add(UpcomingAppointment.fromJson(v));
      });
    }
    if (json['past_appointment'] != null) {
      pastAppointment = <PastAppointment>[];
      json['past_appointment'].forEach((v) {
        pastAppointment!.add(PastAppointment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (upcomingAppointment != null) {
      data['upcoming_appointment'] =
          upcomingAppointment!.map((v) => v.toJson()).toList();
    }
    if (pastAppointment != null) {
      data['past_appointment'] =
          pastAppointment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpcomingAppointment {
  int? id;
  String? date;
  String? time;
  int? userId;
  int? hospitalId;
  String? patientAddress;
  String? patientName;
  String? appointmentStatus;
  String? treatment;
  String? doctorName;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  UpcomingAppointment(
      {this.id,
      this.date,
      this.time,
      this.userId,
      this.hospitalId,
      this.patientAddress,
      this.patientName,
      this.appointmentStatus,
      this.treatment,
      this.doctorName,
      this.rate,
      this.review,
      this.user,
      this.hospital});

  UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    userId = json['user_id'];
    hospitalId = json['hospital_id'];
    patientAddress = json['patient_address'];
    patientName = json['patient_name'];
    appointmentStatus = json['appointment_status'];
    treatment = json['treatment'];
    doctorName = json['doctor_name'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null
        ? Hospital.fromJson(json['hospital'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['time'] = time;
    data['user_id'] = userId;
    data['hospital_id'] = hospitalId;
    data['patient_address'] = patientAddress;
    data['patient_name'] = patientName;
    data['appointment_status'] = appointmentStatus;
    data['treatment'] = treatment;
    data['doctor_name'] = doctorName;
    data['rate'] = rate;
    data['review'] = review;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (hospital != null) {
      data['hospital'] = hospital!.toJson();
    }
    return data;
  }
}

class PastAppointment {
  int? id;
  String? date;
  String? time;
  int? userId;
  int? hospitalId;
  String? patientAddress;
  String? patientName;
  String? appointmentStatus;
  String? treatment;
  String? doctorName;
  int? rate;
  int? review;
  User? user;
  Hospital? hospital;

  PastAppointment(
      {this.id,
      this.date,
      this.time,
      this.userId,
      this.hospitalId,
      this.patientAddress,
      this.patientName,
      this.appointmentStatus,
      this.treatment,
      this.doctorName,
      this.rate,
      this.review,
      this.user,
      this.hospital});

  PastAppointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    time = json['time'];
    userId = json['user_id'];
    hospitalId = json['hospital_id'];
    patientAddress = json['patient_address'];
    patientName = json['patient_name'];
    appointmentStatus = json['appointment_status'];
    treatment = json['treatment'];
    doctorName = json['doctor_name'];
    rate = json['rate'];
    review = json['review'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    hospital = json['hospital'] != null
        ? Hospital.fromJson(json['hospital'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['time'] = time;
    data['user_id'] = userId;
    data['hospital_id'] = hospitalId;
    data['patient_address'] = patientAddress;
    data['patient_name'] = patientName;
    data['appointment_status'] = appointmentStatus;
    data['treatment'] = treatment;
    data['doctor_name'] = doctorName;
    data['rate'] = rate;
    data['review'] = review;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (hospital != null) {
      data['hospital'] = hospital!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? image;
  String? fullImage;

  User({this.id, this.image, this.fullImage});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    fullImage = json['fullImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['fullImage'] = fullImage;
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
