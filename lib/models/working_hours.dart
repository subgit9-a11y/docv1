class Workinghours {
  bool? success;
  List<Data>? data;
  String? msg;

  Workinghours({this.success, this.data, this.msg});

  Workinghours.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  int? id;
  int? doctorId;
  String? dayIndex;
  String? periodList;
  int? status;

  Data({this.id, this.doctorId, this.dayIndex, this.periodList, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    dayIndex = json['day_index'];
    periodList = json['period_list'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['day_index'] = dayIndex;
    data['period_list'] = periodList;
    data['status'] = status;
    return data;
  }
}
