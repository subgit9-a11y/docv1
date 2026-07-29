class FinanceDetails {
  bool? success;
  List<PurchaseDetails>? data;

  FinanceDetails({this.success, this.data});

  FinanceDetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(PurchaseDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseDetails {
  int? id;
  int? doctorId;
  int? duration;
  String? startDate;
  String? endDate;
  String? paymentType;
  int? amount;
  String? paymentToken;
  int? paymentStatus;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? doctorName;

  PurchaseDetails();

  PurchaseDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    doctorId = json['doctor_id'];
    duration = json['duration'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    paymentType = json['payment_type'];
    amount = json['amount'];
    paymentToken = json['payment_token'];
    paymentStatus = json['payment_status'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    doctorName = json['doctor_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['doctor_id'] = doctorId;
    data['duration'] = duration;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['payment_type'] = paymentType;
    data['amount'] = amount;
    data['payment_token'] = paymentToken;
    data['payment_status'] = paymentStatus;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['doctor_name'] = doctorName;
    return data;
  }
}
