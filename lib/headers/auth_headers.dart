import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHeaders {
  static Future<Map<String, dynamic>> getAuthHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }
}

class ProtectedDataHeaders {
  static Future<Map<String, dynamic>> getProtectedDataHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };

    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }
}

class SignInHeaders {
  static Map<String, dynamic> getSignInHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
}

class SignUpHeaders {
  static Map<String, dynamic> getSignUpHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
}

class RefreshHeader {
  static Options getAuthHeaders(String refreshToken) {
    return Options(
      headers: {
        'Authorization': 'Bearer $refreshToken',
        'Content-Type': 'application/json',
      },
    );
  }
}
