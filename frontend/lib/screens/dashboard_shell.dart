import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import 'live_feed_screen.dart';
import 'cameras_screen.dart';
import 'map_screen.dart';
import 'anpr_screen.dart';
import 'night_detection_screen.dart';
import 'fence_screen.dart';
import 'alerts_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class DashboardShell extends StatefulWidget {
  final String operatorId;
  const DashboardShell({super.key, this.operatorId = 'Operator'});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String _page = 'live';
  bool _collapsed = false;

  static const mobileNavOrder = ['live', 'map', 'anpr', 'alerts', 'settings'];

  static const titles = {
    'live': ['Live Feed', 'SECTOR NORTH-EAST // NODE 12'],
    'cameras': ['Camera Network', 'REGISTERED NODES'],
    'map': ['Sector Map', 'REAL-TIME PERIMETER VIEW'],
    'anpr': ['ANPR', 'AUTOMATIC NUMBER PLATE RECOGNITION'],
    'night': ['Night Detection', 'LOW-LIGHT & THERMAL MOVEMENT'],
    'fence': ['Virtual Fence', 'PERIMETER INTRUSION BOUNDARIES'],
    'alerts': ['Alert History', 'SYSTEM-WIDE TACTICAL LOG'],
    'analytics': ['Intelligence Analytics', '30-DAY ROLLUP'],
    'settings': ['System Settings', 'PLATFORM CONFIGURATION'],
  };

  static const navIcons = {
    'live': Icons.videocam_outlined,
    'cameras': Icons.camera_alt_outlined,
    'map': Icons.map_outlined,
    'anpr': Icons.badge_outlined,
    'night': Icons.nightlight_outlined,
    'fence': Icons.fence_outlined,
    'alerts': Icons.warning_amber_outlined,
    'analytics': Icons.analytics_outlined,
    'settings': Icons.settings_outlined,
  };

  Widget _buildPage(String key) {
    switch (key) {
      case 'live':
        return const LiveFeedScreen();
      case 'cameras':
        return const CamerasScreen();
      case 'map':
        return const MapScreen();
      case 'anpr':
        return const AnprScreen();
      case 'night':
        return const NightDetectionScreen();
      case 'fence':
        return const FenceScreen();
      case 'alerts':
        return const AlertsScreen();
      case 'analytics':
        return const AnalyticsScreen();
      case 'settings':
        return const SettingsScreen();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final c = themeProvider.colors;
    final title = titles[_page]!;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final body = Column(
      children: [
        _Header(c: c, title: title, themeProvider: themeProvider, isMobile: isMobile, operatorId: widget.operatorId),
        Expanded(
          child: Container(
            color: c.bg,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                  child: child,
                ),
              ),
              child: Padding(
                key: ValueKey(_page),
                padding: EdgeInsets.all(isMobile ? 14 : 22),
                child: _buildPage(_page),
              ),
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Scaffold(
        backgroundColor: c.bg,
        drawer: Drawer(
          backgroundColor: c.bgElev,
          child: SafeArea(
            child: Sidebar(
              c: c,
              selected: _page,
              collapsed: false,
              onSelect: (k) {
                setState(() => _page = k);
                Navigator.of(context).pop();
              },
              onToggleCollapse: () {},
            ),
          ),
        ),
        body: SafeArea(child: body),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: c.bgElev, border: Border(top: BorderSide(color: c.border))),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 58,
              child: Row(
                children: mobileNavOrder.map((k) {
                  final active = k == _page;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _page = k),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(navIcons[k], size: 20, color: active ? c.teal : c.textFaint),
                          const SizedBox(height: 3),
                          Text(
                            titles[k]![0],
                            style: AppFonts.mono(context, size: 8.5, color: active ? c.teal : c.textFaint),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: Row(
        children: [
          Sidebar(
            c: c,
            selected: _page,
            collapsed: _collapsed,
            onSelect: (k) => setState(() => _page = k),
            onToggleCollapse: () => setState(() => _collapsed = !_collapsed),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppColors c;
  final List<String> title;
  final ThemeProvider themeProvider;
  final bool isMobile;
  final String operatorId;

  const _Header({required this.c, required this.title, required this.themeProvider, required this.isMobile, required this.operatorId});

  String get _initial {
    final t = operatorId.trim();
    if (t.isEmpty) return '?';
    final alphaNum = t.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (alphaNum.isEmpty) return t[0].toUpperCase();
    return alphaNum[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 54 : 60,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 22),
      decoration: BoxDecoration(color: c.bgElev, border: Border(bottom: BorderSide(color: c.border))),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (ctx) => IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.menu, color: c.text, size: 22),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          if (isMobile) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title[0],
                  style: AppFonts.display(context, size: isMobile ? 14.5 : 16.5, w: FontWeight.w600, color: c.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile)
                  Text(title[1], style: AppFonts.mono(context, size: 9.5, color: c.textFaint, spacing: 0.8)),
              ],
            ),
          ),
          if (!isMobile) ...[
            _Clock(c: c),
            const SizedBox(width: 16),
          ],
          GestureDetector(
            onTap: themeProvider.toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 44,
              height: 24,
              decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: themeProvider.isDark ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: themeProvider.isDark ? c.amber : c.blue),
                  child: Icon(themeProvider.isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round, size: 11, color: const Color(0xFF14100A)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _showProfileMenu(context, c, operatorId, _initial),
            child: CircleAvatar(radius: 15, backgroundColor: c.teal, child: Text(_initial, style: AppFonts.mono(context, size: 12, w: FontWeight.w700, color: const Color(0xFF06110E)))),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(operatorId, style: AppFonts.body(context, size: 11.5, w: FontWeight.w600, color: c.text)),
                Text('TACTICAL ADMIN', style: AppFonts.mono(context, size: 8.5, color: c.textFaint)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Clock extends StatefulWidget {
  final AppColors c;
  const _Clock({required this.c});
  @override
  State<_Clock> createState() => _ClockState();
}

class _ClockState extends State<_Clock> {
  late DateTime _now;
  @override
  void initState() {
    super.initState();
    _now = DateTime.now().toUtc();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _now = DateTime.now().toUtc());
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _now.toIso8601String().substring(11, 19);
    return Text('$s Z', style: AppFonts.mono(context, size: 12, color: widget.c.textDim));
  }
}

void _showProfileMenu(BuildContext context, AppColors c, String operatorId, String initial) {
  showModalBottomSheet(
    context: context,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 22, backgroundColor: c.teal, child: Text(initial, style: AppFonts.mono(ctx, size: 15, w: FontWeight.w700, color: const Color(0xFF06110E)))),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(operatorId, style: AppFonts.display(ctx, size: 15, w: FontWeight.w600, color: c.text)),
              Text('TACTICAL ADMIN', style: AppFonts.mono(ctx, size: 9.5, color: c.textFaint)),
            ]),
          ]),
          const SizedBox(height: 18),
          Container(height: 1, color: c.borderSoft),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Row(children: [
              Icon(Icons.logout, size: 18, color: c.red),
              const SizedBox(width: 10),
              Text('Log Out', style: AppFonts.body(ctx, size: 13.5, w: FontWeight.w600, color: c.red)),
            ]),
          ),
        ]),
      ),
    ),
  );
}
