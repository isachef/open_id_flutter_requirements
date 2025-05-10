import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/api_state.dart';

class ApiBloc extends Cubit<ApiState> {
  final FlutterSecureStorage _storage;
  final Dio _dio = Dio();

  ApiBloc({required FlutterSecureStorage storage})
    : _storage = storage,
      super(const ApiInitial());

  Future<void> testApi() async {
    try {
      emit(const ApiLoading());

      final accessToken = await _storage.read(key: 'access_token');

      if (accessToken == null) {
        emit(
          const ApiError('Нет доступного токена для выполнения API запроса'),
        );
        return;
      }

      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      try {
        final response = await _dio.get(
          'https://demo.duendesoftware.com/api/test',
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData;

          if (response.data is String) {
            try {
              jsonData = jsonDecode(response.data);
            } catch (e) {
              jsonData = {
                'data': response.data.toString(),
                'timestamp': DateTime.now().toIso8601String(),
                'status': 'success',
              };
            }
          } else if (response.data is Map) {
            jsonData = Map<String, dynamic>.from(response.data);
          } else if (response.data is List) {
            jsonData = {
              'data': response.data,
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'success',
            };
          } else {
            jsonData = {
              'data': response.data.toString(),
              'timestamp': DateTime.now().toIso8601String(),
              'status': 'success',
            };
          }

          emit(ApiSuccess(jsonData));
        } else {
          emit(
            ApiError('API запрос завершился с ошибкой: ${response.statusCode}'),
          );
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          emit(
            const ApiError(
              'Токен истек. Пожалуйста, обновите токен и попробуйте снова',
            ),
          );
        } else {
          emit(ApiError('Ошибка при выполнении API запроса: ${e.toString()}'));
        }
      }
    } catch (e) {
      emit(ApiError('Ошибка при выполнении API запроса: ${e.toString()}'));
    }
  }
}
