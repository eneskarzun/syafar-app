import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:syafarapp/data/models/hotels/hotel_model.dart';

abstract class RemoteDataSource {
  Future<List<HotelModel>> getHotels();
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;

  final String baseUrl = 'https://syafar-backend-production.up.railway.app/api';

  RemoteDataSourceImpl({required this.client});

  @override
  Future<List<HotelModel>> getHotels() async {
    final response = await client.get(Uri.parse('$baseUrl/hotels'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List data = jsonResponse['data']['hotels'];
      return data.map((hotel) => HotelModel.fromJson(hotel)).toList();
    } else {
      throw Exception('Gagal mengambil data hotel dari server');
    }
  }
}
