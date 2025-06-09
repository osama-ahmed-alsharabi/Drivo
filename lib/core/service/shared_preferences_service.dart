import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const _keyFirstOpen = 'is_first_open';
  static const _userNameKey = 'user_name';
  static SharedPreferences? _prefs;

// Add these to your existing SharedPreferencesService class
  static const _userIdKey = 'user_id';
  static const _phoneNumber = 'user_phone';
  static const _email = 'email';
  static const _userType = 'userType';

  static const _offers = 'offers';

  static const _products = 'products';

  // Add to SharedPreferencesService class
  static const _keyProviderSetupComplete = 'provider_setup_complete';

  static Future<void> setProviderSetupComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyProviderSetupComplete, complete);
  }

  static Future<bool> isProviderSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyProviderSetupComplete) ?? false;
  }

  static Future<void> saveProducts(int product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_products, product);
  }

  static Future<int?> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_products);
  }

  static Future<void> clearProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_products);
  }

  static Future<void> saveOffers(int offers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_offers, offers);
  }

  static Future<int?> getOffers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_offers);
  }

  static Future<void> clearOffers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offers);
  }

  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userType, userType);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userType);
  }

  static Future<void> clearUserType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userType);
  }

  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_email, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email);
  }

  static Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_email);
  }

  static Future<void> saveUserPhone(String userPhone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneNumber, userPhone);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumber);
  }

  static Future<void> clearUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneNumber);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  /// Initialize SharedPreferences. Should be called at app startup.
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    log(prefs.getString(_userNameKey).toString());
    return prefs.getString(_userNameKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userNameKey);
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
  }

  static Future<bool> isNotFirstOpen() async {
    try {
      if (_prefs == null) {
        await init();
      }

      bool hasOpenedBefore = _prefs?.getBool(_keyFirstOpen) ?? false;

      if (!hasOpenedBefore) {
        await _prefs?.setBool(_keyFirstOpen, true);
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error in isNotFirstOpen: $e');
      return true;
    }
  }

  static Future<void> resetFirstTimeFlag() async {
    try {
      if (_prefs == null) {
        await init();
      }
      await _prefs?.remove(_keyFirstOpen);
    } catch (e) {
      debugPrint('Error resetting first time flag: $e');
    }
  }
}
