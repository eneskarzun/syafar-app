import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/domain/quotation/entities/quotation_args.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

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

  // Logika Filter & Sorting
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

    // Format Tanggal
    final dateFormat = DateFormat('dd MMM yyyy');
    final String dateRangeStr =
        "${dateFormat.format(widget.searchData.checkIn)} - ${dateFormat.format(widget.searchData.checkOut)}";

    return Scaffold(
      appBar: AppBar(
        title: Text("Hotel di $city"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () => context.push(SAVED_QUOTATION_ROUTE),
            tooltip: 'Quotation Tersimpan',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- 1. Ringkasan Kebutuhan Pencarian (Ikut Terscroll) ---
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Ringkasan Kebutuhan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateRangeStr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.searchData.pax} Jamaah | Tipe ${widget.searchData.roomType} | ${widget.searchData.rooms} Kamar | ${widget.searchData.nights} Malam",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // --- 2. Area Filter & Search (Langsung Terbuka & Ikut Terscroll) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Filter & Urutkan Pencarian",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Cari nama hotel...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _sortOption,
                            decoration: const InputDecoration(
                              labelText: 'Urutkan Harga',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['Termurah', 'Termahal'].map((String val) {
                              return DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _sortOption = val!),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Rentang Harga: ${_priceRange.start.toInt()} SAR - ${_priceRange.end.toInt()} SAR',
                          ),
                          RangeSlider(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // --- 3. Daftar Hotel (Ikut Terscroll) ---
              hotels.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text("Tidak ada hotel yang sesuai kriteria."),
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

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildRow(
                                    'Rate',
                                    '${hotel.rate.toInt()} SAR / room / night',
                                  ),
                                  _buildRow(
                                    'Total Hotel',
                                    '${totalHotelSar.toInt()} SAR',
                                    isBold: true,
                                  ),
                                  _buildRow(
                                    'Per Pax',
                                    '${perPaxSar.toStringAsFixed(2)} SAR',
                                    isBold: true,
                                    color: Colors.blue[800],
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final args = QuotationArgs(
                                          hotel: hotel,
                                          searchData: widget.searchData,
                                        );
                                        context.push(
                                          QUOTATION_ROUTE,
                                          extra: args,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[800],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'PILIH HOTEL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
