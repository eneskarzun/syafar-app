import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syafarapp/data/models/quotation/saved_quotation_model.dart';

class SavedQuotationPage extends StatefulWidget {
  const SavedQuotationPage({super.key});

  @override
  State<SavedQuotationPage> createState() => _SavedQuotationPageState();
}

class _SavedQuotationPageState extends State<SavedQuotationPage> {
  List<SavedQuotation> _savedList = [];
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadSavedQuotations();
  }

  Future<void> _loadSavedQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList =
        prefs.getStringList('saved_quotations') ?? [];

    setState(() {
      _savedList = stringList
          .map((item) => SavedQuotation.fromJson(item))
          .toList()
          .reversed
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quotation Tersimpan")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _savedList.isEmpty
              ? const Text("Belum ada quotation yang disimpan.")
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedList.length,
                  itemBuilder: (context, index) {
                    final item = _savedList[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.receipt)),
                        title: Text(
                          item.hotelName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${item.pax} Jamaah | Jual: ${_currencyFormat.format(item.sellingPricePerPax)} / pax',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Hapus logic
                            final prefs = await SharedPreferences.getInstance();
                            List<String> currentList =
                                prefs.getStringList('saved_quotations') ?? [];
                            currentList.removeWhere(
                              (element) =>
                                  SavedQuotation.fromJson(element).id ==
                                  item.id,
                            );
                            await prefs.setStringList(
                              'saved_quotations',
                              currentList,
                            );
                            _loadSavedQuotations();
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
