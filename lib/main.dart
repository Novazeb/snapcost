import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/lock_screen.dart';
import 'features/expenses/presentation/providers/expense_provider.dart';
import 'features/expenses/presentation/screens/main_navigation_screen.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const SnapCostApp(),
    ),
  );
}

class SnapCostApp extends StatefulWidget {
  const SnapCostApp({super.key});

  @override
  State<SnapCostApp> createState() => _SnapCostAppState();
}

class _SnapCostAppState extends State<SnapCostApp> with WidgetsBindingObserver {
  bool _isUnlocked = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (settings.isBiometricsEnabled) {
        setState(() {
          _isUnlocked = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'SnapCost',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: Builder(
            builder: (context) {
              if (settings.isBiometricsEnabled && !_isUnlocked) {
                return LockScreen(
                  onUnlocked: () {
                    setState(() {
                      _isUnlocked = true;
                    });
                  },
                );
              }
              return const MainNavigationScreen();
            },
          ),
        );
      },
    );
  }
}
