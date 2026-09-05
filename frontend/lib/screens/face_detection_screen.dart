import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  bool _watchlistMatching = true;
  bool _anonymizeNonMatches = false;
  bool _storeThumbnails = true;

  static const _log = [
    ['Unidentified Subject', 'Gate Bravo', 'No Match', false, '03:12 Z'],
    ['Watchlist #WL-042', 'Checkpoint Alpha', 'Watchlist Match', true, '02:47 Z'],
    ['Operator 4471', 'Sector A-3', 'Cleared (Staff)', false, '01:58 Z'],
    ['Unidentified Subject', 'Gate Bravo', 'No Match', false, '01:20 Z'],
    ['Watchlist #WL-017', 'Sector B-1', 'Watchlist Match', true, '00:44 Z'],
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
                  'https://images.unsplash.com/photo-1552374196-c4e7ffc6e126?w=1200&q=70',
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.25),
                  colorBlendMode: BlendMode.darken,
                ),
                Positioned(top: 12, left: 12, child: _tag(context, 'FACIAL RECOGNITION // ACTIVE', c.teal)),
                Positioned(top: 12, right: 12, child: _tag(context, 'FACES IN FRAME: 2', c.amber)),
                Positioned(bottom: 12, left: 12, child: _tag(context, 'MATCH THRESHOLD: 82%', c.teal)),
                Positioned(bottom: 12, right: 12, child: _tag(context, 'SCAN RATE: 12 FPS', c.teal)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          isNarrow
              ? Column(children: [
                  Row(children: [
                    Expanded(child: _statCard(context, c, 'FACES SCANNED (24H)', '1,204', c.text, isNarrow)),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard(context, c, 'WATCHLIST MATCHES', '1', c.red, isNarrow)),
                  ]),
                  const SizedBox(height: 10),
                  _statCard(context, c, 'AVG MATCH CONFIDENCE', '91.3%', c.teal, isNarrow),
                ])
              : Row(children: [
                  Expanded(child: _statCard(context, c, 'FACES SCANNED (24H)', '1,204', c.text, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'WATCHLIST MATCHES', '1', c.red, isNarrow)),
                  const SizedBox(width: 14),
                  Expanded(child: _statCard(context, c, 'AVG MATCH CONFIDENCE', '91.3%', c.teal, isNarrow)),
                ]),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(isNarrow ? 12 : 16),
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent Face Matches', style: AppFonts.display(context, size: isNarrow ? 13 : 14, w: FontWeight.w600, color: c.text)),
              const SizedBox(height: 4),
              Text('Facial recognition results across all checkpoint feeds.', style: AppFonts.body(context, size: isNarrow ? 11 : 12, color: c.textDim)),
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
              Text('Face Detection Settings', style: AppFonts.display(context, size: isNarrow ? 13 : 14, w: FontWeight.w600, color: c.text)),
              const SizedBox(height: 8),
              _row(context, c, 'Watchlist Matching', 'Compare detected faces against watchlist DB', _watchlistMatching, (v) => setState(() => _watchlistMatching = v)),
              _row(context, c, 'Anonymize Non-Matches', 'Blur faces with no watchlist match in logs', _anonymizeNonMatches, (v) => setState(() => _anonymizeNonMatches = v)),
              _row(context, c, 'Store Match Thumbnails', 'Save a cropped image with each match event', _storeThumbnails, (v) => setState(() => _storeThumbnails = v)),
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
          decoration: BoxDecoration(color: (row[3] as bool) ? c.red.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(row[2] as String, style: AppFonts.mono(context, size: 9.5, color: (row[3] as bool) ? c.red : c.teal)),
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
                decoration: BoxDecoration(color: (row[3] as bool) ? c.red.withOpacity(0.14) : c.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(row[2] as String, style: AppFonts.mono(context, size: 9, color: (row[3] as bool) ? c.red : c.teal), maxLines: 1, overflow: TextOverflow.ellipsis),
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
