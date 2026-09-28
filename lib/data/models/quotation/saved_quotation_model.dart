import 'dart:convert';

class SavedQuotation {
  final String id;
  final String hotelName;
  final int pax;
  final double totalCostIdr;
  final double sellingPricePerPax;
  final String dateSaved;

  SavedQuotation({
    required this.id,
    required this.hotelName,
    required this.pax,
    required this.totalCostIdr,
    required this.sellingPricePerPax,
    required this.dateSaved,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hotelName': hotelName,
      'pax': pax,
      'totalCostIdr': totalCostIdr,
      'sellingPricePerPax': sellingPricePerPax,
      'dateSaved': dateSaved,
    };
  }

  factory SavedQuotation.fromMap(Map<String, dynamic> map) {
    return SavedQuotation(
      id: map['id'],
      hotelName: map['hotelName'],
      pax: map['pax'],
      totalCostIdr: map['totalCostIdr'],
      sellingPricePerPax: map['sellingPricePerPax'],
      dateSaved: map['dateSaved'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedQuotation.fromJson(String source) =>
      SavedQuotation.fromMap(json.decode(source));
}
