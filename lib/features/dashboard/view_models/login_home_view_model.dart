import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/models/today_appointment.dart';
import 'package:doctro/models/payment.dart';
import 'package:doctro/models/review.dart';
import 'package:doctro/network/api_header.dart';
import 'package:doctro/network/network_api.dart';

class LoginHomeViewModel extends ChangeNotifier {
  bool isLoading = false;

  String? dName;
  String? dFullImage;
  int? isFilled;
  int? subscription;
  String? phone;

  List<Today> todayAppointments = [];
  List<Tomorrow> tomorrowAppointments = [];
  List<Upcoming> upcomingAppointments = [];

  List<Today> searchResult = [];
  List<Tomorrow> tomorrowSearchResult = [];
  List<Upcoming> upcomingSearchResult = [];

  double totalEarnings = 0;
  int reviewCount = 0;
  int patientCount = 0;

  void initializeData(BuildContext context) {
    Future.delayed(Duration.zero, () {
      final isLoggedIn =
          SharedPreferenceHelper.getBoolean(Preferences.is_logged_in);

      if (isLoggedIn) {
        settingRequest(context);
        fetchAppointments(context);
      }

      dName = SharedPreferenceHelper.getString(Preferences.name);
      dFullImage = SharedPreferenceHelper.getString(Preferences.image);
      isFilled = SharedPreferenceHelper.getInt(Preferences.is_filled);
      subscription =
          SharedPreferenceHelper.getInt(Preferences.subscription_status);
      phone = SharedPreferenceHelper.getString(Preferences.phone_no);
      notifyListeners();
    });
  }

  Future<void> fetchAppointments(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      todayAppointments.clear();
      tomorrowAppointments.clear();
      upcomingAppointments.clear();
      totalEarnings = 0;

      final client = RestClient(await RetroApi().dioData(context));

      final futures = await Future.wait([
        client.todayAppointments(),
        client
            .paymentRequest()
            .catchError((_) => Payment(success: false, paymentData: [])),
        client
            .reviewRequest()
            .catchError((_) => Review(success: false, data: [])),
      ]);

      final response = futures[0] as TodayAppointment;
      final payments = futures[1] as Payment;
      final reviews = futures[2] as Review;

      if (payments.paymentData != null) {
        for (var p in payments.paymentData!) {
          totalEarnings += double.tryParse(p.amount.toString()) ?? 0;
        }
      }

      if (reviews.data != null) {
        reviewCount = reviews.data!.length;
      }

      if (response.data?.today != null && response.data!.today!.isNotEmpty) {
        response.data!.today!.sort((a, b) => DateFormat("yyyy-MM-dd h:mm a")
            .parse(
                "${DateTime.now().toString().split(" ")[0]} ${(a.time ?? "00:00 AM").toUpperCase()}")
            .compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(
                "${DateTime.now().toString().split(" ")[0]} ${(b.time ?? "00:00 AM").toUpperCase()}")));
        todayAppointments.addAll(response.data!.today!);
      }

