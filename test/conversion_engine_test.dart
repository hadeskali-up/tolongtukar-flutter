import 'package:flutter_test/flutter_test.dart';
import 'package:tolongtukar_flutter/domain/conversion_engine.dart';
import 'package:tolongtukar_flutter/domain/currency_rates.dart';
import 'package:tolongtukar_flutter/domain/unit_definitions.dart';

void main() {
  test('ports all 20 categories and all 253 original units and currencies', () {
    expect(UnitDefinitions.categories.length, 20);
    expect(UnitDefinitions.categories.fold<int>(0, (n, c) => n + c.units.length), 253);
  });
  test('length conversion avoids floating point noise', () => expect(ConversionEngine.convertToAll('length', 'meters', 1)['feet'], startsWith('3.28084')));
  test('temperature formulas work', () => expect(ConversionEngine.convertToAll('temperature', 'celsius', 100)['fahrenheit'], '212'));
  test('numeral systems work', () { final r = ConversionEngine.convertStringToAll('numeral_systems', 'decimal_numeral', '255'); expect(r['hexadecimal'], 'FF'); expect(r['binary'], '11111111'); });
  test('refreshed currency rates work both ways', () { CurrencyRates.update({'USD': 1, 'MYR': 5}, 'test'); expect(ConversionEngine.convertToAll('currency', 'USD', 2)['MYR'], '10'); expect(ConversionEngine.convertToAll('currency', 'MYR', 10)['USD'], '2'); });
  test('reciprocal units work', () { expect(ConversionEngine.convertToAll('fuel_consumption', 'liters_per_100km', 5)['kilometers_per_liter'], '20'); expect(ConversionEngine.convertToAll('speed', 'minutes_per_kilometer', 5)['meters_per_second'], startsWith('3.333')); });
  test('currency priority is MYR USD GBP EUR IDR before the rest', () {
    expect(CurrencyRates.units.take(5).map((unit) => unit.id).toList(), ['MYR', 'USD', 'GBP', 'EUR', 'IDR']);
  });
}
