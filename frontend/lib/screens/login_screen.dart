import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/camera_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/fence_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;
  bool _loading = false;
  String _btnLabel = 'Authenticate';
  String? _error;
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _idCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() { _loading = true; _btnLabel = 'Verifying...'; _error = null; });
    try {
      final api = context.read<ApiService>();
      await api.login(_idCtrl.text.trim(), _passCtrl.text.trim());
      if (!mounted) return;
      setState(() => _btnLabel = 'Connecting to backend...');
      await Future.wait([
        context.read<CameraProvider>().fetchAll(),
        context.read<AlertProvider>().fetchAll(),
        context.read<FenceProvider>().fetchAll(),
      ]);
      if (!mounted) return;
      setState(() => _btnLabel = 'Access Granted');
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: DashboardShell(operatorId: _idCtrl.text.trim())),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _btnLabel = 'Authenticate';
        _error = 'Could not reach the backend at ${ApiService().baseUrl}.\nMake sure it is running and reachable.';
      });
    }
  }

  void _showForgotPasscode() {
    final c = context.read<ThemeProvider>().colors;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: Text('Passcode Recovery', style: AppFonts.display(context, size: 16, w: FontWeight.w600, color: c.text)),
        content: Text(
          'For security reasons, passcode reset must go through your system administrator or field commander. Please contact them directly to regain access.',
          style: AppFonts.body(context, size: 13, color: c.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: AppFonts.body(context, size: 13, w: FontWeight.w600, color: c.amber)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 700, height: 700,
                child: AnimatedBuilder(
                  animation: _sweepController,
                  builder: (_, __) => CustomPaint(
                    painter: _RadarPainter(_sweepController.value, c),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: 380,
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 26),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      _ShieldIcon(c: c, size: 32),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('IBVAP', style: AppFonts.display(context, size: 18, w: FontWeight.w700, color: c.text)),
                        Text('BORDER VIDEO ANALYTICS', style: AppFonts.mono(context, size: 9, color: c.textDim, spacing: 1.4)),
                      ]),
                    ]),
                    const SizedBox(height: 26),
                    Text('Secure Access', style: AppFonts.display(context, size: 19, w: FontWeight.w600, color: c.text)),
                    const SizedBox(height: 4),
                    Text('Authenticate to reach the command console.', style: AppFonts.body(context, size: 12.5, color: c.textDim)),
                    const SizedBox(height: 24),
                    Text('OPERATOR ID', style: AppFonts.mono(context, size: 10, color: c.textDim, spacing: 1)),
                    const SizedBox(height: 6),
                    TextField(controller: _idCtrl, style: AppFonts.body(context, color: c.text), decoration: const InputDecoration(hintText: 'e.g. OP-4471')),
                    const SizedBox(height: 14),
                    Text('PASSCODE', style: AppFonts.mono(context, size: 10, color: c.textDim, spacing: 1)),
                    const SizedBox(height: 6),
                    TextField(controller: _passCtrl, obscureText: true, style: AppFonts.body(context, color: c.text)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _showForgotPasscode,
                        child: Text('Forgot passcode?', style: AppFonts.body(context, size: 11.5, color: c.teal)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.amber,
                          foregroundColor: const Color(0xFF14100A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                                const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14100A))),
                                const SizedBox(width: 10),
                                Text(_btnLabel, style: AppFonts.display(context, size: 13.5, w: FontWeight.w600, color: const Color(0xFF14100A))),
                              ])
                            : Text(_btnLabel, style: AppFonts.display(context, size: 13.5, w: FontWeight.w600, color: const Color(0xFF14100A))),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: c.red.withOpacity(0.1), border: Border.all(color: c.red.withOpacity(0.4)), borderRadius: BorderRadius.circular(4)),
                        child: Text(_error!, style: AppFonts.body(context, size: 11.5, color: c.red)),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(height: 1, color: c.borderSoft),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: c.teal, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('SYSTEM NOMINAL', style: AppFonts.mono(context, size: 9, color: c.textFaint)),
                      ]),
                      Text('NODE 12 / SEC-3', style: AppFonts.mono(context, size: 9, color: c.textFaint)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldIcon extends StatelessWidget {
  final AppColors c;
  final double size;
  const _ShieldIcon({required this.c, required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _ShieldPainter(c)),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  final AppColors c;
  _ShieldPainter(this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.95, size.height * 0.14)
      ..lineTo(size.width * 0.95, size.height * 0.5)
      ..cubicTo(size.width * 0.95, size.height * 0.78, size.width * 0.75, size.height * 0.95, size.width * 0.5, size.height)
      ..cubicTo(size.width * 0.25, size.height * 0.95, size.width * 0.05, size.height * 0.78, size.width * 0.05, size.height * 0.5)
      ..lineTo(size.width * 0.05, size.height * 0.14)
      ..close();
    canvas.drawPath(p, Paint()..color = c.amber.withOpacity(0.08));
    canvas.drawPath(p, Paint()..color = c.amber..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), size.width * 0.18, Paint()..color = c.teal..style = PaintingStyle.stroke..strokeWidth = 1.6);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), size.width * 0.05, Paint()..color = c.teal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarPainter extends CustomPainter {
  final double t;
  final AppColors c;
  _RadarPainter(this.t, this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.width / 2;
    final ringPaint = Paint()
      ..color = c.teal.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final f in [1.0, 0.72, 0.44, 0.2]) {
      canvas.drawCircle(center, maxR * f, ringPaint);
    }
    final sweepAngle = t * 6.2832;
    final rect = Rect.fromCircle(center: center, radius: maxR * 0.72);
    final gradient = SweepGradient(
      startAngle: sweepAngle,
      endAngle: sweepAngle + 1.1,
      colors: [c.teal.withOpacity(0.28), c.teal.withOpacity(0.0)],
    );
    canvas.drawArc(rect, sweepAngle, 1.1, true, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => true;
}

