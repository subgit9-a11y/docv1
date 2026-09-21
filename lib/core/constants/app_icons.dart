import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Centralized icon set for the app, backed by Hugeicons' stroke-rounded
/// family instead of Material's built-in glyphs, for a more distinctive
/// look. Every getter returns the `List<List<dynamic>>` shape `HugeIcon`
/// expects; render with `HugeIcon(icon: AppIcons.x, color: ..., size: ...)`
/// rather than the Material `Icon(...)` widget.
class AppIcons {
  static const Color iconPrimary = Color(0xFF24382C);
  static const Color iconSecondary = Color(0xFF607063);
  static const Color iconAccent = Color(0xFF2E7D32);

  static List<List<dynamic>> get home => HugeIcons.strokeRoundedHome01;
  static List<List<dynamic>> get homeFilled => HugeIcons.strokeRoundedHome01;

  static List<List<dynamic>> get calendar => HugeIcons.strokeRoundedCalendar03;
  static List<List<dynamic>> get calendarFilled =>
      HugeIcons.strokeRoundedCalendar03;

  static List<List<dynamic>> get chat => HugeIcons.strokeRoundedMessage01;
  static List<List<dynamic>> get chatFilled => HugeIcons.strokeRoundedMessage01;

  static List<List<dynamic>> get profile => HugeIcons.strokeRoundedUserCircle;
  static List<List<dynamic>> get profileFilled =>
      HugeIcons.strokeRoundedUserCircle;

  static List<List<dynamic>> get settings => HugeIcons.strokeRoundedSettings01;
  static List<List<dynamic>> get settingsFilled =>
      HugeIcons.strokeRoundedSettings01;

  static List<List<dynamic>> get notifications =>
      HugeIcons.strokeRoundedNotification01;
  static List<List<dynamic>> get notificationsFilled =>
      HugeIcons.strokeRoundedNotification01;

  static List<List<dynamic>> get search => HugeIcons.strokeRoundedSearch01;

  static List<List<dynamic>> get menu => HugeIcons.strokeRoundedMenu01;

  static List<List<dynamic>> get back => HugeIcons.strokeRoundedArrowLeft01;

  static List<List<dynamic>> get forward => HugeIcons.strokeRoundedArrowRight01;

  static List<List<dynamic>> get add => HugeIcons.strokeRoundedAddCircle;
  static List<List<dynamic>> get addFilled => HugeIcons.strokeRoundedAddCircle;

  static List<List<dynamic>> get edit => HugeIcons.strokeRoundedEdit01;

  static List<List<dynamic>> get delete => HugeIcons.strokeRoundedDelete01;

  static List<List<dynamic>> get call => HugeIcons.strokeRoundedCall02;
  static List<List<dynamic>> get callEnd => HugeIcons.strokeRoundedCallEnd01;

  static List<List<dynamic>> get mic => HugeIcons.strokeRoundedMic01;

  static List<List<dynamic>> get micOff => HugeIcons.strokeRoundedMicOff01;

  static List<List<dynamic>> get videoCall => HugeIcons.strokeRoundedVideo01;
  static List<List<dynamic>> get videoCallOff =>
      HugeIcons.strokeRoundedVideoOff;

  static List<List<dynamic>> get camera => HugeIcons.strokeRoundedCamera01;

  static List<List<dynamic>> get cameraFlip =>
      HugeIcons.strokeRoundedCameraRotated01;

  static List<List<dynamic>> get photo => HugeIcons.strokeRoundedImage01;

  static List<List<dynamic>> get medical => HugeIcons.strokeRoundedStethoscope;

  static List<List<dynamic>> get prescription =>
      HugeIcons.strokeRoundedPrescription;

  static List<List<dynamic>> get patient => HugeIcons.strokeRoundedUserGroup;

  static List<List<dynamic>> get appointment =>
      HugeIcons.strokeRoundedCalendarCheck01;

  static List<List<dynamic>> get payment => HugeIcons.strokeRoundedCreditCard;

  static List<List<dynamic>> get subscription => HugeIcons.strokeRoundedIdCard;

  static List<List<dynamic>> get language => HugeIcons.strokeRoundedTranslate;

