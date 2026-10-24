import 'package:flutter/material.dart';

import 'skinx_icon.dart';

class SkinXAuthField extends StatelessWidget {
  const SkinXAuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.onVisibilityTap,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final VoidCallback? onVisibilityTap;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: Color(0xFFE1EAE2)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF193B38),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            autofillHints: autofillHints,
            autocorrect: false,
            enableSuggestions: onVisibilityTap == null,
            cursorColor: const Color(0xFF14665E),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            style: const TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Color(0xFF193B38), height: 1.4),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Color(0xFF647D78), height: 1.4),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(borderSide: const BorderSide(color: Color(0xFF14665E))),
              errorMaxLines: 3,
              suffixIcon: onVisibilityTap == null
                  ? null
                  : IconButton(
                      tooltip: obscureText ? 'Show password' : 'Hide password',
                      onPressed: onVisibilityTap,
                      icon: SkinXIcon(
                        obscureText ? SkinXIconType.eyeOff : SkinXIconType.eye,
                        size: 20,
                        color: const Color(0xFF647D78),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
