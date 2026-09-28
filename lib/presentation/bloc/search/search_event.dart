import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchHotelsEvent extends SearchEvent {
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final int pax;
  final String roomType;

  const SearchHotelsEvent({
    required this.city,
    required this.checkIn,
    required this.checkOut,
    required this.pax,
    required this.roomType,
  });

  @override
  List<Object?> get props => [city, checkIn, checkOut, pax, roomType];
}
