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
import 'sign_in_screen.dart';
import 'services/connectivity_service.dart';

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
  final AccountScreen accountScreen;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  SkinXDestination _selectedDestination = SkinXDestination.learn;
  final _picker = ImagePicker();
  final _model = SkinXModelService();
  final _history = ScreeningHistoryService();
  Uint8List? _photoBytes;
  bool _screening = false;
  bool _confirmedSkinPhoto = false;
  List<ScreeningRecord> _records = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      setState(() {
        _photoBytes = bytes;
        _confirmedSkinPhoto = false;
      });
      _selectDestination(SkinXDestination.screen);
    } catch (_) {
      _showError('Unable to open your camera or selected photo.');
    }
  }

  Future<void> _screenPhoto() async {
    final bytes = _photoBytes;
    if (bytes == null || _screening || !_confirmedSkinPhoto) return;
    setState(() => _screening = true);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ConnectivityService.instance.refresh();
    }
  }

  void _openSignIn() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => const SignInScreen(),
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.close();
    super.dispose();
  }


  void _showGuide(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _selectDestination(SkinXDestination destination) {
    FocusScope.of(context).unfocus();
    setState(() => _selectedDestination = destination);
    widget.onNavigationTap?.call(destination);
    if (destination == SkinXDestination.history) _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ConnectivityService.instance,
      builder: (context, _) => AnnotatedRegion<SystemUiOverlayStyle>(
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
          body: Column(
            children: [
              if (!ConnectivityService.instance.online)
                Material(
                  color: const Color(0xFFEAF2E9),
                  child: SafeArea(
                    top: false,
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off, color: Color(0xFF14665E), size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Offline mode · Screening, Ask, Learn and History are available',
                              style: TextStyle(fontSize: 12, color: Color(0xFF193B38)),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Check connection',
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            icon: const Icon(Icons.refresh, size: 19),
                            onPressed: ConnectivityService.instance.refresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: switch (_selectedDestination) {
                    SkinXDestination.history => 1,
                    SkinXDestination.screen => 2,
                    SkinXDestination.ask => 3,
                    SkinXDestination.account => 4,
                    _ => 0,
                  },
                  children: [
                    LearnScreen(
                      offline: !ConnectivityService.instance.online,
                      onFeaturedGuideTap: () => _showGuide(
                        'Protect your skin',
                        'Seek shade, especially around midday. Wear long sleeves, a wide-brimmed hat and UV-protective sunglasses. Use broad-spectrum SPF 30 or higher and reapply it regularly outdoors. Sun protection is especially important for people with albinism.',
                      ),
                      onSkinChangesTap: () => _showGuide(
                        'Notice changes in your skin',
                        'Look for new spots, changes in size or appearance, bleeding, or wounds that do not heal. A photograph cannot confirm what a skin change is. Ask a health professional about any concerning or persistent spot.',
                      ),
                      onSeekCareTap: () => _showGuide(
                        'When to seek care',
                        'Contact a qualified health professional promptly if a skin change grows, bleeds repeatedly or does not heal. A suspicious screening result is not a diagnosis, and a less suspicious result does not rule out cancer.',
                      ),
                    ),
                    HistoryScreen(records: _records, onRecordTap: _showRecord),
                    ScreeningScreen(
                      onPatientNameChanged: widget.onPatientNameChanged,
                      onTakePhoto: widget.onTakePhoto ?? () => _pickPhoto(ImageSource.camera),
                      onUploadPhoto: widget.onUploadPhoto ?? () => _pickPhoto(ImageSource.gallery),
                      onScreenPhoto: _screening || !_confirmedSkinPhoto
                          ? null
                          : (widget.onScreenPhoto ?? _screenPhoto),
                      onChangePhoto: widget.onChangePhoto ?? () => setState(() {
                        _photoBytes = null;
                        _confirmedSkinPhoto = false;
                      }),
                      photoConfirmed: _confirmedSkinPhoto,
                      onPhotoConfirmedChanged: (confirmed) =>
                          setState(() => _confirmedSkinPhoto = confirmed),
                      photo: widget.screeningPhoto ??
                          (_photoBytes == null ? null : MemoryImage(_photoBytes!)),
                      isIllustrativePhoto: widget.isIllustrativePhoto,
                    ),
                    AskScreen(
                      onlineAvailable: ConnectivityService.instance.online,
                      onQuestionSubmitted: widget.onAskQuestionSubmitted,
                      onSourceTap: widget.onAskSourceTap,
                    ),
                    widget.accountScreen.name != null
                        ? widget.accountScreen
                        : AccountScreen(
                            name: AuthService.user?.userMetadata?['full_name']
                                    ?.toString() ??
                                'Offline guest',
                            email: AuthService.user?.email ?? 'No account required',
                            profileTitle: AuthService.user == null
                                ? (ConnectivityService.instance.online
                                    ? 'Guest mode'
                                    : 'Offline mode')
                                : 'SkinX account',
                            profileSubtitle: AuthService.user == null
                                ? 'Offline features are available without an account'
                                : 'Signed in',
                            actionLabel: AuthService.user == null
                                ? 'Sign in (online)'
                                : 'Sign out',
                            accountActionAvailable:
                                ConnectivityService.instance.online,
                            onSignOutTap:
                                AuthService.user == null ? _openSignIn : _signOut,
                            onPrivacyConsentTap: () => _showGuide(
                              'Privacy & consent',
                              'Offline screening stays on this device. Screening results are saved only when selected, without images or patient names. Local history is not encrypted, so avoid using shared devices for private records. Consult a health professional for concerning skin changes.',
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SkinXBottomNavigationBar(
            selectedDestination: _selectedDestination,
            onTap: _selectDestination,
          ),
        ),
      ),
    );
  }
}
