import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/currency_rates.dart';
class ForexService {
  static Future<bool> refresh() async { try { final r=await http.get(Uri.parse(CurrencyRates.endpoint)).timeout(const Duration(seconds:30)); if(r.statusCode!=200)return false; final d=jsonDecode(r.body) as Map<String,dynamic>; final rates=d['rates']; if(rates is! Map)return false; CurrencyRates.update(Map<String,dynamic>.from(rates), (d['last_updated']??d['fetched_at']??'Live rates').toString()); return true; } catch (_) { return false; } }
}
