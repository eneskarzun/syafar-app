import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syafarapp/common/app_colors.dart';
import 'package:syafarapp/common/routers.dart';
import 'package:syafarapp/presentation/bloc/search/search_bloc.dart';
import 'package:syafarapp/presentation/bloc/search/search_event.dart';
import 'package:syafarapp/presentation/bloc/search/search_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCity = 'Makkah';
  String _selectedRoomType = 'Double';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final TextEditingController _paxController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? DateTime.now().add(const Duration(days: 1))
          : (_checkInDate != null
                ? _checkInDate!.add(const Duration(days: 1))
                : DateTime.now().add(const Duration(days: 2))),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && !_checkOutDate!.isAfter(_checkInDate!)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _submitSearch() {
    if (_formKey.currentState!.validate()) {
      if (_checkInDate == null || _checkOutDate == null) {
        _showSnackBar('Mohon lengkapi tanggal Check-in dan Check-out');
        return;
      }
      if (!_checkOutDate!.isAfter(_checkInDate!)) {
        _showSnackBar('Check-out harus setelah Check-in');
        return;
      }

      context.read<SearchBloc>().add(
        SearchHotelsEvent(
          city: _selectedCity,
          checkIn: _checkInDate!,
          checkOut: _checkOutDate!,
          pax: int.parse(_paxController.text),
          roomType: _selectedRoomType,
        ),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _paxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchError) {
            _showSnackBar(state.message);
          } else if (state is SearchLoaded) {
            context.push(RESULT_ROUTE, extra: state);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            "Syafar Tour",
                            textAlign: .center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDropdown(
                                    label: 'Tujuan Kota',
                                    icon: Icons.location_city_rounded,
                                    value: _selectedCity,
                                    items: ['Makkah', 'Madinah'],
                                    onChanged: (val) =>
                                        setState(() => _selectedCity = val!),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDateSelector(
                                          label: 'Check-in',
                                          date: _checkInDate,
                                          onTap: () =>
                                              _selectDate(context, true),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDateSelector(
                                          label: 'Check-out',
                                          date: _checkOutDate,
                                          onTap: () =>
                                              _selectDate(context, false),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    label: 'Jamaah',
                                    icon: Icons.group_rounded,
                                    controller: _paxController,
                                    hint: '0',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDropdown(
                                    label: 'Tipe Kamar',
                                    icon: Icons.bed_rounded,
                                    value: _selectedRoomType,
                                    items: ['Double', 'Triple', 'Quad'],
                                    onChanged: (val) => setState(
                                      () => _selectedRoomType = val!,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: state is SearchLoading
                                          ? null
                                          : _submitSearch,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: state is SearchLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                          : const Text(
                                              'CARI HOTEL',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSub,
      ),
      decoration: _inputDecoration(label, icon),
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(
            val,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.textMain,
      ),
      decoration: _inputDecoration(label, icon, hint: hint),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Wajib diisi';
        if (int.parse(value) <= 0) return 'Min 1';
        return null;
      },
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_month_rounded),
        child: Text(
          date == null ? 'Pilih' : _dateFormat.format(date),
          style: TextStyle(
            fontWeight: date == null ? FontWeight.normal : FontWeight.w600,
            color: date == null ? AppColors.textSub : AppColors.textMain,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
