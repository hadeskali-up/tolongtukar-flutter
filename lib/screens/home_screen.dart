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
    'currency' => Icons.currency_exchange,
    'length' => Icons.straighten,
    'area' => Icons.crop_square,
    'volume' => Icons.water_drop,
    'mass' => Icons.scale,
    'time' => Icons.schedule,
    'speed' => Icons.speed,
    'force' => Icons.bolt,
    'fuel_consumption' => Icons.local_gas_station,
    'pressure' => Icons.compress,
    'energy' => Icons.sunny,
    'power' => Icons.electrical_services,
    'angle' => Icons.architecture,
    'torque' => Icons.sync,
    'digital_data' => Icons.memory,
    'si_prefixes' => Icons.science,
    'density' => Icons.blur_on,
    'temperature' => Icons.thermostat,
    'numeral_systems' => Icons.code,
    'shoe_size' => Icons.directions_walk,
    _ => Icons.calculate,
  };

  void persistOrder() => widget.settings.putString(SettingsService.categoryOrder, order.join(','));

  Future<void> moveCategory(String id) async {
    final current = order.indexOf(id);
    final target = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: order.length,
          itemBuilder: (_, index) => ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(UnitDefinitions.byId(order[index])!.name),
            trailing: index == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, index),
          ),
        ),
      ),
    );
    if (target == null || target == current) return;
    setState(() => order.insert(target, order.removeAt(current)));
    persistOrder();
  }

  @override
  Widget build(BuildContext context) {
    final cats = {for (final c in UnitDefinitions.categories) c.id: c};
    final colors = [const Color(0xFFE4EDF6), const Color(0xFFFDEBD7), const Color(0xFFE0F0EC), const Color(0xFFF1E7F0)];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Image.asset('assets/icon.png', width: 34), const SizedBox(width: 8), const Text('TolongTukar', style: TextStyle(fontWeight: FontWeight.w900))]),
        actions: [
          IconButton(tooltip: edit ? 'Done' : 'Reorder categories', onPressed: () => setState(() => edit = !edit), icon: Icon(edit ? Icons.done : Icons.edit)),
          IconButton(
            tooltip: widget.themeMode == ThemeMode.system ? 'Follow system (tap to override)' : widget.themeMode == ThemeMode.dark ? 'Switch to light' : 'Switch to dark',
            onPressed: () => widget.onThemeChanged(widget.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(widget.themeMode == ThemeMode.system ? Icons.brightness_auto : widget.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          ),
          IconButton(tooltip: 'Settings', onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => SettingsScreen(settings: widget.settings, themeMode: widget.themeMode, onThemeChanged: widget.onThemeChanged))), icon: const Icon(Icons.settings)),
        ],
      ),
      body: GridView.builder(
        key: const Key('home-category-grid'),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1),
        itemCount: order.length,
        itemBuilder: (context, index) {
          final category = cats[order[index]]!;
          return Card(
            color: Theme.of(context).colorScheme.surface,
            child: InkWell(
              onTap: edit ? () => moveCategory(category.id) : () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ConverterScreen(categoryId: category.id, settings: widget.settings))),
              child: Stack(children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: colors[index % colors.length], border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(12)),
                        child: Icon(icon(category.id), size: 27, color: const Color(0xFF1E3552)),
                      ),
                      const SizedBox(height: 8),
                      Text(category.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ),
                if (edit) const Positioned(top: 5, right: 5, child: Icon(Icons.drag_indicator, size: 18)),
              ]),
            ),
          );
        },
      ),
    );
  }
}
