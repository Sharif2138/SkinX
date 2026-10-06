import 'package:flutter/material.dart';

import 'widgets/skinx_account_type_selector.dart';
import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';
import 'splash_screen.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);
const _border = Color(0xFFE1EAE2);

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    this.name,
    this.email,
    this.profileTitle = 'Example account',
    this.profileSubtitle = 'Illustrative profile · no personal data',
    this.initialRole = SkinXAccountType.individual,
    this.onRoleChanged,
    this.languageCode = 'EN',
    this.languageName = 'English',
    this.onLanguageTap,
    this.onPrivacyConsentTap,
    this.onSignOutTap,
  });

  final String? name;
  final String? email;
  final String profileTitle;
  final String profileSubtitle;
  final SkinXAccountType initialRole;
  final ValueChanged<SkinXAccountType>? onRoleChanged;
  final String languageCode;
  final String languageName;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onPrivacyConsentTap;
  final VoidCallback? onSignOutTap;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late SkinXAccountType _role = widget.initialRole;

  @override
  void didUpdateWidget(covariant AccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRole != widget.initialRole) _role = widget.initialRole;
  }

  void _changeRole(SkinXAccountType role) {
    setState(() => _role = role);
    widget.onRoleChanged?.call(role);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkinXHeader(languageCode: widget.languageCode, onLanguageTap: widget.onLanguageTap),
                const SizedBox(height: 20),
                Text('Account', style: _type(24, weight: FontWeight.w700, height: 1.2)),
                const SizedBox(height: 4),
                Text('Your details and account preferences.', style: _type(14, color: _muted, height: 1.4)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0E7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(color: Color(0xFFC5DCC2), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const SkinXIcon(SkinXIconType.account, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.profileTitle, style: _type(16, weight: FontWeight.w700, height: 1.3)),
                            const SizedBox(height: 2),
                            Text(widget.profileSubtitle, style: _type(12, color: _muted, height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Text('Account role', style: _type(14, weight: FontWeight.w600, height: 1.3))),
                    const SizedBox(width: 10),
                    Text('Example selection', style: _type(12, color: _muted, height: 1.3)),
                  ],
                ),
                const SizedBox(height: 8),
                SkinXAccountTypeSelector(value: _role, onChanged: _changeRole),
                const SizedBox(height: 20),
                Text('Account details', style: _type(14, weight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Name', value: _detailValue(widget.name)),
                      Container(height: 1, color: _border),
                      _DetailRow(label: 'Email', value: _detailValue(widget.email)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _PreferenceRow(
                        icon: SkinXIconType.globe,
                        title: 'Language',
                        value: widget.languageName,
                        onTap: widget.onLanguageTap,
                      ),
                      Container(height: 1, color: _border),
                      _PreferenceRow(
                        icon: SkinXIconType.shieldCheck,
                        title: 'Privacy & consent',
                        onTap: widget.onPrivacyConsentTap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 54),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SkinXIcon(SkinXIconType.signOut, size: 20),
                            const SizedBox(width: 10),
                            Text('Sign out', style: _type(14, color: _teal, weight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'SkinX · AI-assisted skin screening\nCapstone by Sharif Kiviiri',
                    textAlign: TextAlign.center,
                    style: _type(12, color: _muted, height: 1.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _type(14, height: 1.3))),
          const SizedBox(width: 12),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: _type(13.5, color: _muted, height: 1.3))),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.icon, required this.title, this.value, this.onTap});

  final SkinXIconType icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            SkinXIcon(icon, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: _type(14, height: 1.3))),
            if (value != null) ...[
              const SizedBox(width: 8),
              Flexible(child: Text(value!, textAlign: TextAlign.right, style: _type(13.5, color: _muted, height: 1.3))),
            ],
            const SizedBox(width: 12),
            const SkinXIcon(SkinXIconType.chevronRight, size: 14),
          ],
        ),
      ),
    );
  }
}

String _detailValue(String? value) => value == null || value.trim().isEmpty ? 'Not provided' : value;

TextStyle _type(double size, {Color color = _ink, FontWeight weight = FontWeight.w400, double height = 1.4}) {
  return TextStyle(fontFamily: 'Roboto', fontSize: size, fontWeight: weight, color: color, height: height);
}
