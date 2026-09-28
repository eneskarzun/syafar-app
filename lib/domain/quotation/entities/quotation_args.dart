import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

class QuotationArgs {
  final Hotel hotel;
  final SearchLoaded searchData;

  QuotationArgs({required this.hotel, required this.searchData});
}
