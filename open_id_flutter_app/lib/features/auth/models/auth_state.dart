abstract class AuthState {
  const AuthState();
}

class Initial extends AuthState {
  const Initial();
}

class Authenticating extends AuthState {
  const Authenticating();
}

class Authenticated extends AuthState {
  final String accessToken;
  final String idToken;
  final String refreshToken;

  const Authenticated({
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
  });
}

class Error extends AuthState {
  final String message;

  const Error(this.message);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}
