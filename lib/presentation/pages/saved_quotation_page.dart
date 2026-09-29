import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syafarapp/common/app_colors.dart';
import 'package:syafarapp/data/models/quotation/saved_quotation_model.dart';
import 'package:syafarapp/presentation/widgets/saved_quotation_item.dart';

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

  Future<void> _deleteQuotation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentList = prefs.getStringList('saved_quotations') ?? [];
    currentList.removeWhere(
      (element) => SavedQuotation.fromJson(element).id == id,
    );
    await prefs.setStringList('saved_quotations', currentList);
    _loadSavedQuotations();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quotation berhasil dihapus'),
          backgroundColor: AppColors.textMain,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, SavedQuotation item) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Quotation?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus quotation untuk hotel ${item.hotelName}?",
            style: const TextStyle(color: AppColors.textSub),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "Batal",
                style: TextStyle(color: AppColors.textSub),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteQuotation(item.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
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
                  child: const FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(left: 48, bottom: 16),
                    title: Text(
                      "Quotation Tersimpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _savedList.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.receipt_long_rounded,
                                size: 64,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Belum ada Quotation",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Quotation yang Anda simpan akan muncul di sini.",
                              style: TextStyle(color: AppColors.textSub),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      sliver: SliverList.builder(
                        itemCount: _savedList.length,
                        itemBuilder: (context, index) {
                          final item = _savedList[index];

                          return SavedQuotationItem(
                            item: item,
                            currencyFormat: _currencyFormat,
                            onDelete: () => _confirmDelete(context, item),
                          );
                        },
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
