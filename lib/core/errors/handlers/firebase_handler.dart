import 'package:firebase_core/firebase_core.dart';

import '../exceptions.dart';

class FirebaseHandler {
  static AppException handle(final dynamic error) {
    if (error is FirebaseException) return _handleFirebase(error);
    return ServerException(message: error.toString());
  }

  static AppException _handleFirebase(final FirebaseException e) {
    switch (e.code) {
      // Auth
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return UnauthorizedException(message: 'Invalid email or password.');

      case 'email-already-in-use':
        return ConflictException(message: 'Email already registered.');

      case 'weak-password':
        return ValidationException(message: 'Password is too weak.');

      case 'invalid-email':
        return ValidationException(message: 'Invalid email format.');

      case 'user-disabled':
        return ForbiddenException(message: 'This account has been disabled.');

      case 'too-many-requests':
        return TooManyRequestsException();

      case 'network-request-failed':
        return NetworkException();

      case 'id-token-expired':
      case 'session-cookie-expired':
        return UnauthorizedException(
            message: 'Session expired. Please login again.');

      // Firestore
      case 'not-found':
        return NotFoundException(message: e.message ?? 'Resource not found.');

      case 'already-exists':
        return ConflictException(
            message: e.message ?? 'Resource already exists.');

      case 'permission-denied':
        return ForbiddenException(message: e.message ?? 'Access forbidden.');

      case 'unavailable':
        return ServerException(
            message: 'Service unavailable.', statusCode: 503);

      case 'deadline-exceeded':
        return TimeoutException();

      default:
        return ServerException(message: e.message ?? 'Unknown Firebase error.');
    }
  }
}
