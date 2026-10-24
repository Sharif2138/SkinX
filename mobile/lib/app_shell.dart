import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'account_screen.dart';
import 'ask_screen.dart';
import 'history_screen.dart';
import 'learn_screen.dart';
import 'screening_screen.dart';
import 'widgets/skinx_bottom_navigation_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.onNavigationTap,
    this.onPatientNameChanged,
    this.onTakePhoto,
    this.onUploadPhoto,
    this.onScreenPhoto,
    this.onChangePhoto,
    this.screeningPhoto,
    this.isIllustrativePhoto = false,
    this.onAskQuestionSubmitted,
    this.onAskSourceTap,
    this.accountScreen = const AccountScreen(),
  });

  final ValueChanged<SkinXDestination>? onNavigationTap;
  final ValueChanged<String>? onPatientNameChanged;
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadPhoto;
  final VoidCallback? onScreenPhoto;
  final VoidCallback? onChangePhoto;
  final ImageProvider<Object>? screeningPhoto;
  final bool isIllustrativePhoto;
  final ValueChanged<String>? onAskQuestionSubmitted;
  final ValueChanged<Uri>? onAskSourceTap;
  // Supply account details and action callbacks through this screen.
  final AccountScreen accountScreen;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  SkinXDestination _selectedDestination = SkinXDestination.learn;

  void _selectDestination(SkinXDestination destination) {
    FocusScope.of(context).unfocus();
    setState(() => _selectedDestination = destination);
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
          index: switch (_selectedDestination) {
            SkinXDestination.history => 1,
            SkinXDestination.screen => 2,
            SkinXDestination.ask => 3,
            SkinXDestination.account => 4,
            _ => 0,
          },
          children: [
            const LearnScreen(),
            const HistoryScreen(),
            ScreeningScreen(
              onPatientNameChanged: widget.onPatientNameChanged,
              onTakePhoto: widget.onTakePhoto,
              onUploadPhoto: widget.onUploadPhoto,
              onScreenPhoto: widget.onScreenPhoto,
              onChangePhoto: widget.onChangePhoto,
              photo: widget.screeningPhoto,
              isIllustrativePhoto: widget.isIllustrativePhoto,
            ),
            AskScreen(
              onQuestionSubmitted: widget.onAskQuestionSubmitted,
              onSourceTap: widget.onAskSourceTap,
            ),
            widget.accountScreen,
          ],
        ),
        bottomNavigationBar: SkinXBottomNavigationBar(
          selectedDestination: _selectedDestination,
          onTap: _selectDestination,
        ),
      ),
    );
  }
}
