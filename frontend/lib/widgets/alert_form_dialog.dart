import 'package:flutter/material.dart';
import '../models/alert_item.dart';
import '../theme/app_theme.dart';

class AlertFormResult {
  final AlertSeverity severity;
  final String title, description;
  AlertFormResult(this.severity, this.title, this.description);
}

Future<AlertFormResult?> showAlertFormDialog(BuildContext context, AppColors c, {AlertItem? existing}) {
  final titleCtrl = TextEditingController(text: existing?.title ?? '');
  final descCtrl = TextEditingController(text: existing?.description ?? '');
  AlertSeverity severity = existing?.severity ?? AlertSeverity.warning;
  final formKey = GlobalKey<FormState>();

  return showDialog<AlertFormResult>(
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
                  Text(existing == null ? 'Log Alert' : 'Edit Alert', style: AppFonts.display(ctx, size: 16, w: FontWeight.w600, color: c.text)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: Icon(Icons.close, size: 18, color: c.textFaint)),
                ]),
                const SizedBox(height: 12),
                Text('SEVERITY', style: AppFonts.mono(ctx, size: 10, color: c.textDim, spacing: 0.8)),
                const SizedBox(height: 8),
                Row(children: AlertSeverity.values.map((s) {
                  final active = severity == s;
                  final color = s == AlertSeverity.critical ? c.red : (s == AlertSeverity.warning ? c.amber : c.blue);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s.label, style: AppFonts.mono(ctx, size: 10, color: active ? const Color(0xFF0B0E12) : color)),
                      selected: active,
                      selectedColor: color,
                      backgroundColor: color.withOpacity(0.12),
                      side: BorderSide(color: color.withOpacity(0.5)),
                      onSelected: (_) => setState(() => severity = s),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 14),
                Text('TITLE', style: AppFonts.mono(ctx, size: 10, color: c.textDim, spacing: 0.8)),
                const SizedBox(height: 6),
                TextFormField(controller: titleCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: 'e.g. Unregistered Vehicle Approach')),
                const SizedBox(height: 14),
                Text('DESCRIPTION', style: AppFonts.mono(ctx, size: 10, color: c.textDim, spacing: 0.8)),
                const SizedBox(height: 6),
                TextFormField(controller: descCtrl, maxLines: 3, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null, decoration: const InputDecoration(hintText: 'Details for the response team...')),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: c.textDim))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: c.amber, foregroundColor: const Color(0xFF14100A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(ctx, AlertFormResult(severity, titleCtrl.text, descCtrl.text));
                      }
                    },
                    child: const Text('Save Alert'),
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
