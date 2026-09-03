import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/alert_provider.dart';
import '../models/alert_item.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_form_dialog.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertSeverity? _filter;

  IconData _iconFor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.critical:
        return Icons.warning_amber_rounded;
      case AlertSeverity.warning:
        return Icons.directions_car_filled_outlined;
      case AlertSeverity.info:
        return Icons.videocam_outlined;
    }
  }

  Color _colorFor(AppColors c, AlertSeverity s) {
    switch (s) {
      case AlertSeverity.critical:
        return c.red;
      case AlertSeverity.warning:
        return c.amber;
      case AlertSeverity.info:
        return c.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final alertProvider = context.watch<AlertProvider>();
    final alerts = _filter == null
        ? alertProvider.alerts
        : alertProvider.alerts.where((a) => a.severity == _filter).toList();

    if (alertProvider.loading && alertProvider.alerts.isEmpty) {
      return Center(child: CircularProgressIndicator(color: c.amber));
    }
    if (alertProvider.error != null && alertProvider.alerts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off, color: c.textFaint, size: 32),
          const SizedBox(height: 10),
          Text(alertProvider.error!,
              style: AppFonts.body(context, size: 12, color: c.textDim),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: alertProvider.fetchAll, child: const Text('Retry')),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Alert History',
                style: AppFonts.display(context, size: 16, w: FontWeight.w600, color: c.text)),
            Text('System-wide tactical alerts and intrusion logs.',
                style: AppFonts.body(context, size: 12, color: c.textDim)),
          ]),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: c.amber,
            foregroundColor: const Color(0xFF14100A),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          onPressed: () async {
            final result = await showAlertFormDialog(context, c);
            if (result != null) {
              try {
                await alertProvider.addAlert(
                  severity: result.severity,
                  title: result.title,
                  description: result.description,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Could not save alert: $e')));
                }
              }
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Log Alert'),
        ),
      ]),
      const SizedBox(height: 14),
      Row(children: [
        _chip(context, c, 'All', _filter == null, () => setState(() => _filter = null)),
        const SizedBox(width: 8),
        _chip(context, c, 'Critical', _filter == AlertSeverity.critical,
            () => setState(() => _filter = AlertSeverity.critical)),
        const SizedBox(width: 8),
        _chip(context, c, 'Warning', _filter == AlertSeverity.warning,
            () => setState(() => _filter = AlertSeverity.warning)),
        const SizedBox(width: 8),
        _chip(context, c, 'Info', _filter == AlertSeverity.info,
            () => setState(() => _filter = AlertSeverity.info)),
      ]),
      const SizedBox(height: 14),
      Expanded(
        child: alerts.isEmpty
            ? Center(child: Text('No alerts match this filter.', style: AppFonts.body(context, color: c.textDim)))
            : ListView.separated(
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = alerts[i];
                  final color = _colorFor(c, a.severity);

                  // NOTE: the outer Container below uses a UNIFORM border
                  // (Border.all — same color on all four sides) together
                  // with borderRadius. Flutter throws "A borderRadius can
                  // only be given on borders with uniform colors" if you
                  // mix borderRadius with a Border that has different
                  // colors per side (e.g. a colored left accent + grey on
                  // the other three sides) — that combo silently blanked
                  // out every alert card. The severity-colored accent is
                  // now a separate flat Container strip inside the Row
                  // instead of being part of the border.
                  return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: c.border),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // severity accent bar (was the buggy border-left)
                          Container(width: 3, color: color),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(_iconFor(a.severity), size: 17, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: color,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              a.severity.label,
                                              style: AppFonts.mono(
                                                context,
                                                size: 9,
                                                w: FontWeight.w700,
                                                color: a.severity == AlertSeverity.warning
                                                    ? const Color(0xFF14100A)
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(a.refCode,
                                              style: AppFonts.mono(context, size: 10, color: c.textFaint)),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(a.title,
                                            style: AppFonts.body(context, size: 13.5, w: FontWeight.w600, color: c.text)),
                                        const SizedBox(height: 2),
                                        Text(a.description,
                                            style: AppFonts.body(context, size: 12, color: c.textDim)),
                                        const SizedBox(height: 6),
                                        Text(a.timestamp,
                                            style: AppFonts.mono(context, size: 10, color: c.textFaint)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, size: 15, color: c.textDim),
                                    onPressed: () async {
                                      final result = await showAlertFormDialog(context, c, existing: a);
                                      if (result != null) {
                                        alertProvider.updateAlert(
                                          a.id,
                                          severity: result.severity,
                                          title: result.title,
                                          description: result.description,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 15, color: c.red),
                                    onPressed: () => alertProvider.deleteAlert(a.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _chip(BuildContext context, AppColors c, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? c.amber : c.surface,
          border: Border.all(color: active ? c.amber : c.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            context,
            size: 12,
            w: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? const Color(0xFF14100A) : c.textDim,
          ),
        ),
      ),
    );
  }
}