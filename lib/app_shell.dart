import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'history_screen.dart';
import 'learn_screen.dart';
import 'widgets/skinx_bottom_navigation_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.onNavigationTap});

  final ValueChanged<SkinXDestination>? onNavigationTap;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  SkinXDestination _selectedDestination = SkinXDestination.learn;

  void _selectDestination(SkinXDestination destination) {
    if (destination == SkinXDestination.learn || destination == SkinXDestination.history) {
      setState(() => _selectedDestination = destination);
    }
    widget.onNavigationTap?.call(destination);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedDestination == SkinXDestination.history ? 1 : 0,
          children: const [LearnScreen(), HistoryScreen()],
        ),
        bottomNavigationBar: SkinXBottomNavigationBar(
          selectedDestination: _selectedDestination,
          onTap: _selectDestination,
        ),
      ),
    );
  }
}
