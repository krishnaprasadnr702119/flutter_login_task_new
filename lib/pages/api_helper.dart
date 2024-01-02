import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newlogin/pages/coverpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper extends Interceptor {
  static const String baseUrl = 'http://192.168.4.166:3001';
  static final Dio _dio = Dio();

  ApiHelper(BuildContext context) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
              'Content-Type': 'application/json',
            },
          );
          return handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401) {
            String? newAccessToken = await refreshToken();
            if (newAccessToken == null) {
              clearTokens(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CoverPage()));
            }

            e.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';

            return handler.resolve(await _dio.fetch(e.requestOptions));
          }

          return handler.next(e);
        },
      ),
    );
  }

  static Future<String?> refreshToken() async {
    var dio = Dio();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');
      if (refreshToken != null) {
        final Response response = await dio.post(
          '$baseUrl/refresh',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        final newAccessToken = response.data['accessToken'];
        await prefs.setString('accessToken', newAccessToken);
        return newAccessToken;
      }
    } catch (e) {
      print('Error during token refresh: $e');

      return null;
    }
    return null;
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        await storeTokens(
            responseData['accessToken'], responseData['refreshToken']);
        return 'Success';
      } else {
        return null;
      }
    } catch (error) {
      print('Sign-in error: $error');
      return null;
    }
  }

  static Future<String?> signUp(
      String email, String name, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/signup',
        data: {
          'email': email,
          'name': name,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return 'Success';
      } else {
        return null;
      }
    } catch (error) {
      print('Sign-up error: $error');
      return null;
    }
  }

  static Future<String?> getProtectedData(BuildContext context) async {
    try {
      final response = await _dio.get(
        '$baseUrl/protected',
      );
      if (response.statusCode == 200) {
        final protectedData = response.data;
        return protectedData.toString();
      } else {
        return await getProtectedData(context);
      }
    } catch (error) {
      print('Error fetching protected data: $error');
    }
    return null;
  }

  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(accessToken);
    print(refreshToken);
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  static Future<void> clearTokens(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
