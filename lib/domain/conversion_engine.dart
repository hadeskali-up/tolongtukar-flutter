import 'dart:math' as math;
import 'unit_definitions.dart';

class ConversionEngine {
  static Map<String, String> convertToAll(String categoryId, String fromId, double value) {
    final c = UnitDefinitions.byId(categoryId); if (c == null) return {};
    UnitDef? from; for (final u in c.units) { if (u.id == fromId) from = u; }
    if (from == null) return {}; final base = _toBase(from, value);
    return {for (final u in c.units) u.id: formatNumber(_fromBase(u, base))};
  }
  static Map<String, String> convertStringToAll(String categoryId, String fromId, String input) {
    final c = UnitDefinitions.byId(categoryId); if (c == null) return {};
    final n = int.tryParse(input.trim().replaceAll(' ', ''), radix: _radix(fromId));
    return {for (final u in c.units) u.id: n == null ? '' : n.toRadixString(_radix(u.id)).toUpperCase()};
  }
  static double _toBase(UnitDef u, double v) => switch (u.strategy) { UnitStrategy.factor => v*u.factor, UnitStrategy.reciprocal => v == 0 ? 0 : u.factor/v, UnitStrategy.formula => _formulaToBase(u.id,v) };
  static double _fromBase(UnitDef u, double v) => switch (u.strategy) { UnitStrategy.factor => v/u.factor, UnitStrategy.reciprocal => v == 0 ? 0 : u.factor/v, UnitStrategy.formula => _formulaFromBase(u.id,v) };
  static double _formulaToBase(String id,double v) => switch(id) {'fahrenheit'=>(v-32)*5/9,'kelvin'=>v-273.15,'reamur'=>v*5/4,'romer'=>(v-7.5)*40/21,'delisle'=>(100-v)*2/3,'rankine'=>(v-491.67)*5/9,'inches_shoe'=>v*2.54,'eu_china'=>(v-1.2)/1.5,'usa_canada_man'||'usa_canada_child'||'uk_india_child'=>(v+11.67)/.762,'usa_canada_woman'=>(v+10.67)/.762,'uk_india_man'=>(v+10.5)/.762,'uk_india_woman'=>(v+9.5)/.762,_=>v};
  static double _formulaFromBase(String id,double v) => switch(id) {'fahrenheit'=>v*9/5+32,'kelvin'=>v+273.15,'reamur'=>v*4/5,'romer'=>v*21/40+7.5,'delisle'=>100-v*3/2,'rankine'=>(v+273.15)*9/5,'inches_shoe'=>v/2.54,'eu_china'=>v*1.5+1.2,'usa_canada_man'||'usa_canada_child'||'uk_india_child'=>v*.762-11.67,'usa_canada_woman'=>v*.762-10.67,'uk_india_man'=>v*.762-10.5,'uk_india_woman'=>v*.762-9.5,_=>v};
  static int _radix(String id) => switch(id) {'binary'=>2,'octal'=>8,'hexadecimal'=>16,_=>10};
  static String formatNumber(double value) {
    if (!value.isFinite) return '—'; final a=value.abs();
    if(a!=0&&(a<1e-4||a>=1e12)){final exp=(math.log(a)/math.ln10).floor();final m=value/math.pow(10,exp);return '${_trim(m.toStringAsFixed(4))}E${exp>=0?'+':''}$exp';}
    final rounded=_significant(value,8); final raw=_trim(rounded.toStringAsFixed(6)); final parts=raw.split('.'); final neg=parts[0].startsWith('-'); final digits=neg?parts[0].substring(1):parts[0]; final grouped=digits.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'),(_)=>','); return '${neg?'-':''}$grouped${parts.length>1?'.${parts[1]}':''}';
  }
  static String _trim(String s)=>s.contains('.')?s.replaceFirst(RegExp(r'0+$'),'').replaceFirst(RegExp(r'\.$'),''):s;
  static double _significant(double v,int sf){if(v==0)return 0;final d=(math.log(v.abs())/math.ln10).ceil();final p=sf-d;final mag=math.pow(10,p).toDouble();return (v*mag).round()/mag;}
}
