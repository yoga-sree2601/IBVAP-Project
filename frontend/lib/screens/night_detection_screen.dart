import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class NightDetectionScreen extends StatelessWidget {
  const NightDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 16 / 7.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(fit: StackFit.expand, children: [
              Image.network('https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200&q=70', fit: BoxFit.cover, color: Colors.black.withOpacity(0.25), colorBlendMode: BlendMode.darken),
              Positioned(top: 12, left: 12, child: _tag(context, 'NIGHT MODE // AUTO', c.teal, c)),
              Positioned(top: 12, right: 12, child: _tag(context, 'IR ILLUMINATION: ON', c.amber, c)),
              Positioned(bottom: 12, left: 12, child: _tag(context, 'TARGETS ACQUIRED: 3', c.teal, c)),
              Positioned(bottom: 12, right: 12, child: _tag(context, 'TEMP: -15°C', c.teal, c)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _statCard(context, c, 'ACTIVE NIGHT FEEDS', '4 / 5', c.teal)),
          const SizedBox(width: 14),
          Expanded(child: _statCard(context, c, 'MOVEMENT EVENTS (12H)', '27', c.amber)),
          const SizedBox(width: 14),
          Expanded(child: _statCard(context, c, 'LOW-LIGHT ACCURACY', '94.2%', c.text)),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Night Detection Settings', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
            const SizedBox(height: 8),
            _row(context, c, 'Auto Thermal Switch', 'Switch feeds to thermal optics after dusk', true),
            _row(context, c, 'Infrared Illuminators', 'Trigger IR floodlights on movement', true),
            _row(context, c, 'Motion-only Recording', 'Store footage only when movement detected', false),
          ]),
        ),
      ]),
    );
  }

  Widget _tag(BuildContext context, String text, Color color, AppColors c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: Border.all(color: color.withOpacity(0.5)), borderRadius: BorderRadius.circular(2)),
        child: Text(text, style: AppFonts.mono(context, size: 10, color: color)),
      );

  Widget _statCard(BuildContext context, AppColors c, String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppFonts.mono(context, size: 9.5, color: c.textFaint, spacing: 0.8)),
          const SizedBox(height: 8),
          Text(value, style: AppFonts.display(context, size: 22, w: FontWeight.w700, color: color)),
        ]),
      );

  Widget _row(BuildContext context, AppColors c, String title, String desc, bool value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppFonts.body(context, size: 13, w: FontWeight.w500, color: c.text)),
              Text(desc, style: AppFonts.body(context, size: 11.5, color: c.textDim)),
            ]),
          ),
          Switch(value: value, activeColor: c.teal, onChanged: (_) {}),
        ]),
      );
}
