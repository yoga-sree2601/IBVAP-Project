import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  String _mode = 'terrain'; // terrain | satellite | thermal
  late final AnimationController _pulse;

  static const markers = [
    [0.135, 0.20, 'BOP-04'],
    [0.43, 0.44, 'DRONE UAV-1'],
    [0.30, 0.62, 'BOP-12'],
    [0.38, 0.72, 'GATE-B'],
  ];

  static const clusters = [
    [0.42, 0.53, 'SEC A-3 · 3 TGTS'],
    [0.17, 0.86, 'CHK-ALPHA · VEH'],
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color _accent(AppColors c) => _mode == 'thermal' ? const Color(0xFFFF9142) : c.teal;

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final accent = _accent(c);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Sector Map', style: AppFonts.display(context, size: 16, w: FontWeight.w600, color: c.text)),
      Text('Live node positions, terrain overlay and active perimeter clusters.',
          style: AppFonts.body(context, size: 12, color: c.textDim)),
      const SizedBox(height: 16),
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: c.bgElev, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(builder: (context, cons) {
            final w = cons.maxWidth, h = cons.maxHeight;
            return Stack(children: [
              // base layer: satellite photo OR hillshade, depending on mode
              if (_mode == 'satellite')
                Positioned.fill(
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1519904981063-b0cf448d479e?w=1200&q=68',
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.35),
                      colorBlendMode: BlendMode.darken,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.black.withOpacity(0.15), Colors.black.withOpacity(0.55)]),
                      ),
                    ),
                  ]),
                )
              else
                Positioned.fill(child: CustomPaint(painter: _HillshadePainter(c, _mode))),

              // grid overlay
              Positioned.fill(child: CustomPaint(painter: _GridPainter(accent, dim: _mode == 'satellite'))),

              // terrain contour lines (dimmed under satellite photo, tinted orange in thermal)
              Positioned.fill(
                child: Opacity(
                  opacity: _mode == 'satellite' ? 0.4 : 1.0,
                  child: CustomPaint(painter: _TerrainPainter(accent)),
                ),
              ),

              // thermal heat overlay + scale bar
              if (_mode == 'thermal') Positioned.fill(child: CustomPaint(painter: _ThermalPainter())),
              if (_mode == 'thermal')
                Positioned(bottom: 44, right: 14, child: _thermalScale(context)),

              // toolbar
              Positioned(top: 14, left: 14, child: _toolbar(context, c)),

              // reticle
              Center(child: _reticle(accent)),

              // camera / node markers
              ...markers.map((m) {
                final dx = m[0] as double, dy = m[1] as double, label = m[2] as String;
                return Positioned(
                  left: w * dx - 6, top: h * dy - 6,
                  child: _NodeMarker(color: accent, label: label, pulse: _pulse, c: c),
                );
              }),

              // intrusion clusters (thermal-style red blobs)
              ...clusters.map((cl) {
                final dx = cl[0] as double, dy = cl[1] as double, label = cl[2] as String;
                return Positioned(
                  left: w * dx - 13, top: h * dy - 11,
                  child: _ClusterMarker(label: label, pulse: _pulse, c: c),
                );
              }),

              // legend
              Positioned(top: 14, right: 14, child: _legend(context, c)),

              // bottom info bar
              Positioned(left: 0, right: 0, bottom: 0, child: _infoBar(context, c)),
            ]);
          }),
        ),
      ),
    ]);
  }

  Widget _toolbar(BuildContext context, AppColors c) {
    Widget btn(String key, String label) {
      final active = _mode == key;
      return GestureDetector(
        onTap: () => setState(() => _mode = key),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: active ? c.amber : c.surface,
            border: Border.all(color: active ? c.amber : c.border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(label,
              style: AppFonts.mono(context, size: 10, color: active ? const Color(0xFF14100A) : c.textDim)),
        ),
      );
    }

    return Row(children: [btn('terrain', 'TERRAIN'), btn('satellite', 'SATELLITE'), btn('thermal', 'THERMAL')]);
  }

  Widget _reticle(Color accent) {
    return SizedBox(
      width: 64, height: 64,
      child: Stack(alignment: Alignment.center, children: [
        Container(decoration: BoxDecoration(border: Border.all(color: accent.withOpacity(0.85), width: 1.4))),
        Container(width: 92, height: 1, color: accent.withOpacity(0.5)),
        Container(width: 1, height: 92, color: accent.withOpacity(0.5)),
      ]),
    );
  }

  Widget _legend(BuildContext context, AppColors c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(4)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _legendRow(context, c.teal, 'Node online', c),
          const SizedBox(height: 6),
          _legendRow(context, c.red, 'Intrusion cluster', c),
        ]),
      );

  Widget _legendRow(BuildContext context, Color color, String label, AppColors c) => Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(label, style: AppFonts.body(context, size: 11, color: c.textDim)),
      ]);

  Widget _infoBar(BuildContext context, AppColors c) {
    Widget cell(String label, String value, {Color? valueColor}) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(border: Border(right: BorderSide(color: c.borderSoft))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: AppFonts.mono(context, size: 9, color: c.textFaint, spacing: 1)),
              const SizedBox(height: 2),
              Text(value, style: AppFonts.mono(context, size: 13, w: FontWeight.w600, color: valueColor ?? c.teal)),
            ]),
          ),
        );

    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), border: Border(top: BorderSide(color: c.border))),
      child: Row(children: [
        cell("GPS COORD", "42°17'N 101°42'E"),
        cell("HEADING", "045° NE"),
        cell("ACTIVE SECTOR", "A-3 NORTH", valueColor: c.amber),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("ZOOM", style: AppFonts.mono(context, size: 9, color: c.textFaint, spacing: 1)),
              const SizedBox(height: 2),
              Text("×4.2", style: AppFonts.mono(context, size: 13, w: FontWeight.w600, color: c.teal)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _thermalScale(BuildContext context) => Container(
        width: 14, height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6C8), Color(0xFFFFB454), Color(0xFFFF6A2E), Color(0xFFB3245C), Color(0xFF3A1560)],
          ),
        ),
        child: Stack(children: [
          Positioned(top: 2, left: 2, child: Text('+45°', style: AppFonts.mono(context, size: 7, color: Colors.white))),
          Positioned(bottom: 2, left: 2, child: Text('-10°', style: AppFonts.mono(context, size: 7, color: Colors.white))),
        ]),
      );
}

