import 'package:flutter/material.dart';
import '../domain/unit_definitions.dart';
import '../services/settings_service.dart';
import 'converter_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.settings, required this.themeMode, required this.onThemeChanged});
  final SettingsService settings;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> order;
  bool edit = false;

  @override
  void initState() {
    super.initState();
    final all = UnitDefinitions.categories.map((e) => e.id).toList();
    final saved = widget.settings.getString(SettingsService.categoryOrder).split(',').where(all.contains).toList();
    order = [...saved, ...all.where((e) => !saved.contains(e))];
  }

  IconData icon(String id) => switch (id) {
    'currency' => Icons.currency_exchange, 'length' => Icons.straighten,
    'area' => Icons.crop_square, 'volume' => Icons.water_drop,
    'mass' => Icons.scale, 'time' => Icons.schedule, 'speed' => Icons.speed,
    'force' => Icons.bolt, 'fuel_consumption' => Icons.local_gas_station,
    'pressure' => Icons.compress, 'energy' => Icons.sunny,
    'power' => Icons.electrical_services, 'angle' => Icons.architecture,
    'torque' => Icons.sync, 'digital_data' => Icons.memory,
    'si_prefixes' => Icons.science, 'density' => Icons.blur_on,
    'temperature' => Icons.thermostat, 'numeral_systems' => Icons.code,
    'shoe_size' => Icons.directions_walk, _ => Icons.calculate,
  };

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in UnitDefinitions.categories) c.id: c};
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Image.asset('assets/icon.png', width: 34), const SizedBox(width: 8), const Text('TolongTukar', style: TextStyle(fontWeight: FontWeight.w900))]),
        actions: [
          IconButton(tooltip: edit ? 'Done' : 'Reorder categories', onPressed: () => setState(() => edit = !edit), icon: Icon(edit ? Icons.done : Icons.edit)),
          IconButton(tooltip: 'Settings', onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(settings: widget.settings, themeMode: widget.themeMode, onThemeChanged: widget.onThemeChanged))), icon: const Icon(Icons.settings)),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: order.length,
        onReorder: (a, b) {
          if (!edit) return;
          if (b > a) b--;
          setState(() => order.insert(b, order.removeAt(a)));
          widget.settings.putString(SettingsService.categoryOrder, order.join(','));
        },
        itemBuilder: (context, i) {
          final c = cats[order[i]]!;
          return Padding(
            key: ValueKey(c.id), padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              color: [const Color(0xFFFFD02B), const Color(0xFF7AD9CC), const Color(0xFFFF9F68), const Color(0xFFB7A7F8)][i % 4],
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                leading: Icon(icon(c.id), size: 32, color: Colors.black),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                subtitle: Text('${c.units.length} units', style: const TextStyle(color: Colors.black87)),
                trailing: Icon(edit ? Icons.drag_indicator : Icons.arrow_forward, color: Colors.black),
                onTap: edit ? null : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ConverterScreen(categoryId: c.id, settings: widget.settings))),
              ),
            ),
          );
        },
      ),
    );
  }
}
