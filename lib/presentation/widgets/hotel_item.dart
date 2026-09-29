import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syafarapp/common/app_colors.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/domain/hotel/entities/hotel.dart';
import 'package:syafarapp/domain/quotation/entities/quotation_args.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

class HotelItem extends StatelessWidget {
  final Hotel hotel;
  final NumberFormat currencyFormat;
  final SearchLoaded searchData;
  final double totalHotelSar;
  final double perPaxSar;

  const HotelItem({
    super.key,
    required this.hotel,
    required this.currencyFormat,
    required this.searchData,
    required this.totalHotelSar,
    required this.perPaxSar,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.textSub,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel.city,
                      style: const TextStyle(
                        color: AppColors.textSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rate / Kamar / Malam',
                      style: TextStyle(color: AppColors.textSub, fontSize: 13),
                    ),
                    Text(
                      '${currencyFormat.format(hotel.rate.toInt())} SAR',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRow(
                  'Total Hotel (${searchData.rooms} kmr)',
                  '${currencyFormat.format(totalHotelSar.toInt())} SAR',
                ),
                const SizedBox(height: 4),
                _buildRow(
                  'Biaya Per Jamaah',
                  '${currencyFormat.format(perPaxSar)} SAR',
                  isBold: true,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final args = QuotationArgs(
                        hotel: hotel,
                        searchData: searchData,
                      );
                      context.push(QUOTATION_ROUTE, extra: args);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'PILIH HOTEL',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSub,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: color ?? AppColors.textMain,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
