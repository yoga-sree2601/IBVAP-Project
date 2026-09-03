import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/alert_provider.dart';
import 'providers/fence_provider.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const IbvapApp());
}

class IbvapApp extends StatelessWidget {
  const IbvapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider(api: api)),
        ChangeNotifierProvider(create: (_) => AlertProvider(api: api)),
        ChangeNotifierProvider(create: (_) => FenceProvider(api: api)),
        Provider<ApiService>.value(value: api),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'IBVAP',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(themeProvider.colors, themeProvider.brightness),
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}
