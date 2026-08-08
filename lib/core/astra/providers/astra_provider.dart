import 'package:flutter/material.dart';
import 'package:doctro/core/astra/controllers/astra_controller.dart';

/// Astra Provider
///
/// A ChangeNotifierProvider wrapper for AstraController.
/// Use this to easily integrate Astra AI into the existing Provider architecture.
class AstraProvider extends ChangeNotifier {
  final AstraController _controller;

  AstraProvider({String? patientId, String? patientName, String? appointmentId})
      : _controller = AstraController() {
    _initialize(patientId: patientId, patientName: patientName, appointmentId: appointmentId);
  }

  AstraController get controller => _controller;

  // Proxy getters for convenience
  bool get isInitialized => _controller.isInitialized;
  bool get isLoading => _controller.isLoading;
  bool get isStreaming => _controller.isStreaming;
  bool get isBrainHealthy => _controller.isBrainHealthy;
  String? get errorMessage => _controller.errorMessage;

  Future<void> _initialize({
    String? patientId,
    String? patientName,
    String? appointmentId,
  }) async {
    await _controller.initialize(
      patientId: patientId,
      patientName: patientName,
      appointmentId: appointmentId,
    );
    notifyListeners();
  }

  /// Set patient context
  void setPatientContext({
    required String patientId,
    String? patientName,
    String? appointmentId,
  }) {
    _controller.setPatientContext(
      patientId: patientId,
      patientName: patientName,
      appointmentId: appointmentId,
    );
    notifyListeners();
  }

  /// Clear patient context
  void clearPatientContext() {
    _controller.clearPatientContext();
    notifyListeners();
  }

  /// Send a message
  Future<void> sendMessage(String text) async {
    await _controller.sendMessage(text);
    notifyListeners();
  }

  /// Send a streaming message
  Future<void> sendMessageStreaming(String text) async {
    await _controller.sendMessageStreaming(text);
    notifyListeners();
  }

  /// Cancel ongoing stream
  void cancelStream() {
    _controller.cancelStream();
    notifyListeners();
  }

  /// Refresh brain health
  Future<void> refreshBrainHealth() async {
    await _controller.refreshBrainHealth();
    notifyListeners();
  }

  /// Clear conversation
  Future<void> clearConversation() async {
    await _controller.clearConversation();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Provider creation helper
ChangeNotifierProvider<AstraProvider> createAstraProvider({
  String? patientId,
  String? patientName,
  String? appointmentId,
}) {
  return ChangeNotifierProvider(
    create: (_) => AstraProvider(
      patientId: patientId,
      patientName: patientName,
      appointmentId: appointmentId,
    ),
  );
}
