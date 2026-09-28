import 'package:dartz/dartz.dart';
import 'package:syafarapp/common/failure.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';

abstract class HotelRepository {
  Future<Either<Failure, List<Hotel>>> getHotels();
}
