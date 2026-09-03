import 'package:flutter/material.dart';
import '../models/camera.dart';
import '../theme/app_theme.dart';

class CameraFormResult {
  final String name, sector, ip, rtsp;
  final CameraType type;
  final bool online;
  CameraFormResult(this.name, this.sector, this.ip, this.rtsp, this.type, this.online);
}

Future<CameraFormResult?> showCameraFormDialog(BuildContext context, AppColors c, {SurveillanceCamera? existing}) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final sectorCtrl = TextEditingController(text: existing?.sector ?? '');
  final ipCtrl = TextEditingController(text: existing?.ip ?? '');
  final rtspCtrl = TextEditingController(text: existing?.rtsp ?? '');
  CameraType type = existing?.type ?? CameraType.fixed;
  bool online = existing?.online ?? true;
  final formKey = GlobalKey<FormState>();

  return showDialog<CameraFormResult>(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Dialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: c.border)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(existing == null ? 'Add Camera' : 'Edit Camera', style: AppFonts.display(ctx, size: 16, w: FontWeight.w600, color: c.text)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, size: 18, color: c.textFaint)),
                ]),
                const SizedBox(height: 12),
                _label(ctx, c, 'CAMERA NAME'),
                TextFormField(controller: nameCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: 'e.g. BOP-14 North')),
                const SizedBox(height: 14),
                _label(ctx, c, 'SECTOR'),
                TextFormField(controller: sectorCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: 'Sector A-3')),
                const SizedBox(height: 14),
                _label(ctx, c, 'IP ADDRESS'),
                TextFormField(controller: ipCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: '192.168.1.14')),
                const SizedBox(height: 14),
                _label(ctx, c, 'RTSP STREAM URL'),
                TextFormField(controller: rtspCtrl, decoration: const InputDecoration(hintText: 'rtsp://192.168.1.14:554/stream1')),
                const SizedBox(height: 14),
                _label(ctx, c, 'CAMERA TYPE'),
                DropdownButtonFormField<CameraType>(
                  value: type,
                  decoration: const InputDecoration(),
                  dropdownColor: c.surface,
                  items: CameraType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: AppFonts.body(ctx, color: c.text)))).toList(),
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: Text('Camera Online', style: AppFonts.body(ctx, size: 13, color: c.text))),
                  Switch(value: online, activeColor: c.teal, onChanged: (v) => setState(() => online = v)),
                ]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: AppFonts.body(ctx, color: c.textDim))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: c.amber, foregroundColor: const Color(0xFF14100A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, CameraFormResult(nameCtrl.text, sectorCtrl.text, ipCtrl.text, rtspCtrl.text, type, online));
                      }
                    },
                    child: const Text('Save Camera'),
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

Widget _label(BuildContext context, AppColors c, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppFonts.mono(context, size: 10, color: c.textDim, spacing: 0.8)),
    );
