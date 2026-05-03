import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final _apiService = ApiService();
  final _storageService = StorageService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _token = await _storageService.getToken();
    _user = await _storageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(login, password);
      
      _token = response['token'] as String;
      _user = User.fromJson(response['user'] as Map<String, dynamic>);

      await _storageService.saveToken(_token!);
      await _storageService.saveUser(_user!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _error = null;
    await _storageService.clearAll();
    notifyListeners();
  }
}
