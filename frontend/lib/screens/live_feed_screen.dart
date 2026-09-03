import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/camera_provider.dart';
import '../theme/app_theme.dart';

class LiveFeedScreen extends StatefulWidget {
  const LiveFeedScreen({super.key});
  @override
  State<LiveFeedScreen> createState() => _LiveFeedScreenState();
}

class _LiveFeedScreenState extends State<LiveFeedScreen> {
  String? _activeId;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final cams = context.watch<CameraProvider>().cameras;
    if (cams.isEmpty) return Center(child: Text('No cameras registered.', style: AppFonts.body(context, color: c.textDim)));
    final active = cams.firstWhere((x) => x.id == _activeId, orElse: () => cams.first);

    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 980;
      final mainFeed = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(fit: StackFit.expand, children: [
                Image.network(active.feedImage, fit: BoxFit.cover),
                Container(color: Colors.black.withOpacity(0.08)),
                Positioned(top: 12, left: 12, child: _hudTag(context, 'THERMAL // ${active.name.toUpperCase()}', c)),
                Positioned(bottom: 12, left: 12, child: _hudTag(context, "COORDS: 42°17'N 101°42'E", c)),
                Positioned(bottom: 12, right: 12, child: _hudTag(context, 'TEMP: -15°C · WIND 12KM/H NW', c)),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: c.red.withOpacity(0.16), border: Border.all(color: c.red), borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _RecDot(color: c.red),
                      const SizedBox(width: 6),
                      Text('RECORDING', style: AppFonts.mono(context, size: 10, color: c.red)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cams.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cam = cams[i];
                final isActive = cam.id == active.id;
                return GestureDetector(
                  onTap: () => setState(() => _activeId = cam.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isActive ? c.amber : c.border, width: isActive ? 1.6 : 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.network(cam.feedImage, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.8)),
                        Positioned(
                          bottom: 3, left: 5,
                          child: Text(cam.name, style: AppFonts.mono(context, size: 8.5, color: Colors.white)),
                        ),
                        if (cam.online)
                          Positioned(top: 5, right: 5, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c.teal, shape: BoxShape.circle))),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

      final sidePanel = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelCard(context, c, 'Feed Status', GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.1,
            children: [
              _stat(context, c, 'STATUS', active.online ? 'ONLINE' : 'OFFLINE', active.online ? c.teal : c.red),
              _stat(context, c, 'ALERT LEVEL', 'NORMAL', c.teal),
              _stat(context, c, 'DETECTIONS', '3', c.amber),
              _stat(context, c, 'UPLINK', '98.4 Mbps', c.text),
            ],
          )),
          const SizedBox(height: 14),
          _panelCard(context, c, 'Active Detections', Column(children: [
            _detectRow(context, c, 'Person — 95% conf.', 'HUMAN', c.teal),
            _detectRow(context, c, 'Person — 89% conf.', 'HUMAN', c.teal),
            _detectRow(context, c, 'Vehicle — 99% conf.', 'VEHICLE', c.amber),
          ])),
        ],
      );

      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: mainFeed),
          const SizedBox(width: 16),
          SizedBox(width: 300, child: sidePanel),
        ]);
      }
      return SingleChildScrollView(child: Column(children: [mainFeed, const SizedBox(height: 16), sidePanel]));
    });
  }

  Widget _hudTag(BuildContext context, String text, AppColors c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border.all(color: c.teal.withOpacity(0.4)), borderRadius: BorderRadius.circular(2)),
        child: Text(text, style: AppFonts.mono(context, size: 10, color: c.teal)),
      );

  Widget _panelCard(BuildContext context, AppColors c, String title, Widget child) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 12),
          child,
        ]),
      );

  Widget _stat(BuildContext context, AppColors c, String label, String value, Color valueColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: c.surface2, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(3)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label, style: AppFonts.mono(context, size: 8.5, color: c.textFaint, spacing: 0.8)),
          const SizedBox(height: 4),
          Text(value, style: AppFonts.display(context, size: 15, w: FontWeight.w600, color: valueColor)),
        ]),
      );

  Widget _detectRow(BuildContext context, AppColors c, String text, String tag, Color tagColor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(text, style: AppFonts.body(context, size: 12.5, color: c.text)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.14), borderRadius: BorderRadius.circular(10)),
            child: Text(tag, style: AppFonts.mono(context, size: 9, color: tagColor)),
          ),
        ]),
      );
}

class _RecDot extends StatefulWidget {
  final Color color;
  const _RecDot({required this.color});
  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.25).animate(_ctrl),
      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
    );
  }
}
