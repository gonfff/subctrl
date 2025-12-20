import 'package:subctrl/domain/entities/currency.dart';

String formatAmountWithCurrency(
  double amount,
  String code, {
  Currency? currency,
}) {
  final normalizedCode = code.toUpperCase();
  final formattedAmount = amount.toStringAsFixed(2);
  final symbol = currency?.symbol;
  if (symbol != null && symbol.isNotEmpty) {
    return '$formattedAmount $symbol';
  }
  return '$formattedAmount $normalizedCode';
}

String currencyDisplayLabel(Currency currency) {
  final buffer = StringBuffer(currency.code);
  if (currency.symbol != null && currency.symbol!.isNotEmpty) {
    buffer.write(' (${currency.symbol})');
  }
  buffer.write(' – ${currency.name}');
  return buffer.toString();
}
