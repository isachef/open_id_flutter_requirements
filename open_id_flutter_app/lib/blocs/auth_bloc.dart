import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_state.dart';
import 'package:dio/dio.dart';

class AuthBloc extends Cubit<AuthState> {
  final FlutterAppAuth _appAuth;
  final FlutterSecureStorage _storage;
  final Dio _dio = Dio();
  final List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'offline_access',
    'api',
  ];
  final String _postLogoutRedirectUrl = 'com.duendesoftware.demo:/';
  final AuthorizationServiceConfiguration
  _serviceConfiguration = const AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://demo.duendesoftware.com/connect/authorize',
    tokenEndpoint: 'https://demo.duendesoftware.com/connect/token',
    endSessionEndpoint: 'https://demo.duendesoftware.com/connect/endsession',
  );
  AuthBloc({
    required FlutterAppAuth appAuth,
    required FlutterSecureStorage storage,
  }) : _appAuth = appAuth,
       _storage = storage,
       super(const Initial());

  Future<void> login() async {
    try {
      emit(const Authenticating());

      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              'interactive.public',
              'com.duendesoftware.demo:/oauthredirect',
              serviceConfiguration: _serviceConfiguration,
              scopes: _scopes,
              promptValues: ['login'],
              allowInsecureConnections: true, 
            ),
          );

      if (result != null) {
        await _storage.write(key: 'access_token', value: result.accessToken);
        await _storage.write(key: 'id_token', value: result.idToken);
        await _storage.write(key: 'refresh_token', value: result.refreshToken);

        emit(
          Authenticated(
            accessToken: result.accessToken!,
            idToken: result.idToken!,
            refreshToken: result.refreshToken!,
          ),
        );
      } else {
        emit(const Error('Couldn\'t get tokens'));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (e is FlutterAppAuthUserCancelledException) {
      emit(Error('The user cancelled the flow!'));
    } else if (e is FlutterAppAuthPlatformException) {
      emit(Error(e.platformErrorDetails.toString()));
    } else if (e is PlatformException) {
      emit(
        Error(
          'Error\n\nCode: ${e.code}\nMessage: ${e.message}\n'
          'Details: ${e.details}',
        ),
      );
    } else {
      emit(Error('Error: $e'));
    }
  }

  Future<void> logout() async {
    try {
      final idToken = await _storage.read(key: 'id_token');
      if (idToken != null) {
        await _endSession(idToken);
      }
      await _clearSessionInfo();
      emit(const Unauthenticated());
    } catch (e) {
      emit(Error(e.toString()));
    }
  }

  Future<void> _clearSessionInfo() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'id_token');
      await _storage.delete(key: 'refresh_token');
    } catch (e) {
      emit(Error('Error clearing session data: ${e.toString()}'));
    }
  }

  Future<void> _endSession(String idToken) async {
    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: _postLogoutRedirectUrl,
          serviceConfiguration: _serviceConfiguration,
        ),
      );
    } catch (e) {
      emit(Error('Error at the end of the session: ${e.toString()}'));
    }
  }

  Future<void> testapi() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');

      if (accessToken == null) {
        emit(Error('Нет доступного токена для выполнения API запроса'));
        return;
      }

      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _dio.get(
        'https://demo.duendesoftware.com/api/test',
      );

      if (response.statusCode == 200) {
        emit(ApiSuccess(response.data.toString()));
      } else {
        emit(Error('API запрос завершился с ошибкой: ${response.statusCode}'));
      }
    } catch (e) {
      emit(Error('Ошибка при выполнении API запроса: ${e.toString()}'));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final idToken = await _storage.read(key: 'id_token');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (accessToken != null && idToken != null && refreshToken != null) {
        emit(
          Authenticated(
            accessToken: accessToken,
            idToken: idToken,
            refreshToken: refreshToken,
          ),
        );
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(Error(e.toString()));
    }
  }
  
}
