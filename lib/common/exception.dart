class ServerException implements Exception {}

class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message);
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);
}

class UnProcessableException implements Exception {
  final String message;

  UnProcessableException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String message;

  ForbiddenException(this.message);
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);
}
