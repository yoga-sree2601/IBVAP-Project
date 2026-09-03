import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool anpr = true, night = true, sync = true, field = false;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 640;

      final platformPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Platform', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 8),
          _row(context, c, 'ANPR Matching', 'Cross-check plates against watchlist DB', anpr, (v) => setState(() => anpr = v)),
          _row(context, c, 'Night-time Mode', 'Auto-switch feeds to thermal after dusk', night, (v) => setState(() => night = v)),
          _row(context, c, 'Command Center Sync', 'Push alerts to regional C2 systems', sync, (v) => setState(() => sync = v)),
          _row(context, c, 'Field Unit Notification', 'SMS nearest patrol on critical events', field, (v) => setState(() => field = v)),
        ]),
      );

      final systemPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('System', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 12),
          _infoRow(context, c, 'Uptime', '99.8%'),
          _infoRow(context, c, 'Latency', '24ms'),
          _infoRow(context, c, 'Active Nodes', '12'),
          _infoRow(context, c, 'Critical Alerts', '0'),
        ]),
      );

      return SingleChildScrollView(
        child: isNarrow
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                platformPanel,
                const SizedBox(height: 16),
                systemPanel,
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: platformPanel),
                const SizedBox(width: 16),
                Expanded(child: systemPanel),
              ]),
      );
    });
  }

  Widget _row(BuildContext context, AppColors c, String title, String desc, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppFonts.body(context, size: 13, w: FontWeight.w500, color: c.text)),
              Text(desc, style: AppFonts.body(context, size: 11.5, color: c.textDim)),
            ]),
          ),
          Switch(value: value, activeColor: c.teal, onChanged: onChanged),
        ]),
      );

  Widget _infoRow(BuildContext context, AppColors c, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: AppFonts.body(context, size: 13, color: c.textDim)),
          Text(value, style: AppFonts.mono(context, size: 13, w: FontWeight.w600, color: c.text)),
        ]),
      );
}