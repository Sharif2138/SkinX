import 'package:flutter/material.dart';

import 'skinx_icon.dart';

enum SkinXDestination { learn, history, screen, ask, account }

class SkinXBottomNavigationBar extends StatelessWidget {
  const SkinXBottomNavigationBar({
    super.key,
    required this.selectedDestination,
    required this.onTap,
  });

  final SkinXDestination selectedDestination;
  final ValueChanged<SkinXDestination> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Stack(
            children: [
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Container(height: 1, color: const Color(0xFFF3F5F2)),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        _item(SkinXDestination.learn, 'Learn', SkinXIconType.book),
                        _item(SkinXDestination.history, 'History', SkinXIconType.history),
                        _item(SkinXDestination.screen, 'Screen', SkinXIconType.scan, raised: true),
                        _item(SkinXDestination.ask, 'Ask', SkinXIconType.chat),
                        _item(SkinXDestination.account, 'Account', SkinXIconType.account),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    SkinXDestination destination,
    String label,
    SkinXIconType icon, {
    bool raised = false,
  }) {
    final selected = selectedDestination == destination;
    final color = selected ? const Color(0xFF14665E) : const Color(0xFF8C9D9B);

    return Expanded(
      child: Semantics(
        label: label,
        button: true,
        selected: selected,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => onTap(destination),
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 82,
            child: Column(
              children: [
                SizedBox(height: raised ? 2 : 31),
                if (raised)
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14665E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: SkinXIcon(icon, size: 27, color: Colors.white),
                  )
                else
                  Container(
                    width: 45,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFFEAF2E9) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: SkinXIcon(icon, size: 24, color: color),
                  ),
                SizedBox(height: raised ? 10 : 7),
                Text(
                  label,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10.5,
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.25,
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
