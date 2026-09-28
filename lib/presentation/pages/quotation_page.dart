import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syafarapp/common/calculator.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/data/models/quotation/saved_quotation_model.dart';
import 'package:syafarapp/domain/quotation/entities/quotation_args.dart';

class QuotationPage extends StatefulWidget {
  final QuotationArgs args;

  const QuotationPage({super.key, required this.args});

  @override
  State<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  final _kursCtrl = TextEditingController(text: '4500'); // Contoh default
  final _visaCtrl = TextEditingController(text: '500');
  final _transportCtrl = TextEditingController(text: '2000');
  final _ticketCtrl = TextEditingController(text: '13000000');
  final _marginCtrl = TextEditingController(text: '1000000');

  Map<String, double> _quotationResult = {};
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _calculate(); // Hitung awal
  }

  void _calculate() {
    // Validasi Kurs tidak boleh kosong atau 0, Harga tidak boleh negatif[cite: 1]
    double kurs = double.tryParse(_kursCtrl.text) ?? 0;
    if (kurs <= 0) kurs = 1; // Cegah error divide by zero atau logic error

    double visa = double.tryParse(_visaCtrl.text) ?? 0;
    if (visa < 0) visa = 0; // Cegah negatif[cite: 1]

    double transport = double.tryParse(_transportCtrl.text) ?? 0;
    if (transport < 0) transport = 0;

    double ticket = double.tryParse(_ticketCtrl.text) ?? 0;
    if (ticket < 0) ticket = 0;

    double margin = double.tryParse(_marginCtrl.text) ?? 0;

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

    setState(() {
      _quotationResult = result;
    });
  }

  @override
  void dispose() {
    _kursCtrl.dispose();
    _visaCtrl.dispose();
    _transportCtrl.dispose();
    _ticketCtrl.dispose();
    _marginCtrl.dispose();
    super.dispose();
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
        const SnackBar(content: Text('Quotation Berhasil Disimpan!')),
      );
      context.push(SAVED_QUOTATION_ROUTE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quotation Engine"), elevation: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ), // Responsive desktop
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Kiri: Form Input ---
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Input Biaya",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInput('Kurs SAR ke IDR', _kursCtrl),
                      _buildInput('Visa per pax (SAR)', _visaCtrl),
                      _buildInput('Transport total (SAR)', _transportCtrl),
                      _buildInput('Tiket pesawat per pax (IDR)', _ticketCtrl),
                      _buildInput('Margin per pax (IDR)', _marginCtrl),
                    ],
                  ),
                ),
              ),

              // --- Kanan: Hasil Kalkulasi ---
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Rincian Biaya",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow(
                          'Total Hotel',
                          '${_quotationResult['totalHotelSar']?.toInt() ?? 0} SAR',
                        ),
                        _buildResultRow(
                          'Total Visa',
                          '${_quotationResult['totalVisaSar']?.toInt() ?? 0} SAR',
                        ),
                        _buildResultRow(
                          'Total Transport',
                          '${_transportCtrl.text} SAR',
                        ),
                        const Divider(thickness: 2),
                        _buildResultRow(
                          'Total SAR',
                          '${_quotationResult['totalSar']?.toInt() ?? 0} SAR',
                          isBold: true,
                        ),
                        const SizedBox(height: 24),
                        _buildResultRow(
                          'Total Biaya (IDR)',
                          _currencyFormat.format(
                            _quotationResult['totalCostSarInIdr'] ?? 0,
                          ),
                        ),
                        _buildResultRow(
                          'Tiket Pesawat (IDR)',
                          _currencyFormat.format(
                            _quotationResult['totalFlightTicketIdr'] ?? 0,
                          ),
                        ),
                        const Divider(thickness: 2),
                        _buildResultRow(
                          'Total Cost (IDR)',
                          _currencyFormat.format(
                            _quotationResult['totalCostIdr'] ?? 0,
                          ),
                          isBold: true,
                        ),
                        _buildResultRow(
                          'Cost per Pax',
                          _currencyFormat.format(
                            _quotationResult['costPerPaxIdr'] ?? 0,
                          ),
                          isBold: true,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "HARGA JUAL PER PAX",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currencyFormat.format(
                                  _quotationResult['sellingPricePerPax'] ?? 0,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text("SIMPAN QUOTATION"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _saveQuotation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) =>
            _calculate(), // Reaktif menghitung otomatis[cite: 1]
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
