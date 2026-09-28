import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syafarapp/common/calculator.dart';
import 'package:syafarapp/domain/hotel/hotel_usecase.dart';
import 'package:syafarapp/presentation/bloc/search/search_event.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final HotelUsecase hotelUsecase;

  SearchBloc({required this.hotelUsecase}) : super(SearchEmpty()) {
    on<SearchHotelsEvent>((event, emit) async {
      emit(SearchLoading());

      // Validasi Check-out harus setelah check-in[cite: 1]
      if (!event.checkOut.isAfter(event.checkIn)) {
        emit(const SearchError("Check-out harus setelah check-in"));
        return;
      }

      // Validasi Pax[cite: 1]
      if (event.pax <= 0) {
        emit(const SearchError("Jumlah jamaah tidak boleh 0"));
        return;
      }

      final result = await hotelUsecase.execute();

      result.fold(
        (failure) {
          emit(SearchError(failure.message));
        },
        (hotels) {
          // Filter Hotel Berdasarkan Kota (Makkah / Madinah)[cite: 1]
          final filteredHotels = hotels
              .where((h) => h.city == event.city)
              .toList();

          // Hitung Malam & Kamar[cite: 1]
          final nights = event.checkOut.difference(event.checkIn).inDays;
          final rooms = Calculator.calculateRoomsNeeded(
            event.pax,
            event.roomType,
          );

          emit(
            SearchLoaded(
              hotels: filteredHotels,
              nights: nights,
              rooms: rooms,
              pax: event.pax,
              checkIn: event.checkIn,
              checkOut: event.checkOut,
              roomType: event.roomType,
            ),
          );
        },
      );
    });
  }
}
