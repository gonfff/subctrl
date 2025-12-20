class CurrencySeed {
  const CurrencySeed({required this.code, required this.name, this.symbol});

  final String code;
  final String name;
  final String? symbol;
}

/// Built-in currencies are limited to the codes supported by Yahoo Finance FX.
const List<CurrencySeed> currencySeeds = [
  CurrencySeed(code: 'AED', name: 'United Arab Emirates Dirham', symbol: 'د.إ'),
  CurrencySeed(code: 'ARS', name: 'Argentine Peso', symbol: r'$'),
  CurrencySeed(code: 'AUD', name: 'Australian Dollar', symbol: r'A$'),
  CurrencySeed(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв'),
  CurrencySeed(code: 'BRL', name: 'Brazilian Real', symbol: r'R$'),
  CurrencySeed(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$'),
  CurrencySeed(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
  CurrencySeed(code: 'CLP', name: 'Chilean Peso', symbol: r'$'),
  CurrencySeed(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  CurrencySeed(code: 'COP', name: 'Colombian Peso', symbol: r'$'),
  CurrencySeed(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč'),
  CurrencySeed(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
  CurrencySeed(code: 'EUR', name: 'Euro', symbol: '€'),
  CurrencySeed(code: 'GBP', name: 'British Pound Sterling', symbol: '£'),
  CurrencySeed(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$'),
  CurrencySeed(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft'),
  CurrencySeed(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
  CurrencySeed(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪'),
  CurrencySeed(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  CurrencySeed(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  CurrencySeed(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  CurrencySeed(code: 'KZT', name: 'Kazakhstani Tenge', symbol: '₸'),
  CurrencySeed(code: 'MAD', name: 'Moroccan Dirham', symbol: 'د.م.'),
  CurrencySeed(code: 'MXN', name: 'Mexican Peso', symbol: r'$'),
  CurrencySeed(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  CurrencySeed(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
  CurrencySeed(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$'),
  CurrencySeed(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/'),
  CurrencySeed(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  CurrencySeed(code: 'PLN', name: 'Polish Złoty', symbol: 'zł'),
  CurrencySeed(code: 'RON', name: 'Romanian Leu', symbol: 'lei'),
  CurrencySeed(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
  CurrencySeed(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
  CurrencySeed(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
  CurrencySeed(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$'),
  CurrencySeed(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  CurrencySeed(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  CurrencySeed(code: 'TWD', name: 'New Taiwan Dollar', symbol: r'NT$'),
  CurrencySeed(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴'),
  CurrencySeed(code: 'USD', name: 'United States Dollar', symbol: r'$'),
  CurrencySeed(code: 'VND', name: 'Vietnamese Dong', symbol: '₫'),
  CurrencySeed(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
];
