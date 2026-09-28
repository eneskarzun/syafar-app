import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  String _selectedCity = 'Makkah'; // Default Makkah
  String _selectedRoomType = 'Quad'; // Default Quad[cite: 1]
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  final TextEditingController _paxController = TextEditingController();

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Reset checkout jika checkout sebelum checkin baru
          if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon lengkapi tanggal Check-in dan Check-out'),
          ),
        );
        return;
      }

      // Validasi Check-out harus setelah check-in[cite: 1] dilakukan di BLoC, tapi kita cegah juga di UI
      if (!_checkOutDate!.isAfter(_checkInDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out harus setelah Check-in')),
        );
        return;
      }

      // Jalankan Event BLoC
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

  @override
  void dispose() {
    _paxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Hotel Syafar"),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchError) {
            // Tampilkan error jika API gagal atau validasi BLoC gagal[cite: 1]
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SearchLoaded) {
            // Navigasi ke halaman hasil dan bawa data state-nya
            context.push(RESULT_ROUTE, extra: state);
          }
        },
        builder: (context, state) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Responsive untuk web/desktop[cite: 1]
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Dropdown Kota ---
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'Kota',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Makkah', 'Madinah'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCity = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Date Picker Check-in ---
                      InkWell(
                        onTap: () => _selectDate(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Check-in',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _checkInDate == null
                                ? 'Pilih Tanggal'
                                : _dateFormat.format(_checkInDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Date Picker Check-out ---
                      InkWell(
                        onTap: () => _selectDate(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Check-out',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _checkOutDate == null
                                ? 'Pilih Tanggal'
                                : _dateFormat.format(_checkOutDate!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Input Jumlah Jamaah (Pax) ---
                      TextFormField(
                        controller: _paxController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Jamaah (Pax)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Tidak boleh kosong';
                          final intValue = int.tryParse(value);
                          if (intValue == null || intValue <= 0)
                            return 'Pax tidak boleh 0 atau teks';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Dropdown Tipe Kamar ---
                      DropdownButtonFormField<String>(
                        value: _selectedRoomType,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Kamar',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Double', 'Triple', 'Quad', 'Quint'].map((
                          String value,
                        ) {
                          // Quint ditambahkan untuk bonus[cite: 1]
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRoomType = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // --- Tombol Cari ---
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is SearchLoading
                              ? null
                              : _submitSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                          child:
                              state
                                  is SearchLoading // Loading State Mock API[cite: 1]
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'CARI HOTEL',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
