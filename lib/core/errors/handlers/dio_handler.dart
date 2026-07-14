import 'package:dio/dio.dart';

import '../exceptions.dart';

class DioHandler {
  static AppException handle(final dynamic error) {
    if (error is DioException) return _handleDio(error);
    return ServerException(message: error.toString());
  }

  static AppException _handleDio(final DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _mapByCode(e.response?.statusCode, e.message ?? 'Server error.');

      default:
        return ServerException(message: e.message ?? 'Unknown error.');
    }
  }

  static AppException _mapByCode(final int? code, final String message) {
    switch (code) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 409:
        return ConflictException(message: message);
      case 422:
        return ValidationException(message: message);
      case 429:
        return TooManyRequestsException(message: message);
      case 500:
      case 502:
      case 503:
        return ServerException(message: message, statusCode: code);
      default:
        return ServerException(message: message);
    }
  }
}
