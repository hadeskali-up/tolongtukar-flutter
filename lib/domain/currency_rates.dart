import 'unit_definitions.dart';

class CurrencyRates {
  static const endpoint = 'https://alisuhari.top/forex.json';
  static String lastUpdated = 'Offline (static rates)';
  static final Map<String, double> rates = {
    'USD': 1, 'EUR': .8788, 'JPY': 163.81, 'GBP': .7507, 'CNY': 7.24,
    'AUD': 1.52, 'CAD': 1.36, 'CHF': .88, 'SEK': 10.48, 'NOK': 10.79,
    'DKK': 6.88, 'KRW': 1310, 'MXN': 17.05, 'INR': 83.25, 'BRL': 4.95,
    'ZAR': 18.50, 'TRY': 28.95, 'PLN': 4.05, 'CZK': 23.10, 'HUF': 360,
    'IDR': 15850, 'THB': 35.80, 'PHP': 56.20, 'MYR': 4.0909, 'HKD': 7.82,
    'SGD': 1.34, 'NZD': 1.66, 'AED': 3.67, 'SAR': 3.75, 'PKR': 278,
  };
  static const names = {
    'USD':'US Dollar','EUR':'Euro','JPY':'Japanese Yen','GBP':'British Pound','CNY':'Chinese Yuan','AUD':'Australian Dollar','CAD':'Canadian Dollar','CHF':'Swiss Franc','SEK':'Swedish Krona','NOK':'Norwegian Krone','DKK':'Danish Krone','KRW':'South Korean Won','MXN':'Mexican Peso','INR':'Indian Rupee','BRL':'Brazilian Real','ZAR':'South African Rand','TRY':'Turkish Lira','PLN':'Polish Zloty','CZK':'Czech Koruna','HUF':'Hungarian Forint','IDR':'Indonesian Rupiah','THB':'Thai Baht','PHP':'Philippine Peso','MYR':'Malaysian Ringgit','HKD':'Hong Kong Dollar','SGD':'Singapore Dollar','NZD':'New Zealand Dollar','AED':'UAE Dirham','SAR':'Saudi Riyal','PKR':'Pakistani Rupee'
  };
  static const priority = ['MYR', 'USD', 'GBP', 'EUR', 'IDR'];
  static List<UnitDef> get units {
    final orderedCodes = [
      ...priority.where(rates.containsKey),
      ...(rates.keys.where((code) => !priority.contains(code)).toList()..sort()),
    ];
    return orderedCodes.map((code) => UnitDef(
      id: code,
      name: names[code] ?? code,
      symbol: code,
      strategy: UnitStrategy.factor,
      factor: 1 / rates[code]!,
    )).toList();
  }
  static void update(Map<String, dynamic> fresh, String timestamp) { for (final e in fresh.entries) { if (rates.containsKey(e.key) && e.value is num) rates[e.key] = (e.value as num).toDouble(); } lastUpdated = timestamp; }
}
