import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'account_screen.dart';
import 'ask_screen.dart';
import 'history_screen.dart';
import 'learn_screen.dart';
import 'screening_screen.dart';
import 'widgets/skinx_bottom_navigation_bar.dart';
import 'services/skinx_model_service.dart';
import 'services/screening_history_service.dart';
import 'services/auth_service.dart';
import 'models/screening_result.dart';
import 'screening_result_screen.dart';
import 'sign_up_screen.dart';

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
  final _picker = ImagePicker();
  final _model = SkinXModelService();
  final _history = ScreeningHistoryService();
  Uint8List? _photoBytes;
  bool _screening = false;
  List<ScreeningRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _history.getAll(AuthService.ownerId);
      if (!mounted) return;
      setState(() => _records = data.map((row) => ScreeningRecord(
        id: row['id'] as int,
        patientName: 'Anonymous screening',
        savedAt: DateTime.parse(row['created_at'] as String).toLocal(),
        savedDetails: row['result'] as String,
        thumbnailAsset: '',
      )).toList());
    } catch (_) {
      if (mounted) _showError('Could not open local screening history.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file == null) return;
      if (await file.length() > 12582912) {
        _showError('Image is too large. Use a JPEG or PNG under 12 MB.');
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() => _photoBytes = bytes);
      _selectDestination(SkinXDestination.screen);
    } catch (_) {
      _showError('Unable to open your camera or selected photo.');
    }
  }

  Future<void> _screenPhoto() async {
    final bytes = _photoBytes;
    if (bytes == null || _screening) return;
    setState(() => _screening = true);
    // Show progress while inference runs locally; no HTTP request is made.
    showDialog<void>(context: context, barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()));
    ScreeningResult result;
    try {
      result = await _model.screen(bytes);
    } catch (_) {
      result = ScreeningResult.failed();
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _screening = false);
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ScreeningResultScreen(
        result: result,
        onSave: () async {
          await _history.save(ownerId: AuthService.ownerId, result: result.status);
          await _loadHistory();
        },
      ),
    ));
  }

  Future<void> _showRecord(ScreeningRecord record) async {
    final delete = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Saved screening'),
      content: Text('${record.savedDetails} • ${record.savedAt.toLocal()}\n\nThis result is not a diagnosis. No photo or patient name was saved.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Close')),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete record')),
      ],
    ));
    if (delete == true && record.id != null) {
      await _history.remove(ownerId: AuthService.ownerId, id: record.id!);
      await _loadHistory();
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignUpScreen()), (_) => false);
    } catch (_) {
      _showError('Could not sign out. Check your connection and try again.');
    }
  }

  @override
  void dispose() {
    _model.close();
    super.dispose();
  }


  void _selectDestination(SkinXDestination destination) {
    FocusScope.of(context).unfocus();
    setState(() => _selectedDestination = destination);
    widget.onNavigationTap?.call(destination);
    if (destination == SkinXDestination.history) _loadHistory();
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
            HistoryScreen(records: _records, onRecordTap: _showRecord),
            ScreeningScreen(
              onPatientNameChanged: widget.onPatientNameChanged,
              onTakePhoto: widget.onTakePhoto ?? () => _pickPhoto(ImageSource.camera),
              onUploadPhoto: widget.onUploadPhoto ?? () => _pickPhoto(ImageSource.gallery),
              onScreenPhoto: _screening ? null : (widget.onScreenPhoto ?? _screenPhoto),
              onChangePhoto: widget.onChangePhoto ?? () => setState(() => _photoBytes = null),
              photo: widget.screeningPhoto ?? (_photoBytes == null ? null : MemoryImage(_photoBytes!)),
              isIllustrativePhoto: widget.isIllustrativePhoto,
            ),
            AskScreen(
              onQuestionSubmitted: widget.onAskQuestionSubmitted,
              onSourceTap: widget.onAskSourceTap,
            ),
            widget.accountScreen.name != null
                ? widget.accountScreen
                : AccountScreen(
                    name: AuthService.user?.userMetadata?['full_name']?.toString() ?? 'Offline guest',
                    email: AuthService.user?.email ?? 'No account required',
                    profileTitle: AuthService.user == null ? 'Offline mode' : 'SkinX account',
                    profileSubtitle: AuthService.user == null ? 'You can screen without internet' : 'Signed in',
                    onSignOutTap: _signOut,
                  ),
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
