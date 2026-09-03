import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;

    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final isNarrow = w < 480; // for the 3 big-stat cards
      final isTight = w < 640; // for the 2 analysis panels

      final stats = [
        _bigStat(context, c, 'TOTAL INTRUSIONS (30D)', '1,248', '↓ 12% vs prior period', c.text, c.teal, isNarrow),
        _bigStat(context, c, 'DETECTION ACCURACY', '98.4%', '↑ 0.2% improvement', c.amber, c.teal, isNarrow),
        _bigStat(context, c, 'AVG RESPONSE TIME', '1m 14s', '↑ 5s slower', c.text, c.red, isNarrow),
      ];

      final hotspotPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hotspot Analysis', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 14),
          _bar(context, c, 'Sector A-3', 412, 412, isTight),
          _bar(context, c, 'Sector B-1', 289, 412, isTight),
          _bar(context, c, 'Zone North-East', 156, 412, isTight),
          _bar(context, c, 'Gate 4 Alpha', 92, 412, isTight),
        ]),
      );

      final reliabilityPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sensor Reliability', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 14),
          _bar(context, c, 'Thermal Optics', 99.8, 100, isTight, suffix: '%'),
          _bar(context, c, 'ANPR Nodes', 98.5, 100, isTight, suffix: '%'),
          _bar(context, c, 'Facial Rec. (FRS)', 92.1, 100, isTight, suffix: '%'),
        ]),
      );

      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          isNarrow
              ? Column(children: [
                  Row(children: [
                    Expanded(child: stats[0]),
                    const SizedBox(width: 10),
                    Expanded(child: stats[1]),
                  ]),
                  const SizedBox(height: 10),
                  stats[2],
                ])
              : Row(children: [
                  Expanded(child: stats[0]),
                  const SizedBox(width: 14),
                  Expanded(child: stats[1]),
                  const SizedBox(width: 14),
                  Expanded(child: stats[2]),
                ]),
          const SizedBox(height: 16),
          isTight
              ? Column(children: [
                  hotspotPanel,
                  const SizedBox(height: 14),
                  reliabilityPanel,
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: hotspotPanel),
                  const SizedBox(width: 14),
                  Expanded(child: reliabilityPanel),
                ]),
        ]),
      );
    });
  }

  Widget _bigStat(BuildContext context, AppColors c, String label, String value, String delta, Color valueColor, Color deltaColor, bool isNarrow) => Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppFonts.mono(context, size: isNarrow ? 8.5 : 9.5, color: c.textFaint, spacing: isNarrow ? 0.3 : 0.6), maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(value, style: AppFonts.display(context, size: isNarrow ? 21 : 26, w: FontWeight.w700, color: valueColor)),
          const SizedBox(height: 6),
          Text(delta, style: AppFonts.mono(context, size: isNarrow ? 9.5 : 10.5, color: deltaColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _bar(BuildContext context, AppColors c, String label, num value, num max, bool isTight, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        SizedBox(
          width: isTight ? 88 : 110,
          child: Text(label, style: AppFonts.body(context, size: isTight ? 11 : 12, color: c.textDim), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / max),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v, minHeight: 8, backgroundColor: c.surface2,
                valueColor: AlwaysStoppedAnimation(c.teal),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 40, child: Text('$value$suffix', textAlign: TextAlign.right, style: AppFonts.mono(context, size: isTight ? 10.5 : 11.5, color: c.textDim))),
      ]),
    );
  }
}