import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'skinx_icon.dart';

class SkinXHeader extends StatelessWidget {
  const SkinXHeader({
    super.key,
    this.languageCode = 'EN',
    this.onLanguageTap,
  });

  final String languageCode;
  final VoidCallback? onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SvgPicture.asset('assets/skinx_logo.svg', width: 20, height: 20),
          const SizedBox(width: 10),
          const Text(
            'skinX',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Color(0xFF193B38),
              height: 1.25,
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'Change language, $languageCode',
            button: true,
            child: InkWell(
              onTap: onLanguageTap,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SkinXIcon(SkinXIconType.globe, size: 17),
                    const SizedBox(width: 6),
                    Text(
                      languageCode,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: Color(0xFF14665E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const SkinXIcon(SkinXIconType.chevronDown, size: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
