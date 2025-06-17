// price_converter.dart
import 'package:intl/intl.dart';

class PriceConverter {
  static final _formatter = NumberFormat('#,###');

  static double convertToYemeni({
    required double saudiPrice,
    required double exchangeRate,
  }) {
    double converted = saudiPrice * exchangeRate;

    // Handle prices below 100
    if (converted < 100 && converted > 0) {
      return 100.0;
    }

    // Round to nearest 100
    return (converted / 100).roundToDouble() * 100;
  }

  static String displayConvertedPrice({
    required double saudiPrice,
    required double exchangeRate,
    bool showBoth = false,
  }) {
    final yemeniPrice = convertToYemeni(
      saudiPrice: saudiPrice,
      exchangeRate: exchangeRate,
    );

    if (showBoth) {
      return '${_formatter.format(saudiPrice)} ر.س (≈ ${_formatter.format(yemeniPrice)} ريال يمني)';
    } else {
      return '${_formatter.format(yemeniPrice)} ريال يمني';
    }
  }

  static String formatNumberWithCommas(double number) {
    return _formatter.format(number);
  }
}
