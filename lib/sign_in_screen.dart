import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sign_up_screen.dart';
import 'widgets/skinx_auth_field.dart';
import 'widgets/skinx_header.dart';
import 'widgets/skinx_icon.dart';

const _ink = Color(0xFF193B38);
const _teal = Color(0xFF14665E);
const _muted = Color(0xFF647D78);

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    this.onSignIn,
    this.onSignUpTap,
    this.onForgotPasswordTap,
    this.languageCode = 'EN',
    this.onLanguageTap,
  });

  final void Function(String email, String password)? onSignIn;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotPasswordTap;
  final String languageCode;
  final VoidCallback? onLanguageTap;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    widget.onSignIn?.call(_emailController.text.trim(), _passwordController.text);
  }

  void _openSignUp() {
    if (widget.onSignUpTap != null) {
      widget.onSignUpTap!();
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => SignUpScreen(languageCode: widget.languageCode, onLanguageTap: widget.onLanguageTap),
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      // Keep the tip at the bottom; allow scrolling with the keyboard open.
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutofillGroup(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkinXHeader(languageCode: widget.languageCode, onLanguageTap: widget.onLanguageTap),
                                    const SizedBox(height: 26),
                                    Text('Welcome back', style: _type(24, weight: FontWeight.w700, height: 1.2)),
                                    const SizedBox(height: 4),
                                    Text('Sign in to continue your skin-health journey.', style: _type(14, color: _muted, height: 1.4)),
                                    const SizedBox(height: 24),
                                    SkinXAuthField(
                                      label: 'Email',
                                      hint: 'Enter your email address',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      autofillHints: const [AutofillHints.username],
                                      validator: _validateEmail,
                                    ),
                                    const SizedBox(height: 20),
                                    SkinXAuthField(
                                      label: 'Password',
                                      hint: 'Enter your password',
                                      controller: _passwordController,
                                      obscureText: _hidePassword,
                                      onVisibilityTap: () => setState(() => _hidePassword = !_hidePassword),
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.password],
                                      onSubmitted: (_) => _submit(),
                                      validator: (value) => (value ?? '').isEmpty ? 'Enter your password.' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: InkWell(
                                        onTap: widget.onForgotPasswordTap,
                                        borderRadius: BorderRadius.circular(6),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Text('Forgot password?', style: _type(12.5, color: _teal, weight: FontWeight.w500)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
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
                                        child: const Text('Sign in'),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Center(
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Text('New to SkinX?', style: _type(12.5, color: _muted)),
                                          InkWell(
                                            onTap: _openSignUp,
                                            borderRadius: BorderRadius.circular(6),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text('Sign up', style: _type(12.5, color: _teal, weight: FontWeight.w600)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: const Color(0xFFEAF2E9), borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SkinXIcon(SkinXIconType.book, size: 18),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Small steps for healthier skin', style: _type(12.5, weight: FontWeight.w600, height: 1.4)),
                                          const SizedBox(height: 3),
                                          Text('Explore skin-health guides in Learn after you sign in.', style: _type(12.5, color: _muted, height: 1.45)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
