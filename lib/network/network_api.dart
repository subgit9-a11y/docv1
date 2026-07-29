import 'package:dio/dio.dart';
import 'package:doctro/models/AllMedicines.dart';
import 'package:doctro/models/CancelAppointment.dart';
import 'package:doctro/models/ChangePassword.dart';
import 'package:doctro/models/DoctorStatusChange.dart';
import 'package:doctro/models/FinanceDetails.dart';
import 'package:doctro/models/ForgotPassword.dart';
import 'package:doctro/models/Notification.dart';
import 'package:doctro/models/ResentOtp.dart';
import 'package:doctro/models/Treatment.dart';
import 'package:doctro/models/UpdateProfile.dart';
import 'package:doctro/models/UpdateTiming.dart';
import 'package:doctro/models/add_prescription.dart';
import 'package:doctro/models/appointment_details.dart';
import 'package:doctro/models/appointment_history.dart';
import 'package:doctro/models/categories.dart';
import 'package:doctro/models/doctor_profile.dart';
import 'package:doctro/models/expertise.dart';
import 'package:doctro/models/hospital.dart';
import 'package:doctro/models/login.dart';
import 'package:doctro/models/otp_verify.dart';
import 'package:doctro/models/payment.dart';
import 'package:doctro/models/register.dart';
import 'package:doctro/models/review.dart';
import 'package:doctro/models/setting.dart';
import 'package:doctro/models/today_appointment.dart';
import 'package:doctro/models/update_profile_image.dart';
import 'package:doctro/models/video_call_history_add_model.dart';
import 'package:doctro/models/video_call_history_show_model.dart';
import 'package:doctro/models/working_hours.dart';
import 'package:doctro/network/apis.dart';
import 'package:doctro/features/consultation/videoCall/model/doctorAgoraTokenGenerateModel.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'network_api.g.dart';

@RestApi(baseUrl: Apis.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @POST(Apis.login)
  Future<LoginResponse> loginRequest(@Body() body);

  @POST(Apis.register)
  Future<Register> registerRequest(@Body() body);

  @GET(Apis.appointment)
  Future<TodayAppointment> todayAppointments();

  @GET(Apis.appointment_details)
  Future<AppointmentDetails> appointmentDetails(@Path() int? id);

  @GET(Apis.appointment_history)
  Future<AppointmentHistory> appointmentHistoryScreenRequest();

  @GET(Apis.working_hours)
  Future<Workinghours> workinghours();

  @GET(Apis.hospitals)
  Future<Hospitals> hospitalRequest();

  @GET(Apis.doctor_profile)
  Future<DoctorProfile> doctorProfile();

  @GET(Apis.review)
  Future<Review> reviewRequest();

  @GET(Apis.payment)
  Future<Payment> paymentRequest();

  @POST(Apis.check_otp)
  Future<OtpVerify> otpVerifyRequest(@Body() body);

  @POST(Apis.update_doctor)
  Future<UpdateProfile> updateProfile(@Body() body);

  @GET(Apis.treatment)
  Future<Treatment> treatmentRequest();

  @GET(Apis.categories)
  Future<Categories> categoryRequest(@Path() int? id);

  @GET(Apis.expertise)
  Future<Expertise> expertiseRequest(@Path() int? id);

  @POST(Apis.addPrescription)
  Future<AddPrescription> addPrescriptionRequest(@Body() body);

  @GET(Apis.setting)
  Future<Setting> settingRequest();

  @POST(Apis.update_image)
  Future<ImageUpload> uploadImage(@Body() body);

  @POST(Apis.status_change)
  Future<DoctorStatusChange> doctorStatusChangeRequest(@Body() body);

  @GET(Apis.cancel_appointment)
  Future<CancelAppointment> cancelAppointmentRequest();

  @GET(Apis.finance_detail)
  Future<FinanceDetails> purchaseDetailsRequest();

  @POST(Apis.update_time)
  Future<UpdateTiming> updateTimingRequest(@Body() body);

  @POST(Apis.change_password)
  Future<ChangePasswordModel> changePasswordRequest(@Body() body);

  @POST(Apis.forgot_password)
  Future<ForgotPassword> forgotPasswordScreen(@Body() body);

  @GET(Apis.notification)
  Future<Notifications> notifications();

  @GET(Apis.all_medicines)
  Future<AllMedicines> allMedicines();

  @GET(Apis.resend_otp)
  Future<ResentOtp> resentOtpRequest(@Path() int? id);

  @POST(Apis.videoCallAddHistory)
  Future<VideoCallHistoryAddModel> videoCallHistoryAddRequest(@Body() body);

  @GET(Apis.videoCallShowHistory)
  Future<VideoCallHistoryShowModel> videoCallHistoryShowRequest();

  @POST(Apis.generateDoctorAgoraToken)
  Future<VideoCallModel> generateDoctorAgoraTokenCall(@Body() body);

  @POST(Apis.updatePatientVcall)
  Future<UpdateProfile> updatePatientVcallRequest(@Body() body);
}
