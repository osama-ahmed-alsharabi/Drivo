// lib/core/utils/delivery_calculator.dart
import 'package:latlong2/latlong.dart';

class DeliveryCalculator {
  static const double pricePerKilometer = 3000.0; // 3000 Yemeni Rial per km
  static const double baseFee = 5000.0; // Base delivery fee

  static double calculateDeliveryFee(LatLng restaurant, LatLng customer) {
    final distance = _calculateDistance(restaurant, customer);
    return baseFee + (distance * pricePerKilometer);
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }
}
