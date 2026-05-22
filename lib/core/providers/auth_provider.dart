import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final Box<UserModel> _usersBox = Hive.box<UserModel>('users');
  final Box<String> _authSessionBox = Hive.box<String>('auth_session');
  
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadSession();
  }

  void _loadSession() {
    final currentUserId = _authSessionBox.get('current_user_id');
    if (currentUserId != null) {
      _currentUser = _usersBox.get(currentUserId);
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<String?> signUp({
    required String email,
    required String name,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    
    // Check if user already exists
    final emailExists = _usersBox.values.any((u) => u.email == normalizedEmail);
    if (emailExists) {
      return 'An account with this email already exists.';
    }

    final userId = const Uuid().v4();
    final user = UserModel(
      id: userId,
      email: normalizedEmail,
      name: name.trim(),
      passwordHash: _hashPassword(password),
    );

    await _usersBox.put(userId, user);
    
    // Automatically sign in
    await _setSession(user);
    return null; // Success
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final hash = _hashPassword(password);

    try {
      final user = _usersBox.values.firstWhere(
        (u) => u.email == normalizedEmail && u.passwordHash == hash,
      );
      
      await _setSession(user);
      return null; // Success
    } catch (_) {
      return 'Invalid email or password.';
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _authSessionBox.delete('current_user_id');
    notifyListeners();
  }

  Future<void> _setSession(UserModel user) async {
    _currentUser = user;
    await _authSessionBox.put('current_user_id', user.id);
    notifyListeners();
  }

  Future<void> updateProfileImage(String? path) async {
    if (_currentUser == null) return;
    
    final updatedUser = _currentUser!.copyWith(profileImagePath: path);
    await _usersBox.put(_currentUser!.id, updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}
