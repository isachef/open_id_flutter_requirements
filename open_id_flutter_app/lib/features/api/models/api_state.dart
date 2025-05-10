abstract class ApiState {
  const ApiState();
}

class ApiInitial extends ApiState {
  const ApiInitial();
}

class ApiLoading extends ApiState {
  const ApiLoading();
}

class ApiSuccess extends ApiState {
  final Map<String, dynamic> data;

  const ApiSuccess(this.data);
}

class ApiError extends ApiState {
  final String message;

  const ApiError(this.message);
}
