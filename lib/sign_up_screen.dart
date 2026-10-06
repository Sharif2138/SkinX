import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sign_in_screen.dart';
import 'widgets/skinx_account_type_selector.dart';
import 'widgets/skinx_auth_field.dart';
import 'widgets/skinx_header.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
    this.onSignUp,
    this.onSignInTap,
    this.initialAccountType = SkinXAccountType.individual,
    this.languageCode = 'EN',
    this.onLanguageTap,
  });

  final void Function(String fullName, String email, String password, SkinXAccountType accountType)? onSignUp;
  final VoidCallback? onSignInTap;
  final SkinXAccountType initialAccountType;
  final String languageCode;
  final VoidCallback? onLanguageTap;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late SkinXAccountType _accountType = widget.initialAccountType;
  bool _hidePassword = true;
  bool _hideConfirmation = true;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    widget.onSignUp?.call(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _accountType,
    );
  }

  void _openSignIn() {
    if (widget.onSignInTap != null) {
      widget.onSignInTap!();
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => SignInScreen(languageCode: widget.languageCode, onLanguageTap: widget.onLanguageTap),
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
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
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkinXHeader(languageCode: widget.languageCode, onLanguageTap: widget.onLanguageTap),
                        const SizedBox(height: 26),
                        Text('Create your account', style: _type(24, weight: FontWeight.w700, height: 1.2)),
                        const SizedBox(height: 4),
                        Text('Start your skin-health journey with SkinX.', style: _type(14, color: _muted, height: 1.4)),
                        const SizedBox(height: 22),
                        Text('Account type', style: _type(13, weight: FontWeight.w600, height: 1.3)),
                        const SizedBox(height: 8),
                        SkinXAccountTypeSelector(
                          value: _accountType,
                          onChanged: (value) => setState(() => _accountType = value),
                        ),
                        const SizedBox(height: 28),
                        SkinXAuthField(
                          label: 'Full name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) => (value ?? '').trim().isEmpty ? 'Enter your full name.' : null,
                        ),
                        const SizedBox(height: 16),
                        SkinXAuthField(
                          label: 'Email',
                          hint: 'Enter your email address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        SkinXAuthField(
                          label: 'Password',
                          hint: 'Create a password',
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          onVisibilityTap: () => setState(() => _hidePassword = !_hidePassword),
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) => (value ?? '').length < 8 ? 'Use at least 8 characters.' : null,
                        ),
                        const SizedBox(height: 8),
                        Text('Use at least 8 characters.', style: _type(12, color: _muted, height: 1.35)),
                        const SizedBox(height: 18),
                        SkinXAuthField(
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          controller: _confirmController,
                          obscureText: _hideConfirmation,
                          onVisibilityTap: () => setState(() => _hideConfirmation = !_hideConfirmation),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          validator: (value) {
                            if ((value ?? '').isEmpty) return 'Confirm your password.';
                            if (value != _passwordController.text) return 'Passwords do not match.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _teal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: const StadiumBorder(),
                              textStyle: _type(14, weight: FontWeight.w600),
                            ),
                            child: const Text('Sign up'),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Text('Already have an account?', style: _type(12.5, color: _muted)),
                              InkWell(
                                onTap: _openSignIn,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('Sign in', style: _type(12.5, color: _teal, weight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Enter a valid email address.';
  return null;
}

TextStyle _type(double size, {Color color = _ink, FontWeight weight = FontWeight.w400, double height = 1.4}) {
  return TextStyle(fontFamily: 'Roboto', fontSize: size, fontWeight: weight, color: color, height: height);
}