      if (response.data?.tomorrow != null &&
          response.data!.tomorrow!.isNotEmpty) {
        response.data!.tomorrow!.sort((a, b) => DateFormat("yyyy-MM-dd h:mm a")
            .parse(
                "${DateTime.now().toString().split(" ")[0]} ${(a.time ?? "00:00 AM").toUpperCase()}")
            .compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(
                "${DateTime.now().toString().split(" ")[0]} ${(b.time ?? "00:00 AM").toUpperCase()}")));
        tomorrowAppointments.addAll(response.data!.tomorrow!);
      }

      if (response.data?.upcoming != null &&
          response.data!.upcoming!.isNotEmpty) {
        response.data!.upcoming!.sort((a, b) => DateFormat("yyyy-MM-dd h:mm a")
            .parse(
                "${DateTime.now().toString().split(" ")[0]} ${(a.time ?? "00:00 AM").toUpperCase()}")
            .compareTo(DateFormat("yyyy-MM-dd h:mm a").parse(
                "${DateTime.now().toString().split(" ")[0]} ${(b.time ?? "00:00 AM").toUpperCase()}")));
        upcomingAppointments.addAll(response.data!.upcoming!);
      }

      Set<String> uniquePatients = {};
      for (var a in todayAppointments) {
        if (a.patientName != null) uniquePatients.add(a.patientName!);
      }
      for (var a in tomorrowAppointments) {
        if (a.patientName != null) uniquePatients.add(a.patientName!);
      }
      for (var a in upcomingAppointments) {
        if (a.patientName != null) uniquePatients.add(a.patientName!);
      }
      patientCount = uniquePatients.length;
    } catch (error) {
      // error handling
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> settingRequest(BuildContext context) async {
    try {
      final response =
          await RestClient(await RetroApi().dioData(context)).settingRequest();
      if (response.data?.agoraAppId != null) {
        SharedPreferenceHelper.setString(
            Preferences.agoraAppId, response.data!.agoraAppId!);
      }
      if (SharedPreferenceHelper.getBoolean(Preferences.is_logged_in) == true) {
        if (response.data!.stripeSecretKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.stripeSecretKey, response.data!.stripeSecretKey!);
        }
        if (response.data!.stripePublicKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.stripPublicKey, response.data!.stripePublicKey!);
        }
        if (response.data!.flutterwaveEncryptionKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.flutterWave_encryption_key,
              response.data!.flutterwaveEncryptionKey!);
        }
        if (response.data!.flutterwaveKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.flutterWave_key, response.data!.flutterwaveKey!);
        }
        if (response.data!.paystackPublicKey != null) {
          SharedPreferenceHelper.setString(Preferences.payStack_public_key,
              response.data!.paystackPublicKey!);
        }
        if (response.data!.razorKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.razor_key, response.data!.razorKey!);
        }
        if (response.data!.paypalProducationKey != null) {
          SharedPreferenceHelper.setString(Preferences.payPal_production_key,
              response.data!.paypalProducationKey!);
        }
        if (response.data!.paypalSandboxKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.payPal_sandbox_key, response.data!.paypalSandboxKey!);
        }
        if (response.data!.paypalClientId != null) {
          SharedPreferenceHelper.setString(
              Preferences.paypal_client_key, response.data!.paypalClientId!);
        }
        if (response.data!.paypalSecretKey != null) {
          SharedPreferenceHelper.setString(
              Preferences.paypal_secret_key, response.data!.paypalSecretKey!);
        }
        if (response.data!.currencySymbol != null) {
          SharedPreferenceHelper.setString(
              Preferences.currency_symbol, response.data!.currencySymbol!);
        }
        if (response.data!.currencyCode != null) {
          SharedPreferenceHelper.setString(
              Preferences.currency_code, response.data!.currencyCode!);
        }
        if (response.data!.doctorAppId != null) {
          SharedPreferenceHelper.setString(
              Preferences.doctorAppId, response.data!.doctorAppId!);
        }
      }
    } catch (error) {
      // error handling
    }
  }

  void onSearchTextChanged(String text) {
    searchResult.clear();
    tomorrowSearchResult.clear();
    upcomingSearchResult.clear();
    if (text.isEmpty) {
      notifyListeners();
      return;
    }

    for (var appointmentData in todayAppointments) {
      if ((appointmentData.patientName ?? "")
          .toLowerCase()
          .contains(text.toLowerCase())) {
        searchResult.add(appointmentData);
      }
    }

    for (var tomorrowData in tomorrowAppointments) {
      if ((tomorrowData.patientName ?? "")
          .toLowerCase()
          .contains(text.toLowerCase())) {
        tomorrowSearchResult.add(tomorrowData);
      }
    }

    for (var upcomingData in upcomingAppointments) {
      if ((upcomingData.patientName ?? "")
          .toLowerCase()
          .contains(text.toLowerCase())) {
        upcomingSearchResult.add(upcomingData);
      }
    }

    notifyListeners();
  }
}
