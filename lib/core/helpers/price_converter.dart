import 'package:intl/intl.dart';

class PriceConverter {
  static final _formatter = NumberFormat('#,###.##');

  static double convertToYemeni({
    required double saudiPrice,
    required double exchangeRate,
  }) {
    return saudiPrice * exchangeRate;
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
    final formatter = NumberFormat('#,###.##');
    return formatter.format(number);
  }
}
