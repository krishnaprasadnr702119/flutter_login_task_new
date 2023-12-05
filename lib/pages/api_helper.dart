import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newlogin/pages/coverpage.dart';

class ApiHelper {
  static const String baseUrl = 'http://192.168.4.166:3001';
  static Dio _dio = Dio();

  static Future<void> setupInterceptors() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await getToken('accessToken');

          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          return handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            print('Token expired. Refreshing token');
            await _refreshTokenAndRetry(
              e.requestOptions,
              e.error,
              handler,
              e.requestOptions.extra['context'],
            );
          } else {
            print('Error occurred: $e');
            return handler.reject(e);
          }
        },
      ),
    );
  }

  static Future<void> handleTokenExpired(BuildContext context) async {
    await removeTokens();
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CoverPage()),
    );
  }

  static Future<void> _refreshTokenAndRetry(
    RequestOptions options,
    dynamic error,
    ErrorInterceptorHandler handler,
    BuildContext context,
  ) async {
    final String refreshToken = await getToken('refreshToken') ?? '';
    print('Refreshing token...');

    if (refreshToken.isNotEmpty) {
      try {
        final response = await _dio.post(
          '$baseUrl/refresh',
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          await storeAccessToken(responseData['accessToken']);
          await storeRefreshToken(responseData['refreshToken']);
          print('New Access Token: ${responseData['accessToken']}');

          options.headers['Authorization'] =
              'Bearer ${responseData['accessToken']}';
          final retryResponse = await _dio.request(
            options.path,
            options: Options(
              headers: options.headers,
              method: options.method,
            ),
          );

          return handler.resolve(retryResponse);
        } else {
          print('Token refresh failed. Status code: ${response.statusCode}');
          return handler.reject(DioError(
            response: response,
            requestOptions: options,
          ));
        }
      } catch (error) {
        print('Error during token refresh: $error');
        return handler.reject(DioError(
          requestOptions: options,
          error: error.toString(),
        ));
      }
    } else {
      await removeTokens();
      await handleTokenExpired(context);
    }
  }

  static Future<String?> getToken(String tokenType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenType);
  }

  static Future<void> storeAccessToken(String accessToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  static Future<void> storeRefreshToken(String refreshToken) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('refreshToken', refreshToken);
  }

  static Future<void> removeTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  static Future<Map<String, dynamic>?> signIn(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        await storeAccessToken(responseData['accessToken']);
        await storeRefreshToken(responseData['refreshToken']);
        return responseData;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> signUp(
    String email,
    String name,
    String password,
  ) async {
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
        return responseData;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<String?> getProtectedData(BuildContext context) async {
    try {
      final accessToken = await getToken('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Access token not found. Please sign in.');
      }

      final response = await _dio.get(
        '$baseUrl/protected',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final protectedData = response.data;
        return protectedData.toString();
      } else {
        throw Exception('Failed to retrieve protected data.');
      }
    } catch (error) {
      // Handle error, log, or return specific error code/message
      return null;
    }
  }
}
