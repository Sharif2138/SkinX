import 'package:flutter/material.dart';

enum SkinXAccountType { individual, communityHealthWorker }

class SkinXAccountTypeSelector extends StatelessWidget {
  const SkinXAccountTypeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SkinXAccountType value;
  final ValueChanged<SkinXAccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _option(
          SkinXAccountType.individual,
          'Individual',
          'For your own skin-health care',
        ),
        const SizedBox(height: 8),
        _option(
          SkinXAccountType.communityHealthWorker,
          'Community health worker',
          'For supporting patient screenings',
        ),
      ],
    );
  }

  Widget _option(SkinXAccountType type, String title, String subtitle) {
    final selected = value == type;
    const teal = Color(0xFF14665E);

    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      onTap: () => onChanged(type),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? const Color(0xFF9CCEA7) : const Color(0xFFE1EAE2)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(type),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF193B38),
                          height: 1.3,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Color(0xFF647D78),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? teal : const Color(0xFFC1D0C0), width: selected ? 1.8 : 1),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? teal : Colors.transparent,
                    ),
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
