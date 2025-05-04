import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FitbitAuthService {
  // Fitbit API credentials (these should be stored securely in a real app)
  final String _clientId;
  final String _clientSecret;
  final String _redirectUri;
  
  // Token storage keys
  static const String _accessTokenKey = 'fitbit_access_token';
  static const String _refreshTokenKey = 'fitbit_refresh_token';
  static const String _tokenExpiryKey = 'fitbit_token_expiry';
  
  FitbitAuthService({
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) : _clientId = clientId,
       _clientSecret = clientSecret,
       _redirectUri = redirectUri;
  
  // Check if user is authenticated with Fitbit
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final tokenExpiry = prefs.getInt(_tokenExpiryKey);
    
    if (accessToken == null || tokenExpiry == null) {
      return false;
    }
    
    // Check if token is expired
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    if (DateTime.now().isAfter(expiryDate)) {
      // Try to refresh the token
      try {
        await _refreshToken();
        return true;
      } catch (e) {
        debugPrint('Failed to refresh token: $e');
        return false;
      }
    }
    
    return true;
  }
  
  // Start OAuth flow
  Future<void> authenticate() async {
    final authUrl = Uri.parse(
      'https://www.fitbit.com/oauth2/authorize'
      '?response_type=code'
      '&client_id=$_clientId'
      '&redirect_uri=$_redirectUri'
      '&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight'
      '&expires_in=604800'
    );
    
    if (await canLaunchUrl(authUrl)) {
      await launchUrl(
        authUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch Fitbit auth URL');
    }
  }
  
  // Handle redirect from Fitbit OAuth
  Future<bool> handleAuthRedirect(Uri uri) async {
    if (uri.host == 'fitbit' && uri.path == '/auth') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        await _exchangeCodeForToken(code);
        return true;
      }
    }
    return false;
  }
  
  // Exchange authorization code for access token
  Future<void> _exchangeCodeForToken(String code) async {
    final tokenUrl = Uri.parse('https://api.fitbit.com/oauth2/token');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}';
    
    final response = await http.post(
      tokenUrl,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': _clientId,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirectUri,
        'code': code,
      },
    );
    
    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      await _saveTokens(tokenData);
    } else {
      throw Exception('Failed to exchange code for token: ${response.body}');
    }
  }
  
  // Refresh access token
  Future<void> _refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }
    
    final tokenUrl = Uri.parse('https://api.fitbit.com/oauth2/token');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$_clientId:$_clientSecret'))}';
    
    final response = await http.post(
      tokenUrl,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    
    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      await _saveTokens(tokenData);
    } else {
      // If refresh fails, clear tokens and require re-authentication
      await logout();
      throw Exception('Failed to refresh token: ${response.body}');
    }
  }
  
  // Save tokens to SharedPreferences
  Future<void> _saveTokens(Map<String, dynamic> tokenData) async {
    final prefs = await SharedPreferences.getInstance();
    
    final accessToken = tokenData['access_token'];
    final refreshToken = tokenData['refresh_token'];
    final expiresIn = tokenData['expires_in'];
    
    if (accessToken != null && refreshToken != null && expiresIn != null) {
      // Calculate expiry date
      final expiryDate = DateTime.now().add(Duration(seconds: expiresIn));
      
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
      await prefs.setInt(_tokenExpiryKey, expiryDate.millisecondsSinceEpoch);
    } else {
      throw Exception('Invalid token data received');
    }
  }
  
  // Get access token (with automatic refresh if needed)
  Future<String> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    final tokenExpiry = prefs.getInt(_tokenExpiryKey);
    
    if (accessToken == null || tokenExpiry == null) {
      throw Exception('Not authenticated with Fitbit');
    }
    
    // Check if token is expired
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(tokenExpiry);
    if (DateTime.now().isAfter(expiryDate)) {
      // Refresh the token
      await _refreshToken();
      return prefs.getString(_accessTokenKey)!;
    }
    
    return accessToken;
  }
  
  // Logout from Fitbit
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
}
