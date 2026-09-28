import 'package:equatable/equatable.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchEmpty extends SearchState {}

class SearchLoading extends SearchState {}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchLoaded extends SearchState {
  final List<Hotel> hotels;
  final int nights;
  final int rooms;
  final int pax;
  // --- Tambahan variabel baru ---
  final DateTime checkIn;
  final DateTime checkOut;
  final String roomType;

  const SearchLoaded({
    required this.hotels,
    required this.nights,
    required this.rooms,
    required this.pax,
    required this.checkIn,
    required this.checkOut,
    required this.roomType,
  });

  @override
  List<Object?> get props => [
    hotels,
    nights,
    rooms,
    pax,
    checkIn,
    checkOut,
    roomType,
  ];
}
