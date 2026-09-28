class Calculator {
  static int calculateRoomsNeeded(int pax, String roomType) {
    if (pax <= 0) return 0;
    int capacity = 2;
    if (roomType == 'Triple') capacity = 3;
    if (roomType == 'Quad') capacity = 4;
    return (pax / capacity).ceil();
  }

  static Map<String, double> calculateQuotation({
    required int rooms,
    required int nights,
    required double hotelRateSar,
    required int pax,
    required double kurs,
    required double visaPerPaxSar,
    required double transportTotalSar,
    required double ticketPerPaxIdr,
    required double marginPerPaxIdr,
  }) {
    double totalHotelSar = rooms * nights * hotelRateSar;
    double totalVisaSar = pax * visaPerPaxSar;
    double totalSar = totalHotelSar + totalVisaSar + transportTotalSar;
    double totalCostSarInIdr = totalSar * kurs;
    double totalTicketIdr = pax * ticketPerPaxIdr;
    double totalCostIdr = totalCostSarInIdr + totalTicketIdr;
    double costPerPaxIdr = totalCostIdr / pax;
    double sellingPricePerPax = costPerPaxIdr + marginPerPaxIdr;

    return {
      'totalHotelSar': totalHotelSar,
      'totalSar': totalSar,
      'totalCostIdr': totalCostIdr,
      'costPerPaxIdr': costPerPaxIdr,
      'sellingPricePerPax': sellingPricePerPax,
    };
  }
}
