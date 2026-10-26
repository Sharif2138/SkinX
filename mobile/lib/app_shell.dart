import 'services/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
import 'widgets/skinx_account_type_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/offline_guides.dart';
import 'education_guide_screen.dart';
import 'videos_screen.dart';
import 'privacy_consent_screen.dart';
import 'widgets/skinx_feedback.dart';

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
  final _patientNameController = TextEditingController();
  Uint8List? _photoBytes;
  bool _screening = false;
  bool _confirmedSkinPhoto = false;
  List<ScreeningRecord> _records = [];
  Map<String, dynamic>? _profile;
  StreamSubscription<AuthState>? _authSubscription;
  bool _passwordDialogOpen = false;
  bool _syncErrorShown = false;

  bool get _isCommunityHealthWorker => AuthService.user != null &&
      (_profile?['account_type'] == 'chw' ||
       (_profile == null && AuthService.user?.userMetadata?['account_type'] == 'chw'));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadHistory();
    _loadProfile();
    ConnectivityService.instance.addListener(_syncWhenOnline);
    if (AuthService.configured) {
      _authSubscription = AuthService.client.auth.onAuthStateChange.listen((_) {
        _loadProfile();
        _loadHistory();
      }, onError: (Object error, StackTrace trace) {});
    }
    AuthService.passwordRecoveryPending.addListener(_maybeShowPasswordRecovery);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowPasswordRecovery());
  }

  void _syncWhenOnline() {
    if (ConnectivityService.instance.online) _loadHistory();
  }

  Future<void> _loadProfile() async {
    if (AuthService.user == null) {
      if (mounted) setState(() => _profile = null);
      return;
    }
    try {
      final profile = await AuthService.getProfile();
      if (mounted && AuthService.user?.id == profile?['id']) {
        setState(() => _profile = profile);
      }
    } catch (_) {}
  }

  void _maybeShowPasswordRecovery() {
    if (!mounted || _passwordDialogOpen || !AuthService.passwordRecoveryPending.value) return;
    _passwordDialogOpen = true;
    final password = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SkinXDialog(
        title: 'Set a new password',
        icon: Icons.lock_reset_rounded,
        content: TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password (at least 8 characters)'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AuthService.passwordRecoveryPending.value = false;
              Navigator.pop(dialogContext);
            },
            child: const SkinXText('Later'),
          ),
          FilledButton(
            onPressed: () async {
              if (password.text.length < 8) {
                _showError('Use at least 8 characters.');
                return;
              }
              try {
                await AuthService.updatePassword(password.text);
                AuthService.passwordRecoveryPending.value = false;
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (_) {
                _showError('Could not update password. Try again.');
              }
            },
            child: const SkinXText('Update password'),
          ),
        ],
      ),
    ).whenComplete(() {
      password.dispose();
      _passwordDialogOpen = false;
    });
  }

  Future<void> _loadHistory() async {
    try {
      final owner = AuthService.ownerId;
      final data = await _history.getAll(owner);
      if (owner != AuthService.ownerId) return;
      if (!mounted) return;
      setState(() => _records = data.map((row) => ScreeningRecord(
        id: row['id'] as int,
        patientName: (row['patient_name'] as String?)?.trim().isNotEmpty == true
            ? row['patient_name'] as String
            : (_isCommunityHealthWorker ? 'Unnamed earlier screening' : 'My screening'),
        savedAt: DateTime.parse(row['created_at'] as String).toLocal(),
        savedDetails: row['result'] as String,
        thumbnailAsset: '',
      )).toList());
      if (_history.lastSyncError != null && !_syncErrorShown && mounted) {
        _syncErrorShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showError(_history.lastSyncError ?? 'Cloud sync unavailable.');
        });
      } else if (_history.lastSyncError == null) {
        _syncErrorShown = false;
      }
    } catch (_) {
      if (mounted) _showError('Could not open local screening history.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    SkinXNotice.show(context, message, error: true);
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
      builder: (_) => const Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: Color(0xFF14665E)),
            SizedBox(width: 18),
            Expanded(child: SkinXText('Checking photo...', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF193B38)))),
          ]),
        ),
      ));
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
        communityHealthWorker: _isCommunityHealthWorker,
        initialPatientName: _isCommunityHealthWorker ? _patientNameController.text : '',
        onSave: (name) async {
          await _history.save(
            ownerId: AuthService.ownerId,
            result: result.status,
            patientName: name,
            communityHealthWorker: _isCommunityHealthWorker,
          );
          _patientNameController.clear();
          if (mounted) setState(() {
            _photoBytes = null;
            _confirmedSkinPhoto = false;
          });
          await _loadHistory();
        },
      ),
    ));
  }

  Future<void> _showRecord(ScreeningRecord record) async {
    final isSuspicious = record.savedDetails == ScreeningResult.suspicious;
    final delete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => SkinXDialog(
        title: 'Saved screening',
        icon: Icons.assignment_outlined,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              SkinXText(record.patientName, style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuspicious ? const Color(0xFFFFF2E8) : const Color(0xFFEAF2E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(isSuspicious ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                    color: isSuspicious ? const Color(0xFFA85E22) : const Color(0xFF14665E)),
                  const SizedBox(width: 10),
                  Expanded(child: SkinXText(record.savedDetails,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.event_outlined, size: 18, color: Color(0xFF647D78)),
                const SizedBox(width: 8),
                Expanded(child: SkinXText(
                  MaterialLocalizations.of(dialogContext).formatMediumDate(record.savedAt) +
                    ' · ' + MaterialLocalizations.of(dialogContext).formatTimeOfDay(
                      TimeOfDay.fromDateTime(record.savedAt)),
                  style: const TextStyle(color: Color(0xFF647D78), fontSize: 13))),
              ]),
              const SizedBox(height: 14),
              const SkinXText('This result is not a diagnosis. No photo was saved.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF647D78))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false),
            child: const SkinXText('Close')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF9B4238)),
            child: const SkinXText('Delete record'),
          ),
        ],
      ),
    );
    if (delete == true && record.id != null) {
      try {
        await _history.remove(ownerId: AuthService.ownerId, id: record.id!);
        await _loadHistory();
      } catch (_) {
        _showError('Could not delete this screening record.');
      }
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
      ConnectivityService.instance.refresh().then((_) {
        if (ConnectivityService.instance.online && mounted) _loadHistory();
      });
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
    ConnectivityService.instance.removeListener(_syncWhenOnline);
    _authSubscription?.cancel();
    AuthService.passwordRecoveryPending.removeListener(_maybeShowPasswordRecovery);
    _model.close();
    _patientNameController.dispose();
    super.dispose();
  }


  void _openPrivacyConsent() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const PrivacyConsentScreen(),
    ));
  }

  void _openGuide(String id) {
    final guide = offlineGuideById(id);
    if (guide == null) return;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => EducationGuideScreen(guide: guide),
    ));
  }

  void _showVideos() {
    if (!ConnectivityService.instance.online) {
      _showError('Internet is required to watch these videos.');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const VideosScreen(),
    ));
  }

  Future<void> _showFeaturedVideo() async {
    if (!ConnectivityService.instance.online) {
      _showError('Internet is required to watch these videos.');
      return;
    }
    await VideosScreen.openVideo(context, VideosScreen.videos.first.url);
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
      animation: Listenable.merge([ConnectivityService.instance, AppLanguage.instance]),
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
                      onFeaturedGuideTap: () => _openGuide('sun_protection'),
                      onSkinChangesTap: () => _openGuide('skin_changes'),
                      onSeekCareTap: () => _openGuide('seek_care'),
                      onAllVideosTap: _showVideos,
                      onVideoTap: _showFeaturedVideo,
                    ),
                    HistoryScreen(records: _records, onRecordTap: _showRecord),
                    ScreeningScreen(
                      showPatientName: _isCommunityHealthWorker,
                      patientNameController: _patientNameController,
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
                            isGuest: AuthService.user == null,
                            name: _profile?['full_name']?.toString() ?? AuthService.user?.userMetadata?['full_name']?.toString() ?? 'Offline guest',
                            email: AuthService.user?.email ?? 'No account required',
                            profileTitle: AuthService.user == null
                                ? (ConnectivityService.instance.online
                                    ? 'Guest mode'
                                    : 'Offline mode')
                                : 'SkinX account',
                            profileSubtitle: AuthService.user == null
                                ? 'Offline features are available without an account'
                                : 'Signed in',
                            initialRole: _isCommunityHealthWorker
                                ? SkinXAccountType.communityHealthWorker
                                : SkinXAccountType.individual,
                            onLanguageTap: () => AppLanguage.choose(context),
                            actionLabel: AuthService.user == null
                                ? 'Sign in (online)'
                                : 'Sign out',
                            accountActionAvailable: ConnectivityService.instance.online,
                            onSignOutTap:
                                AuthService.user == null ? _openSignIn : _signOut,
                            onPrivacyConsentTap: _openPrivacyConsent,
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
