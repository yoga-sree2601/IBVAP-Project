import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SuspiciousActivityScreen extends StatefulWidget {
  const SuspiciousActivityScreen({super.key});

  @override
  State<SuspiciousActivityScreen> createState() => _SuspiciousActivityScreenState();
}

class _SuspiciousActivityScreenState extends State<SuspiciousActivityScreen> {
  bool _loitering = true;
  bool _crowdFormation = true;
  bool _perimeterBreach = false;

  static const _log = [
    ['Loitering', 'Gate Alpha', 'Elevated', true, '03:05 Z'],
    ['Perimeter Approach — Slow', 'Sector B-1', 'Normal', false, '02:31 Z'],
    ['Unusual Grouping (4+)', 'Checkpoint Alpha', 'Elevated', true, '01:52 Z'],
    ['Object Left Unattended', 'Gate Bravo', 'Normal', false, '01:10 Z'],
    ['Erratic Movement Pattern', 'Sector A-3', 'Normal', false, '00:38 Z'],
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 480;

      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 16 / 7.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(fit: StackFit.expand, children: [
                Image.network(
                  'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=1200&q=70',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.25),
                  colorBlendMode: BlendMode.darken,
                ),
                Positioned(top: 12, left: 12, child: _tag(context, 'BEHAVIOR ANALYSIS // ACTIVE', c.teal)),
                Positioned(top: 12, right: 12, child: _tag(context, 'TRACKED SUBJECTS: 4', c.amber)),
                Positioned(bottom: 12, left: 12, child: _tag(context, 'ANOMALY SCORE: LOW', c.teal)),
                Positioned(bottom: 12, right: 12, child: _tag(context, 'PATTERN CONFIDENCE: 88%', c.teal)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          isNarrow
              ? Column(children: [
                  Row(children: [
                    Expanded(child: _statCard(context, c, 'FLAGGED EVENTS (24H)', '9', c.amber, isNarrow)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(context, c, 'HIGH-RISK EVENTS', '2', c.red, isNarrow)),
                  ]),
                  const SizedBox(height: 10),
                  _statCard(context, c, 'FALSE POSITIVE RATE', '4.1%', c.teal, isNarrow),
                ])
              : Row(children: [
                  Expanded(child: _statCard(context, c, 'FLAGGED EVENTS (24H)', '9', c.amber, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'HIGH-RISK EVENTS', '2', c.red, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'FALSE POSITIVE RATE', '4.1%', c.teal, isNarrow)),
                ]),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isNarrow ? 12 : 16),
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent Activity Log', style: AppFonts.display(context, size: isNarrow ? 13 : 14, w: FontWeight.w600, color: c.text)),
              const SizedBox(height: 4),
              Text('Behavior pattern flags across all monitored sectors.', style: AppFonts.body(context, size: isNarrow ? 11 : 12, color: c.textDim)),
              const SizedBox(height: 14),
              ..._log.map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: isNarrow ? _logRowNarrow(context, c, row) : _logRowWide(context, c, row),
                  )),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isNarrow ? 12 : 16),
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Detection Settings', style: AppFonts.display(context, size: isNarrow ? 13 : 14, w: FontWeight.w600, color: c.text)),
              const SizedBox(height: 8),
              _row(context, c, 'Loitering Detection', 'Flag subjects stationary beyond threshold time', _loitering, (v) => setState(() => _loitering = v)),
              _row(context, c, 'Crowd Formation Alert', 'Flag unusual grouping of 4+ subjects', _crowdFormation, (v) => setState(() => _crowdFormation = v)),
              _row(context, c, 'Perimeter Breach Pattern', 'Flag slow/probing approach toward boundaries', _perimeterBreach, (v) => setState(() => _perimeterBreach = v)),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _tag(BuildContext context, String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(2)),
        child: Text(text, style: AppFonts.mono(context, size: 10, color: color)),
      );

  Widget _statCard(BuildContext context, AppColors c, String label, String value, Color color, bool isNarrow) => Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppFonts.mono(context, size: isNarrow ? 8.5 : 9.5, color: c.textFaint, spacing: isNarrow ? 0.4 : 0.8), maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(value, style: AppFonts.display(context, size: isNarrow ? 19 : 22, w: FontWeight.w700, color: color)),
        ]),
      );

  Widget _row(BuildContext context, AppColors c, String title, String desc, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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

  Widget _logRowWide(BuildContext context, AppColors c, List row) => Row(children: [
        Expanded(flex: 2, child: Text(row[0] as String, style: AppFonts.body(context, size: 12.5, w: FontWeight.w600, color: c.text), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 14),
        Expanded(child: Text(row[1] as String, style: AppFonts.body(context, size: 12.5, color: c.textDim))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: (row[3] as bool) ? c.amber.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(row[2] as String, style: AppFonts.mono(context, size: 9.5, color: (row[3] as bool) ? c.amber : c.teal)),
        ),
        const SizedBox(width: 14),
        Text(row[4] as String, style: AppFonts.mono(context, size: 10, color: c.textFaint)),
      ]);

  Widget _logRowNarrow(BuildContext context, AppColors c, List row) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(row[0] as String, style: AppFonts.body(context, size: 12, w: FontWeight.w600, color: c.text), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: (row[3] as bool) ? c.amber.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(row[2] as String, style: AppFonts.mono(context, size: 9, color: (row[3] as bool) ? c.amber : c.teal), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(child: Text(row[1] as String, style: AppFonts.body(context, size: 11.5, color: c.textDim), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Text(row[4] as String, style: AppFonts.mono(context, size: 9.5, color: c.textFaint)),
          ]),
        ],
      );
}
