import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syafarapp/common/app_colors.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';
import 'package:syafarapp/presentation/widgets/hotel_item.dart';

class ResultPage extends StatefulWidget {
  final SearchLoaded searchData;

  const ResultPage({super.key, required this.searchData});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _searchQuery = '';
  String _sortOption = 'Termurah';
  RangeValues _priceRange = const RangeValues(0, 5000);

  final NumberFormat _currencyFormat = NumberFormat.decimalPattern('id');

  List<Hotel> get _filteredAndSortedHotels {
    List<Hotel> list = widget.searchData.hotels.where((hotel) {
      final matchName = hotel.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchPrice =
          hotel.rate >= _priceRange.start && hotel.rate <= _priceRange.end;
      return matchName && matchPrice;
    }).toList();

    if (_sortOption == 'Termurah') {
      list.sort((a, b) => a.rate.compareTo(b.rate));
    } else {
      list.sort((a, b) => b.rate.compareTo(a.rate));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final hotels = _filteredAndSortedHotels;
    final String city = widget.searchData.hotels.isNotEmpty
        ? widget.searchData.hotels.first.city
        : 'Pencarian';
    final dateFormat = DateFormat('dd MMM yyyy');
    final String dateRangeStr =
        "${dateFormat.format(widget.searchData.checkIn)} - ${dateFormat.format(widget.searchData.checkOut)}";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                    title: Text(
                      "Hotel di $city",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.bookmarks_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => context.push(SAVED_QUOTATION_ROUTE),
                    tooltip: 'Quotation Tersimpan',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateRangeStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${widget.searchData.pax} Jamaah  •  Tipe ${widget.searchData.roomType}  •  ${widget.searchData.rooms} Kamar  •  ${widget.searchData.nights} Malam",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.filter_list_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Filter & Urutkan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: _inputDecoration(
                            'Cari nama hotel...',
                            Icons.search_rounded,
                          ),
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _sortOption,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSub,
                          ),
                          decoration: _inputDecoration(
                            'Urutkan Harga',
                            Icons.sort_rounded,
                          ),
                          items: ['Termurah', 'Termahal'].map((String val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Text(
                                val,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _sortOption = val!),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Rentang Harga: ${_currencyFormat.format(_priceRange.start.toInt())} SAR - ${_currencyFormat.format(_priceRange.end.toInt())} SAR',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textMain,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.primaryLight,
                            thumbColor: AppColors.accent,
                            overlayColor: AppColors.accent.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 5000,
                            divisions: 50,
                            labels: RangeLabels(
                              '${_priceRange.start.toInt()}',
                              '${_priceRange.end.toInt()}',
                            ),
                            onChanged: (val) =>
                                setState(() => _priceRange = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              hotels.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hotel_rounded,
                              size: 64,
                              color: AppColors.textSub.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Tidak ada hotel yang sesuai.",
                              style: TextStyle(
                                color: AppColors.textSub,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.builder(
                        itemCount: hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = hotels[index];
                          final double totalHotelSar =
                              widget.searchData.rooms *
                              widget.searchData.nights *
                              hotel.rate;
                          final double perPaxSar =
                              totalHotelSar / widget.searchData.pax;

                          return HotelItem(
                            hotel: hotel,
                            currencyFormat: _currencyFormat,
                            searchData: widget.searchData,
                            totalHotelSar: totalHotelSar,
                            perPaxSar: perPaxSar,
                          );
                        },
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
