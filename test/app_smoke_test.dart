import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolongtukar_flutter/app.dart';
void main() { testWidgets('home exposes every converter and settings', (tester) async { SharedPreferences.setMockInitialValues({}); await tester.pumpWidget(const TolongTukarApp(skipSplash: true)); await tester.pumpAndSettle(); expect(find.text('TolongTukar'), findsOneWidget); expect(find.text('Currency'), findsOneWidget); expect(find.byTooltip('Settings'), findsOneWidget); }); }
