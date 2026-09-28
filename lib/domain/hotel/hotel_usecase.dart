import 'package:dartz/dartz.dart';
import 'package:syafarapp/common/failure.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/domain/hotel/hotel_repository.dart';

class HotelUsecase {
  final HotelRepository repository;

  HotelUsecase(this.repository);

  Future<Either<Failure, List<Hotel>>> execute() {
    return repository.getHotels();
  }
}