class _NodeMarker extends StatelessWidget {
  final Color color;
  final String label;
  final Animation<double> pulse;
  final AppColors c;
  const _NodeMarker({required this.color, required this.label, required this.pulse, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 24, height: 24,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (_, __) {
            final t = pulse.value;
            return Stack(alignment: Alignment.center, children: [
              Opacity(
                opacity: ((1 - t).clamp(0, 1) * 0.6).toDouble(),
                child: Transform.scale(
                  scale: 0.5 + t * 1.4,
                  child: Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color))),
                ),
              ),
              Container(
                width: 11, height: 11,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)]),
              ),
            ]);
          },
        ),
      ),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: c.bg, border: Border.all(color: c.borderSoft), borderRadius: BorderRadius.circular(2)),
        child: Text(label, style: AppFonts.mono(context, size: 9, color: c.textDim)),
      ),
    ]);
  }
}

class _ClusterMarker extends StatelessWidget {
  final String label;
  final Animation<double> pulse;
  final AppColors c;
  const _ClusterMarker({required this.label, required this.pulse, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 26, height: 22,
        child: AnimatedBuilder(
          animation: pulse,
          builder: (_, __) {
            double flick(double phase) => 0.45 + 0.4 * (0.5 + 0.5 * math.sin((pulse.value + phase) * 2 * math.pi));
            return Stack(children: [
              Positioned(left: 0, top: 6, child: _blob(14, flick(0.0))),
              Positioned(left: 9, top: 0, child: _blob(11, flick(0.33))),
              Positioned(left: 14, top: 8, child: _blob(10, flick(0.66))),
            ]);
          },
        ),
      ),
      const SizedBox(height: 3),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(color: c.bg, border: Border.all(color: c.borderSoft), borderRadius: BorderRadius.circular(2)),
        child: Text(label, style: AppFonts.mono(context, size: 8.5, color: c.red)),
      ),
    ]);
  }

  Widget _blob(double size, double opacity) => Opacity(
        opacity: opacity,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [const Color(0xFFE85B4F), const Color(0xFFE85B4F).withOpacity(0.1)]),
          ),
        ),
      );
}

/// Soft green hillshade blobs that give the terrain mode visual depth —
/// dimmed out in thermal mode (thermal overlay takes over the mood).
class _HillshadePainter extends CustomPainter {
  final AppColors c;
  final String mode;
  _HillshadePainter(this.c, this.mode);

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == 'thermal') return;
    void blob(Offset center, double rx, double ry, Color color) {
      final rect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
      final paint = Paint()..shader = RadialGradient(colors: [color, color.withOpacity(0)]).createShader(rect);
      canvas.drawOval(rect, paint);
    }

    blob(Offset(size.width * 0.14, size.height * 0.22), 130, 80, c.teal.withOpacity(0.16));
    blob(Offset(size.width * 0.82, size.height * 0.18), 160, 100, c.teal.withOpacity(0.10));
    blob(Offset(size.width * 0.70, size.height * 0.78), 190, 110, c.teal.withOpacity(0.14));
    blob(Offset(size.width * 0.18, size.height * 0.82), 120, 80, c.teal.withOpacity(0.10));
    blob(Offset(size.width * 0.5, size.height * 0.5), 260, 150, Colors.black.withOpacity(0.18));
  }

  @override
  bool shouldRepaint(covariant _HillshadePainter old) => old.mode != mode;
}

