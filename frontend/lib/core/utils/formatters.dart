import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static String money(num v) => _currency.format(v);
  static String date(DateTime d) => DateFormat('MMM d, y · h:mm a').format(d);
  static String shortDate(DateTime d) => DateFormat('MMM d, y').format(d);
  static String distance(num km) => '${km.toStringAsFixed(1)} km';
  static String duration(num min) => '${min.round()} min';
  static String cardNumberInput(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
    }
    return groups.join(' ');
  }
}
