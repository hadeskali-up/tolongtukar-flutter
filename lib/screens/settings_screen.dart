import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/billing_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings, required this.themeMode, required this.onThemeChanged});
  final SettingsService settings;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode mode;
  late ThemeMode lastManualMode;
  late bool pro;
  late BillingService billing;
  bool buying = false;
  bool purchaseStartedHere = false;

  @override
  void initState() {
    super.initState();
    mode = widget.themeMode;
    final saved = widget.settings.getString(SettingsService.darkMode, 'false');
    lastManualMode = saved == 'true' ? ThemeMode.dark : ThemeMode.light;
    pro = widget.settings.getBool(SettingsService.isPro);
    billing = BillingService(widget.settings);
    billing.initialize((value) {
      if (!mounted) return;
      setState(() => pro = value);
      if (value && purchaseStartedHere) {
        purchaseStartedHere = false;
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Ads Removed! 🎉'),
            content: const Text('Thank you for your purchase! TolongTukar is now ad-free forever.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great!'))],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    billing.dispose();
    super.dispose();
  }

  Widget section(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
  );

  void changeMode(ThemeMode next) {
    if (next != ThemeMode.system) lastManualMode = next;
    setState(() => mode = next);
    widget.onThemeChanged(next);
  }

  Future<void> buy() async {
    setState(() { buying = true; purchaseStartedHere = true; });
    final error = await billing.buy((value) {
      if (mounted) setState(() => pro = value);
    });
    if (!mounted) return;
    setState(() => buying = false);
    if (error != null) {
      purchaseStartedHere = false;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Purchase Failed'),
          content: Text(error),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        section('Appearance'),
        Card(child: Column(children: [
          SwitchListTile(
            title: const Text('Follow System Theme'),
            subtitle: const Text('Match device light/dark setting'),
            value: mode == ThemeMode.system,
            onChanged: (follow) => changeMode(follow ? ThemeMode.system : lastManualMode),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: mode == ThemeMode.dark,
            onChanged: mode == ThemeMode.system ? null : (dark) => changeMode(dark ? ThemeMode.dark : ThemeMode.light),
          ),
        ])),
        section('Premium'),
        Card(
          color: pro ? const Color(0xFF7AD9CC) : const Color(0xFFFFD02B),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Icon(pro ? Icons.verified : Icons.block, size: 42, color: Colors.black),
              const SizedBox(height: 8),
              Text(pro ? 'Premium Active' : 'Remove Ads Forever', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)),
              Text(pro ? 'Ads removed forever. Thank you!' : 'One-time purchase. No subscriptions.', style: const TextStyle(color: Colors.black)),
              if (!pro) Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton(onPressed: buying ? null : buy, child: Text(buying ? 'Loading…' : 'Remove Ads — RM 4.99')),
              ),
            ]),
          ),
        ),
        section('About'),
        Card(child: Column(children: [
          const ListTile(leading: Icon(Icons.info), title: Text('Version'), trailing: Text('1.0.0')),
          ListTile(leading: const Icon(Icons.description), title: const Text('Terms & Conditions'), trailing: const Icon(Icons.open_in_new), onTap: () => launchUrl(Uri.parse('https://tolongtukar.com/terms.html'))),
          ListTile(leading: const Icon(Icons.privacy_tip), title: const Text('Privacy Policy'), trailing: const Icon(Icons.open_in_new), onTap: () => launchUrl(Uri.parse('https://tolongtukar.com/terms.html'))),
        ])),
        const SizedBox(height: 28),
        const Center(child: Text('TolongTukar v1.0.0\nMade with ❤️ by AliWorld', textAlign: TextAlign.center)),
      ],
    ),
  );
}
