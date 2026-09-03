import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/fence_provider.dart';
import '../models/fence.dart';
import '../theme/app_theme.dart';

class FenceScreen extends StatelessWidget {
  const FenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final fp = context.watch<FenceProvider>();
    final labels = {1: 'LOW', 2: 'MEDIUM', 3: 'HIGH'};

    if (fp.loading && fp.zones.isEmpty) {
      return Center(child: CircularProgressIndicator(color: c.amber));
    }
    if (fp.error != null && fp.zones.isEmpty) {
      return _errorState(context, c, fp);
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Two side-by-side panels need real room for the slider + toggle rows
      // and the zone list. Below this width, stack them instead.
      final isNarrow = constraints.maxWidth < 640;

      final settingsPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Intrusion Settings', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('FENCE SENSITIVITY', style: AppFonts.mono(context, size: 10, color: c.textDim, spacing: 0.8)),
            Text(labels[fp.settings.sensitivity]!, style: AppFonts.mono(context, size: 11, w: FontWeight.w700, color: c.amber)),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: c.amber, thumbColor: c.amber, inactiveTrackColor: c.surface2, overlayShape: SliderComponentShape.noOverlay),
            child: Slider(
              value: fp.settings.sensitivity.toDouble(), min: 1, max: 3, divisions: 2,
              onChanged: (v) => fp.setSensitivity(v.round()),
            ),
          ),
          const SizedBox(height: 8),
          _toggleRow(context, c, 'Human Detection', 'Flag bipedal movement inside active zones', fp.settings.humanDetection, fp.toggleHuman),
          _toggleRow(context, c, 'Animal Filter', 'Suppress alerts from wildlife signatures', fp.settings.animalFilter, fp.toggleAnimal),
          _toggleRow(context, c, 'Directional Alert (L→R)', 'Only alert on inbound crossing direction', fp.settings.directionalAlert, fp.toggleDirectional),
        ]),
      );

      final zonesPanel = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Active Perimeter Zones', style: AppFonts.display(context, size: 14, w: FontWeight.w600, color: c.text)),
          const SizedBox(height: 12),
          if (fp.zones.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No zones yet — add your first perimeter zone.', style: AppFonts.body(context, size: 12, color: c.textDim)),
            ),
          ...fp.zones.map((z) => _zoneRow(context, c, fp, z)),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: c.textDim, side: BorderSide(color: c.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            onPressed: () => _showZoneDialog(context, c, fp),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Zone'),
          ),
        ]),
      );

      return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          isNarrow
              ? Column(children: [
                  settingsPanel,
                  const SizedBox(height: 16),
                  zonesPanel,
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: settingsPanel),
                  const SizedBox(width: 16),
                  Expanded(child: zonesPanel),
                ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: fp.settings.armed ? c.red : c.amber,
                foregroundColor: fp.settings.armed ? Colors.white : const Color(0xFF14100A),
                elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: fp.toggleArmed,
              icon: Icon(fp.settings.armed ? Icons.lock : Icons.lock_outline, size: 17),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(fp.settings.armed ? 'Virtual Fence Armed — Tap to Disarm' : 'Arm Virtual Fence'),
              ),
            ),
          ),
        ]),
      );
    });
  }

  Widget _errorState(BuildContext context, AppColors c, FenceProvider fp) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off, color: c.textFaint, size: 32),
          const SizedBox(height: 10),
          Text(fp.error!, style: AppFonts.body(context, size: 12, color: c.textDim), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: fp.fetchAll, child: const Text('Retry')),
        ]),
      );

  Widget _toggleRow(BuildContext context, AppColors c, String title, String desc, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _zoneRow(BuildContext context, AppColors c, FenceProvider fp, FenceZone z) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(color: c.surface2, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(4)),
        child: Row(children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: z.status == 'amber' ? c.amber : c.teal, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(z.name, style: AppFonts.body(context, size: 12.5, color: c.text), overflow: TextOverflow.ellipsis)),
          GestureDetector(
            onTap: () => _showZoneDialog(context, c, fp, existing: z),
            child: Icon(Icons.edit_outlined, size: 14, color: c.textFaint),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => fp.deleteZone(z.id),
            child: Icon(Icons.delete_outline, size: 14, color: c.red),
          ),
        ]),
      );

  void _showZoneDialog(BuildContext context, AppColors c, FenceProvider fp, {FenceZone? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String status = existing?.status ?? 'teal';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return Dialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: c.border)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Form(
                key: formKey,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(existing == null ? 'Add Zone' : 'Edit Zone', style: AppFonts.display(ctx, size: 16, w: FontWeight.w600, color: c.text)),
                  const SizedBox(height: 16),
                  Text('ZONE NAME', style: AppFonts.mono(ctx, size: 10, color: c.textDim, spacing: 0.8)),
                  const SizedBox(height: 6),
                  TextFormField(controller: nameCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: 'e.g. Zone D — Riverbank')),
                  const SizedBox(height: 14),
                  Text('STATUS', style: AppFonts.mono(ctx, size: 10, color: c.textDim, spacing: 0.8)),
                  const SizedBox(height: 8),
                  Row(children: [
                    ChoiceChip(
                      label: const Text('Normal'), selected: status == 'teal',
                      onSelected: (_) => setState(() => status = 'teal'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Elevated'), selected: status == 'amber',
                      onSelected: (_) => setState(() => status = 'amber'),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: c.textDim))),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: c.amber, foregroundColor: const Color(0xFF14100A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        if (existing != null) {
                          fp.updateZone(existing.id, nameCtrl.text, status);
                        } else {
                          fp.addZone(nameCtrl.text, status);
                        }
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Zone'),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        );
      }),
    );
  }
}