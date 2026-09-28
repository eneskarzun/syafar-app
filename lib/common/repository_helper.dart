import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:syafarapp/common/exception.dart';
import 'package:syafarapp/common/failure.dart';

Future<Either<Failure, T>> executeApiCall<T>(
  Future<T> Function() apiCall,
) async {
  try {
    final result = await apiCall();
    return Right(result);
  } on ServerException {
    return const Left(ServerFailure('Maaf terjadi kesalahan'));
  } on TimeoutException {
    return const Left(
      TimeoutFailure('Waktu koneksi habis. Silakan periksa internet Anda.'),
    );
  } on SocketException {
    return const Left(ConnectionFailure('Failed to connect to the network'));
  } on TlsException catch (e) {
    return Left(CommonFailure('Certificated not valid\n${e.message}'));
  } on BadRequestException catch (e) {
    return Left(BadRequestFailure(e.message));
  } on UnauthorizedException catch (e) {
    return Left(UnauthorizedFailure(e.message));
  } on ForbiddenException catch (e) {
    return Left(ForbiddenFailure(e.message));
  } on NotFoundException catch (e) {
    return Left(NotFoundFailure(e.message));
  } catch (e) {
    return Left(CommonFailure(e.toString()));
  }
}