class _GridPainter extends CustomPainter {
  final Color accent;
  final bool dim;
  _GridPainter(this.accent, {this.dim = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = accent.withOpacity(dim ? 0.02 : 0.05)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.accent != accent || old.dim != dim;
}

/// Winding contour/road lines + elevation rings — mirrors the SVG paths in
/// the HTML prototype's terrain mode.
class _TerrainPainter extends CustomPainter {
  final Color accent;
  _TerrainPainter(this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 800, sy = size.height / 520;
    Offset p(double x, double y) => Offset(x * sx, y * sy);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accent.withOpacity(0.28)
      ..strokeWidth = 2;

    final path1 = Path()
      ..moveTo(p(-10, 120).dx, p(-10, 120).dy)
      ..cubicTo(p(120, 90).dx, p(120, 90).dy, p(180, 180).dx, p(180, 180).dy, p(260, 160).dx, p(260, 160).dy)
      ..cubicTo(p(340, 140).dx, p(340, 140).dy, p(400, 90).dx, p(400, 90).dy, p(470, 120).dx, p(470, 120).dy)
      ..cubicTo(p(540, 150).dx, p(540, 150).dy, p(620, 210).dx, p(620, 210).dy, p(760, 170).dx, p(760, 170).dy);
    canvas.drawPath(path1, linePaint);

    final dashPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accent.withOpacity(0.22)
      ..strokeWidth = 1.6;
    final path2 = Path()
      ..moveTo(p(40, 480).dx, p(40, 480).dy)
      ..cubicTo(p(140, 420).dx, p(140, 420).dy, p(160, 340).dx, p(160, 340).dy, p(260, 330).dx, p(260, 330).dy)
      ..cubicTo(p(340, 320).dx, p(340, 320).dy, p(380, 250).dx, p(380, 250).dy, p(430, 260).dx, p(430, 260).dy)
      ..cubicTo(p(480, 270).dx, p(480, 270).dy, p(560, 320).dx, p(560, 320).dy, p(640, 260).dx, p(640, 260).dy)
      ..cubicTo(p(700, 220).dx, p(700, 220).dy, p(720, 190).dx, p(720, 190).dy, p(790, 205).dx, p(790, 205).dy);
    _drawDashedPath(canvas, path2, dashPaint1, dashLength: 1.5, gapLength: 7);

    final thinPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = accent.withOpacity(0.14)
      ..strokeWidth = 1.2;
    final path3 = Path()
      ..moveTo(p(300, 20).dx, p(300, 20).dy)
      ..cubicTo(p(320, 120).dx, p(320, 120).dy, p(260, 190).dx, p(260, 190).dy, p(300, 260).dx, p(300, 260).dy)
      ..cubicTo(p(340, 330).dx, p(340, 330).dy, p(400, 360).dx, p(400, 360).dy, p(380, 500).dx, p(380, 500).dy);
    canvas.drawPath(path3, thinPaint);

    // elevation contour rings around the two hill centers
    void rings(Offset center, List<double> radiiX, List<double> opacities) {
      for (var i = 0; i < radiiX.length; i++) {
        final rx = radiiX[i] * sx, ry = radiiX[i] * 0.55 * sy;
        canvas.drawOval(
          Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
          Paint()..style = PaintingStyle.stroke..color = accent.withOpacity(opacities[i])..strokeWidth = 1,
        );
      }
    }

    rings(p(150, 100), [60, 90, 120], [0.16, 0.1, 0.06]);
    rings(p(600, 410), [90, 130], [0.14, 0.09]);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, {required double dashLength, required double gapLength}) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        final next = math.min(distance + len, metric.length);
        if (draw) canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TerrainPainter old) => old.accent != accent;
}

/// Multi-stop warm heat blobs over a cool base — thermal mode.
class _ThermalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [const Color(0xFF140A3C).withOpacity(0.5), const Color(0xFF14284F).withOpacity(0.3), Colors.transparent],
        ).createShader(Offset.zero & size),
    );

    void hotspot(Offset center, double r, List<Color> colors) {
      final rect = Rect.fromCircle(center: center, radius: r);
      canvas.drawCircle(center, r, Paint()..shader = RadialGradient(colors: colors).createShader(rect));
    }

    hotspot(Offset(size.width * 0.42, size.height * 0.53), size.width * 0.16,
        [const Color(0xFFFFC83C).withOpacity(0.55), const Color(0xFFFF6E1E).withOpacity(0.25), Colors.transparent]);
    hotspot(Offset(size.width * 0.17, size.height * 0.86), size.width * 0.13,
        [const Color(0xFFFFE678).withOpacity(0.4), const Color(0xFFFF5A14).withOpacity(0.22), Colors.transparent]);
    hotspot(Offset(size.width * 0.55, size.height * 0.2), size.width * 0.12,
        [const Color(0xFFFFFFB4).withOpacity(0.15), Colors.transparent, Colors.transparent]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}