import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/camera_provider.dart';
import '../models/camera.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_form_dialog.dart';

class CamerasScreen extends StatelessWidget {
  const CamerasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ThemeProvider>().colors;
    final camProvider = context.watch<CameraProvider>();
    final cams = camProvider.cameras;

    if (camProvider.loading && cams.isEmpty) {
      return Center(child: CircularProgressIndicator(color: c.amber));
    }
    if (camProvider.error != null && cams.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off, color: c.textFaint, size: 32),
          const SizedBox(height: 10),
          Text(camProvider.error!, style: AppFonts.body(context, size: 12, color: c.textDim), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: camProvider.fetchAll, child: const Text('Retry')),
        ]),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 480;

      Future<void> onAddPressed() async {
        final result = await showCameraFormDialog(context, c);
        if (result != null) {
          try {
            await camProvider.addCamera(name: result.name, sector: result.sector, ip: result.ip, rtsp: result.rtsp, type: result.type, online: result.online);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added "${result.name}" to the network.'), backgroundColor: c.surface2));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save camera: $e'), backgroundColor: c.red));
            }
          }
        }
      }

      final header = isNarrow
          // Stack title above a compact icon-only add button so nothing
          // gets squeezed into an overflowing single row.
          ? Row(children: [
              Expanded(
                child: Text('Camera Network', style: AppFonts.display(context, size: 15, w: FontWeight.w600, color: c.text), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(backgroundColor: c.amber, foregroundColor: const Color(0xFF14100A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 20),
              ),
            ])
          : Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Camera Network', style: AppFonts.display(context, size: 16, w: FontWeight.w600, color: c.text)),
                  const SizedBox(height: 2),
                  Text('${cams.length} registered nodes — live thumbnail, sector and stream control.', style: AppFonts.body(context, size: 12, color: c.textDim)),
                ]),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: c.amber, foregroundColor: const Color(0xFF14100A), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Camera'),
              ),
            ]);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (isNarrow) ...[
            const SizedBox(height: 4),
            Text('${cams.length} registered nodes', style: AppFonts.body(context, size: 11, color: c.textDim)),
          ],
          SizedBox(height: isNarrow ? 12 : 18),
          Expanded(
            child: cams.isEmpty
                ? Center(child: Text('No cameras yet — add your first node.', style: AppFonts.body(context, color: c.textDim)))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isNarrow ? constraints.maxWidth : 300,
                      mainAxisExtent: isNarrow ? (constraints.maxWidth * 9 / 16) + 78 : 250,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: cams.length,
                    itemBuilder: (_, i) => _CameraCard(cam: cams[i], c: c, camProvider: camProvider),
                  ),
          ),
        ],
      );
    });
  }
}

class _CameraCard extends StatelessWidget {
  final SurveillanceCamera cam;
  final AppColors c;
  final CameraProvider camProvider;
  const _CameraCard({required this.cam, required this.c, required this.camProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(cam.feedImage, fit: BoxFit.cover),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.55)]))),
            Positioned(
              top: 8, left: 8,
              child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: cam.online ? c.teal : c.red, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(cam.online ? 'LIVE' : 'OFFLINE', style: AppFonts.mono(context, size: 9, color: Colors.white)),
              ]),
            ),
            Positioned(bottom: 8, left: 10, right: 10, child: Text(cam.name, style: AppFonts.display(context, size: 13.5, w: FontWeight.w600, color: Colors.white))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cam.sector, style: AppFonts.body(context, size: 12, w: FontWeight.w500, color: c.text), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${cam.ip} · ${cam.type.label}', style: AppFonts.mono(context, size: 9.5, color: c.textFaint), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: Icon(Icons.edit_outlined, size: 16, color: c.textDim),
              onPressed: () async {
                final result = await showCameraFormDialog(context, c, existing: cam);
                if (result != null) {
                  try {
                    await camProvider.updateCamera(cam.id, name: result.name, sector: result.sector, ip: result.ip, rtsp: result.rtsp, type: result.type, online: result.online);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update camera: $e')));
                    }
                  }
                }
              },
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline, size: 16, color: c.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: c.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: c.border)),
                    title: Text('Remove camera?', style: AppFonts.display(ctx, size: 15, color: c.text)),
                    content: Text('"${cam.name}" will be removed from the network.', style: AppFonts.body(ctx, size: 12.5, color: c.textDim)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: c.textDim))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: c.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await camProvider.deleteCamera(cam.id);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete camera: $e')));
                    }
                  }
                }
              },
            ),
          ]),
        ),
      ]),
    );
  }
}
