import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AnprScreen extends StatelessWidget {
  const AnprScreen({super.key});

  static const _log = [
    ['KA-05-MX-4471', 'Checkpoint Alpha', 'Watchlist Match', true, '03:41 Z'],
    ['DL-3C-AB-9021', 'Gate Bravo', 'Cleared', false, '02:58 Z'],
    ['RJ-14-GT-2210', 'Checkpoint Alpha', 'Cleared', false, '02:20 Z'],
    ['PB-11-QW-7734', 'Sector B-1 Road', 'No Match Found', true, '01:47 Z'],
    ['HR-26-JK-1190', 'Gate Bravo', 'Cleared', false, '01:02 Z'],
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;

    return LayoutBuilder(builder: (context, constraints) {
      // Below this width, 3 equal-width cards in a Row get too thin and the
      // mono label text wraps letter-by-letter. Stack them instead.
      final isNarrow = constraints.maxWidth < 480;

      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          isNarrow
              ? Column(children: [
                  Row(children: [
                    Expanded(child: _statCard(context, c, 'PLATES SCANNED (24H)', '842', c.text, isNarrow)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(context, c, 'WATCHLIST MATCHES', '2', c.red, isNarrow)),
                  ]),
                  const SizedBox(height: 10),
                  _statCard(context, c, 'OCR CONFIDENCE', '96.7%', c.teal, isNarrow),
                ])
              : Row(children: [
                  Expanded(child: _statCard(context, c, 'PLATES SCANNED (24H)', '842', c.text, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'WATCHLIST MATCHES', '2', c.red, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'OCR CONFIDENCE', '96.7%', c.teal, isNarrow)),
                ]),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.all(isNarrow ? 12 : 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent Plate Reads', style: AppFonts.display(context, size: isNarrow ? 13 : 14, w: FontWeight.w600, color: c.text)),
              const SizedBox(height: 4),
              Text('Automatic Number Plate Recognition across all checkpoint feeds.',
                  style: AppFonts.body(context, size: isNarrow ? 11 : 12, color: c.textDim)),
              const SizedBox(height: 14),
              ..._log.map((row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: isNarrow ? _logRowNarrow(context, c, row) : _logRowWide(context, c, row),
                  )),
            ]),
          ),
        ]),
      );
    });
  }

  // Original single-line layout for wider screens.
  Widget _logRowWide(BuildContext context, AppColors c, List row) => Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: c.surface2, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(3)),
          child: Text(row[0] as String, style: AppFonts.mono(context, size: 12, w: FontWeight.w600, color: c.text)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(row[1] as String, style: AppFonts.body(context, size: 12.5, color: c.textDim))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: (row[3] as bool) ? c.red.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(row[2] as String, style: AppFonts.mono(context, size: 9.5, color: (row[3] as bool) ? c.red : c.teal)),
        ),
        const SizedBox(width: 14),
        Text(row[4] as String, style: AppFonts.mono(context, size: 10, color: c.textFaint)),
      ]);

  // Two-line layout for narrow screens: plate + status badge on top,
  // location + time below. Avoids cramming 4 items into one thin row.
  Widget _logRowNarrow(BuildContext context, AppColors c, List row) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: c.surface2, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(3)),
              child: Text(row[0] as String, style: AppFonts.mono(context, size: 11, w: FontWeight.w600, color: c.text)),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: (row[3] as bool) ? c.red.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(row[2] as String,
                    style: AppFonts.mono(context, size: 9, color: (row[3] as bool) ? c.red : c.teal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
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

  Widget _statCard(BuildContext context, AppColors c, String label, String value, Color color, bool isNarrow) => Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: AppFonts.mono(context, size: isNarrow ? 9 : 9.5, color: c.textFaint, spacing: isNarrow ? 0.4 : 0.8),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isNarrow ? 6 : 8),
          Text(value, style: AppFonts.display(context, size: isNarrow ? 20 : 24, w: FontWeight.w700, color: color)),
        ]),
      );
}