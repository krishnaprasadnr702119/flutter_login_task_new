import 'package:shared_preferences/shared_preferences.dart';

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
