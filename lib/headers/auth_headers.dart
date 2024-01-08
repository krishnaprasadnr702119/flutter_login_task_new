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