  static List<List<dynamic>> get password =>
      HugeIcons.strokeRoundedSquareLockPassword;

  static List<List<dynamic>> get logout => HugeIcons.strokeRoundedLogout01;

  static List<List<dynamic>> get check =>
      HugeIcons.strokeRoundedCheckmarkCircle01;

  static List<List<dynamic>> get warning => HugeIcons.strokeRoundedAlert01;

  static List<List<dynamic>> get error => HugeIcons.strokeRoundedAlertCircle;

  static List<List<dynamic>> get info =>
      HugeIcons.strokeRoundedInformationCircle;

  static List<List<dynamic>> get time => HugeIcons.strokeRoundedTime01;

  static List<List<dynamic>> get date => HugeIcons.strokeRoundedCalendar01;

  static List<List<dynamic>> get send => HugeIcons.strokeRoundedSent;

  static List<List<dynamic>> get attach => HugeIcons.strokeRoundedAttachment01;

  static List<List<dynamic>> get document => HugeIcons.strokeRoundedFile01;

  static List<List<dynamic>> get folder => HugeIcons.strokeRoundedFolder01;

  static List<List<dynamic>> get star => HugeIcons.strokeRoundedStar;
  static List<List<dynamic>> get starFilled => HugeIcons.strokeRoundedStar;

  static List<List<dynamic>> get filter => HugeIcons.strokeRoundedFilter;

  static List<List<dynamic>> get more => HugeIcons.strokeRoundedMoreVertical;

  static List<List<dynamic>> get close => HugeIcons.strokeRoundedCancel01;

  static List<List<dynamic>> get visibility => HugeIcons.strokeRoundedView;
  static List<List<dynamic>> get visibilityOff =>
      HugeIcons.strokeRoundedViewOff;

  static List<List<dynamic>> get email => HugeIcons.strokeRoundedMailAtSign01;

  static List<List<dynamic>> get phone => HugeIcons.strokeRoundedCall02;

  static List<List<dynamic>> get location => HugeIcons.strokeRoundedLocation01;

  static List<List<dynamic>> get doctor => HugeIcons.strokeRoundedStethoscope02;

  static List<List<dynamic>> get hospital => HugeIcons.strokeRoundedHospital01;

  static List<List<dynamic>> get wallet => HugeIcons.strokeRoundedWallet01;

  static List<List<dynamic>> get share => HugeIcons.strokeRoundedShare01;

  static List<List<dynamic>> get download => HugeIcons.strokeRoundedDownload01;

  static List<List<dynamic>> get upload => HugeIcons.strokeRoundedUpload01;

  static List<List<dynamic>> get image => HugeIcons.strokeRoundedImage02;

  static List<List<dynamic>> get help => HugeIcons.strokeRoundedHelpCircle;

  static List<List<dynamic>> get privacy => HugeIcons.strokeRoundedShieldCheck;

  static List<List<dynamic>> get terms => HugeIcons.strokeRoundedAgreement01;

  static List<List<dynamic>> get about =>
      HugeIcons.strokeRoundedInformationCircle;

  static List<List<dynamic>> get shield => HugeIcons.strokeRoundedShield01;

  static List<List<dynamic>> get verified =>
      HugeIcons.strokeRoundedCheckmarkBadge01;

  static List<List<dynamic>> get clock => HugeIcons.strokeRoundedClock01;

  static List<List<dynamic>> get mail => HugeIcons.strokeRoundedMailAtSign02;

  static List<List<dynamic>> get sms => HugeIcons.strokeRoundedMessage02;

  static List<List<dynamic>> get wifi => HugeIcons.strokeRoundedWifi01;

  static List<List<dynamic>> get refresh => HugeIcons.strokeRoundedReload;

  static List<List<dynamic>> get list => HugeIcons.strokeRoundedListView;

  static List<List<dynamic>> get grid => HugeIcons.strokeRoundedGridView;

  static List<List<dynamic>> get analytics =>
      HugeIcons.strokeRoundedAnalytics01;

  static List<List<dynamic>> get language2 => HugeIcons.strokeRoundedTranslate;
}
