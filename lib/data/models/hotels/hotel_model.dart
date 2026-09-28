import 'package:syafarapp/domain/hotel/entities/hotel.dart';

class HotelModel extends Hotel {
  const HotelModel({
    required super.id,
    required super.name,
    required super.city,
    required super.rate,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      rate: (json['rate'] as num).toDouble(),
    );
  }
}
