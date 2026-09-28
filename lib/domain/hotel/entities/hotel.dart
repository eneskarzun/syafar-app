import 'package:equatable/equatable.dart';

class Hotel extends Equatable {
  final int id;
  final String name;
  final String city;
  final double rate;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.rate,
  });

  @override
  List<Object?> get props => [id, name, city, rate];
}
