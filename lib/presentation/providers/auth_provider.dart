import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/constants/app_constants.dart';

enum AuthState { initial, unauthenticated, authenticated, pinSetup }

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthState _authState = AuthState.initial;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String _errorMessage = '';

  AuthState get authState => _authState;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    await _checkBiometricAvailability();
    final hasPin = await _storage.containsKey(key: AppConstants.pinKey);
    if (!hasPin) {
      _authState = AuthState.pinSetup;
    } else {
      _authState = AuthState.unauthenticated;
      final biometric = await _storage.read(key: AppConstants.biometricKey);
      _biometricEnabled = biometric == 'true';
    }
    notifyListeners();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      _biometricAvailable = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      _biometricAvailable = false;
    }
  }

  Future<bool> createPin(String pin) async {
    if (pin.length != 4) return false;
    await _storage.write(key: AppConstants.pinKey, value: pin);
    _authState = AuthState.authenticated;
    _errorMessage = '';
    notifyListeners();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: AppConstants.pinKey);
    if (pin == stored) {
      _authState = AuthState.authenticated;
      _errorMessage = '';
      notifyListeners();
      return true;
    }
    _errorMessage = 'Incorrect PIN. Please try again.';
    notifyListeners();
    return false;
  }

  Future<bool> changePin(String currentPin, String newPin) async {
    final stored = await _storage.read(key: AppConstants.pinKey);
    if (currentPin != stored) {
      _errorMessage = 'Current PIN is incorrect.';
      notifyListeners();
      return false;
    }
    await _storage.write(key: AppConstants.pinKey, value: newPin);
    _errorMessage = '';
    notifyListeners();
    return true;
  }

  Future<bool> authenticateWithBiometric() async {
    if (!_biometricAvailable) return false;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Finance Pro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (authenticated) {
        _authState = AuthState.authenticated;
        _errorMessage = '';
        notifyListeners();
      }
      return authenticated;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    _biometricEnabled = enabled;
    await _storage.write(
      key: AppConstants.biometricKey,
      value: enabled.toString(),
    );
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void lock() {
    _authState = AuthState.unauthenticated;
    notifyListeners();
  }
}
