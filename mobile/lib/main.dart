import 'package:flutter/material.dart';

import 'api/miamai_api_client.dart';
import 'app_state.dart';
import 'screens/assistant_screen.dart';
import 'screens/basket_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/preferences_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/app_chrome.dart';

const apiBaseUrl = String.fromEnvironment(
  'MIAMAI_API_BASE',
  // 10.0.2.2 permet à l'émulateur Android de joindre le localhost machine.
  defaultValue: 'http://10.0.2.2:8080/api',
);

void main() {
  runApp(MiamAiApp(apiClient: MiamAiApiClient(apiBaseUrl)));
}

class MiamAiApp extends StatefulWidget {
  const MiamAiApp({required this.apiClient, super.key});

  final MiamAiApiClient apiClient;

  @override
  State<MiamAiApp> createState() => _MiamAiAppState();
}

class _MiamAiAppState extends State<MiamAiApp> {
  late final MiamAiAppState appState;

  @override
  void initState() {
    super.initState();
    appState = MiamAiAppState(widget.apiClient)..loadInitialData();
  }

  @override
  void dispose() {
    appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MiamAiStateScope(
      state: appState,
      child: MaterialApp(
        title: 'MiamAI',
        debugShowCheckedModeBanner: false,
        theme: buildMiamAiTheme(),
        builder: (context, child) {
          return MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.18,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const MiamAiHome(),
      ),
    );
  }
}

class MiamAiHome extends StatefulWidget {
  const MiamAiHome({super.key});

  @override
  State<MiamAiHome> createState() => _MiamAiHomeState();
}

class _MiamAiHomeState extends State<MiamAiHome> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final driveName = state.preferences?.preferredDrive.name ?? 'Pessac';
        return Scaffold(
          backgroundColor: MiamAiColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(driveName: driveName),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      AssistantScreen(onOpenBasket: () => _selectTab(2)),
                      const MealsScreen(),
                      const BasketScreen(),
                      const PreferencesScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: MiamAiBottomNavigation(
            currentIndex: _tabIndex,
            onSelected: _selectTab,
            basketCount: state.basket?.lines.length ?? 0,
          ),
        );
      },
    );
  }

  void _selectTab(int index) {
    setState(() => _tabIndex = index);
  }
}
