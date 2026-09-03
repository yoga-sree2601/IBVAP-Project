import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavEntry {
  final String key;
  final String label;
  final IconData icon;
  final String group;
  final int? badge;
  const NavEntry(this.key, this.label, this.icon, this.group, {this.badge});
}

const navEntries = [
  NavEntry('live', 'Live Feed', Icons.videocam_outlined, 'MONITORING'),
  NavEntry('cameras', 'Cameras', Icons.camera_alt_outlined, 'MONITORING'),
  NavEntry('map', 'Sector Map', Icons.map_outlined, 'MONITORING'),
  NavEntry('anpr', 'ANPR', Icons.directions_car_filled_outlined, 'DETECTION'),
  NavEntry('night', 'Night Detection', Icons.nightlight_round, 'DETECTION'),
  NavEntry('fence', 'Virtual Fence', Icons.fence_outlined, 'DETECTION'),
  NavEntry('alerts', 'Alerts', Icons.warning_amber_rounded, 'INTELLIGENCE', badge: 3),
  NavEntry('analytics', 'Analytics', Icons.bar_chart_rounded, 'INTELLIGENCE'),
  NavEntry('settings', 'Settings', Icons.settings_outlined, 'SYSTEM'),
];

class Sidebar extends StatelessWidget {
  final AppColors c;
  final String selected;
  final bool collapsed;
  final ValueChanged<String> onSelect;
  final VoidCallback onToggleCollapse;

  const Sidebar({
    super.key,
    required this.c,
    required this.selected,
    required this.collapsed,
    required this.onSelect,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<NavEntry>>{};
    for (final e in navEntries) {
      groups.putIfAbsent(e.group, () => []).add(e);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: collapsed ? 68 : 216,
      decoration: BoxDecoration(
        color: c.bgElev,
        border: Border(right: BorderSide(color: c.border)),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.borderSoft))),
            child: Row(children: [
              Icon(Icons.shield_moon_outlined, color: c.amber, size: 22),
              if (!collapsed) ...[
                const SizedBox(width: 10),
                Text('IBVAP', style: AppFonts.display(context, size: 15.5, w: FontWeight.w700, color: c.amber)),
              ],
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              children: groups.entries.expand((g) sync* {
                if (!collapsed) {
                  yield Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 6),
                    child: Text(g.key, style: AppFonts.mono(context, size: 9.5, color: c.textFaint, spacing: 1.4)),
                  );
                } else {
                  yield const SizedBox(height: 10);
                }
                for (final e in g.value) {
                  yield _NavTile(entry: e, active: e.key == selected, collapsed: collapsed, c: c, onTap: () => onSelect(e.key));
                }
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.borderSoft))),
            child: InkWell(
              onTap: onToggleCollapse,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                child: Row(children: [
                  AnimatedRotation(
                    turns: collapsed ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: Icon(Icons.chevron_left, size: 18, color: c.textFaint),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 10),
                    Text('Collapse', style: AppFonts.body(context, size: 12, color: c.textFaint)),
                  ],
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavEntry entry;
  final bool active;
  final bool collapsed;
  final AppColors c;
  final VoidCallback onTap;
  const _NavTile({required this.entry, required this.active, required this.collapsed, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active ? c.surface2 : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: active ? c.amber : Colors.transparent, width: 2)),
            ),
            child: Row(children: [
              Icon(entry.icon, size: 18, color: active ? c.amber : c.textDim),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(child: Text(entry.label, style: AppFonts.body(context, size: 13, w: FontWeight.w500, color: active ? c.amber : c.textDim))),
                if (entry.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: c.red, borderRadius: BorderRadius.circular(8)),
                    child: Text('${entry.badge}', style: AppFonts.mono(context, size: 9, color: Colors.white)),
                  ),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
