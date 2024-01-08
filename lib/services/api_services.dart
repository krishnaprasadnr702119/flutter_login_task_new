import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newlogin/headers/auth_headers.dart';
import 'package:newlogin/headers/protected_data_headers.dart';
import 'package:newlogin/headers/signin_headers.dart';
import 'package:newlogin/headers/signup_headers.dart';
import 'package:newlogin/screens/coverpage.dart';
import 'package:newlogin/services/api_constants.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper extends Interceptor {
  static final Dio _dio = Dio();

  ApiHelper(BuildContext context) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authHeaders = await AuthHeaders.getAuthHeaders();
          options.headers = authHeaders;

          return handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401) {
            String? newAccessToken = await refreshToken(context);

            if (newAccessToken != null) {
              e.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              return handler.resolve(await _dio.fetch(e.requestOptions));
            } else {
              await clearTokens(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CoverPage()),
              );
              return null;
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<String?> refreshToken(BuildContext context) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? refreshToken = prefs.getString('refreshToken');
      if (refreshToken != null) {
        final dio = Dio();
        final Response response = await dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.refreshEndpoint}',
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
      print('Refresh Token Expired: $e');
      await clearTokens(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CoverPage()),
      );
      return null;
    }
    return null;
  }

  static Future<void> clearTokens(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      final signInHeaders = SignInHeaders.getSignInHeaders();
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
        data: {'email': email, 'password': password},
        options: Options(headers: signInHeaders),
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
      final signUpHeaders = SignUpHeaders.getSignUpHeaders();
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.signupEndpoint}',
        data: {
          'email': email,
          'name': name,
          'password': password,
        },
        options: Options(headers: signUpHeaders),
      );

      if (response.statusCode == 200) {
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
      final protectedDataHeaders =
          await ProtectedDataHeaders.getProtectedDataHeaders();
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.protectedDataEndpoint}',
        options: Options(headers: protectedDataHeaders),
      );

      if (response.statusCode == 200) {
        final protectedData = response.data;
        return protectedData.toString();
      }

      return null;
    } catch (error) {
      print('Error fetching protected data: $error');
      return null;
    }
  }

  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }
}
