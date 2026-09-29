import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syafarapp/common/app_colors.dart';
import 'package:syafarapp/common/calculator.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/data/models/quotation/saved_quotation_model.dart';
import 'package:syafarapp/domain/quotation/entities/quotation_args.dart';

class CurrencyFormat extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return newValue.copyWith(text: '');
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(int.parse(digitsOnly));
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class QuotationPage extends StatefulWidget {
  final QuotationArgs args;
  const QuotationPage({super.key, required this.args});
  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  final _kursCtrl = TextEditingController(text: '4.500');
  final _visaCtrl = TextEditingController(text: '500');
  final _transportCtrl = TextEditingController(text: '2.000');
  final _ticketCtrl = TextEditingController(text: '13.000.000');
  final _marginCtrl = TextEditingController(text: '1.000.000');

  Map<String, double> _quotationResult = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  double _parseInput(String text) {
    String cleanText = text.replaceAll('.', '');
    return double.tryParse(cleanText) ?? 0;
  }

  void _calculate() {
    double kurs = _parseInput(_kursCtrl.text);
    if (kurs <= 0) kurs = 1;
    double visa = _parseInput(_visaCtrl.text);
    double transport = _parseInput(_transportCtrl.text);
    double ticket = _parseInput(_ticketCtrl.text);
    double margin = _parseInput(_marginCtrl.text);

    final result = Calculator.calculateQuotation(
      rooms: widget.args.searchData.rooms,
      nights: widget.args.searchData.nights,
      hotelRateSar: widget.args.hotel.rate,
      pax: widget.args.searchData.pax,
      kurs: kurs,
      visaPerPaxSar: visa,
      transportTotalSar: transport,
      ticketPerPaxIdr: ticket,
      marginPerPaxIdr: margin,
    );
    setState(() => _quotationResult = result);
  }

  Future<void> _saveQuotation() async {
    final prefs = await SharedPreferences.getInstance();
    final newQuotation = SavedQuotation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hotelName: widget.args.hotel.name,
      pax: widget.args.searchData.pax,
      totalCostIdr: _quotationResult['totalCostIdr'] ?? 0,
      sellingPricePerPax: _quotationResult['sellingPricePerPax'] ?? 0,
      dateSaved: DateTime.now().toString(),
    );
    List<String> savedList = prefs.getStringList('saved_quotations') ?? [];
    savedList.add(newQuotation.toJson());
    await prefs.setStringList('saved_quotations', savedList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quotation Berhasil Disimpan!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.push(SAVED_QUOTATION_ROUTE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.sizeOf(context).width >= 800;
    final int pax = widget.args.searchData.pax;
    final int rooms = widget.args.searchData.rooms;
    final int nights = widget.args.searchData.nights;
    final double hotelRate = widget.args.hotel.rate;

    double kursRate = _parseInput(_kursCtrl.text);
    double totalHotelSar = rooms * nights * hotelRate;
    double totalVisaSar = _parseInput(_visaCtrl.text) * pax;
    double totalTransportSar = _parseInput(_transportCtrl.text);
    double totalBiayaSarLokal =
        totalHotelSar + totalVisaSar + totalTransportSar;
    double totalTicketPesawat = _parseInput(_ticketCtrl.text) * pax;

    Widget leftPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Form Input Biaya",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInput(
            'Kurs SAR ke IDR',
            _kursCtrl,
            Icons.currency_exchange_rounded,
          ),
          _buildInput(
            'Visa per pax (SAR)',
            _visaCtrl,
            Icons.document_scanner_rounded,
          ),
          _buildInput(
            'Transport TOTAL (SAR)',
            _transportCtrl,
            Icons.directions_bus_rounded,
          ),
          _buildInput(
            'Tiket pesawat per pax (IDR)',
            _ticketCtrl,
            Icons.flight_takeoff_rounded,
          ),
          _buildInput(
            'Margin per pax (IDR)',
            _marginCtrl,
            Icons.payments_rounded,
          ),
        ],
      ),
    );

    Widget rightPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Rincian Estimasi Biaya",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryBadge(Icons.group_rounded, "$pax Pax"),
                _buildSummaryBadge(Icons.bed_rounded, "$rooms Kamar"),
                _buildSummaryBadge(Icons.nightlight_round, "$nights Malam"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildResultRow(
            'Total Hotel ($rooms kmr x $nights mlm)',
            '${NumberFormat.decimalPattern('id').format(totalHotelSar)} SAR',
          ),
          _buildResultRow(
            'Total Visa ($pax pax)',
            '${NumberFormat.decimalPattern('id').format(totalVisaSar)} SAR',
          ),
          _buildResultRow(
            'Total Transport (All In)',
            '${NumberFormat.decimalPattern('id').format(totalTransportSar)} SAR',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(thickness: 1.5),
          ),
          _buildResultRow(
            'TOTAL BIAYA SAR',
            '${NumberFormat.decimalPattern('id').format(totalBiayaSarLokal)} SAR',
            isBold: true,
            color: AppColors.primaryDark,
          ),
          const SizedBox(height: 24),
          _buildResultRow(
            'Konversi SAR ke IDR',
            _currencyFormat.format(totalBiayaSarLokal * kursRate),
          ),
          _buildResultRow(
            'Tiket Pesawat ($pax pax)',
            _currencyFormat.format(totalTicketPesawat),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(thickness: 1.5),
          ),
          _buildResultRow(
            'BIAYA KESELURUHAN',
            _currencyFormat.format(_quotationResult['totalCostIdr'] ?? 0),
            isBold: true,
          ),
          _buildResultRow(
            'Biaya per Pax',
            _currencyFormat.format(_quotationResult['costPerPaxIdr'] ?? 0),
            isBold: true,
            color: AppColors.textSub,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "HARGA JUAL PER PAX",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(
                    _quotationResult['sellingPricePerPax'] ?? 0,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                "SIMPAN QUOTATION",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saveQuotation,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Quotation",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: leftPanel),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: rightPanel),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      leftPanel,
                      const SizedBox(height: 24),
                      rightPanel,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textMain,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyFormat(),
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSub),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
        ),
        onChanged: (value) => _calculate(),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textSub,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              color: color ?? AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
