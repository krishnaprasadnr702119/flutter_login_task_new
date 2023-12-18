import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper extends Interceptor {
  static const String baseUrl = 'http://192.168.4.166:3001';
  static Dio _dio = Dio();

  ApiHelper() {
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');
      if (refreshToken != null) {
        final Response response = await _dio.post(
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        print('Access token not found. Please sign in.');
        return null;
      }

      final Response? response = await _fetchProtectedData(accessToken);
      if (response == null) {
        return null;
      }
      print(response.statusCode);
      if (response.statusCode == 200) {
        final protectedData = response.data;
        return protectedData.toString();
      } else if (response.statusCode == 401) {
        final newAccessToken = await refreshToken();
        if (newAccessToken != null) {
          // Retry request with new access token
          // final newResponse = await _fetchProtectedData(newAccessToken);
          // if (newResponse.statusCode == 200) {
          //   final protectedData = newResponse.data;
          //   return protectedData.toString();
          // }
        }
        print('Failed to refresh token or fetch protected data.');
        return null;
      } else {
        print('Failed to fetch protected data: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching protected data: $error');
      return null;
    }
  }

  static Future<Response?> _fetchProtectedData(String accessToken) async {
    try {
      final response = await _dio.get(
        '$baseUrl/protected',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response;
      } else {
        return null;
      }
    }
  }

  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print(accessToken);
    print(refreshToken);
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }
}
