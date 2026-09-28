import 'package:dartz/dartz.dart';
import 'package:syafarapp/common/failure.dart';
import 'package:syafarapp/common/repository_helper.dart';
import 'package:syafarapp/data/datasources/remote_data_sources.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/domain/hotel/hotel_repository.dart';

class HotelRepositoryImpl implements HotelRepository {
  final RemoteDataSource remoteDataSource;

  HotelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Hotel>>> getHotels() async {
    return executeApiCall(() async {
      final result = await remoteDataSource.getHotels();
      return result;
    });
  }
}
