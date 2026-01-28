import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:mobile_reporting/localization/generated/l10n.dart";

class LanguageOption {
  final String code;
  final String label;
  final String svgAsset;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.svgAsset,
  });
}

const List<LanguageOption> availableLanguages = [
  LanguageOption(
      code: 'en', label: 'ENG', svgAsset: 'assets/icons/flags/en.svg'),
  LanguageOption(
      code: 'ka', label: 'GEO', svgAsset: 'assets/icons/flags/ge.svg'),
];

void showProfilePopover({
  required BuildContext context,
  required String name,
  required String email,
  required String currentLangCode,
  required VoidCallback onLogout,
  required void Function(String langCode) onLanguageChanged,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "profile_popover",
    barrierColor: Colors.black.withOpacity(0.25),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (_, __, ___) {
      return SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // Tap outside to close
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.translucent,
                  child: const SizedBox.expand(),
                ),
              ),

              // Popover (top-right)
              Positioned(
                top: 64,
                right: 16,
                child: _ProfilePopover(
                  name: name,
                  email: email,
                  currentLangCode: currentLangCode,
                  onLanguageChanged: (langCode) {
                    Navigator.of(context).pop();
                    onLanguageChanged(langCode);
                  },
                  onLogout: () {
                    Navigator.of(context).pop();
                    onLogout();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (_, anim, __, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ProfilePopover extends StatefulWidget {
  const _ProfilePopover({
    required this.name,
    required this.email,
    required this.currentLangCode,
    required this.onLogout,
    required this.onLanguageChanged,
  });

  final String name;
  final String email;
  final String currentLangCode;
  final VoidCallback onLogout;
  final void Function(String langCode) onLanguageChanged;

  @override
  State<_ProfilePopover> createState() => _ProfilePopoverState();
}

class _ProfilePopoverState extends State<_ProfilePopover> {
  bool _showLanguageDropdown = false;

  LanguageOption get _currentLanguage {
    return availableLanguages.firstWhere(
      (lang) => lang.code == widget.currentLangCode,
      orElse: () => availableLanguages.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(18);

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Arrow (little speech-bubble pointer)
          Positioned(
            top: -10,
            right: 18,
            child: CustomPaint(
              size: const Size(18, 12),
              painter: _PopoverArrowPainter(color: Colors.white),
            ),
          ),

          // Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: cardRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: cardRadius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top user row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF1FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF2F6BFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                  // Language row
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showLanguageDropdown = !_showLanguageDropdown;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              S.of(context).language,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SvgPicture.asset(
                              _currentLanguage.svgAsset,
                              width: 20,
                              height: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentLanguage.label,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: _showLanguageDropdown ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 22,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Language dropdown
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildLanguageDropdown(),
                    crossFadeState: _showLanguageDropdown
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),

                  const Divider(
                      height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

                  // Logout button (soft red)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(
                          S.of(context).logout,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFFE8E8),
                          foregroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: availableLanguages.map((lang) {
          final isSelected = lang.code == widget.currentLangCode;
          return InkWell(
            onTap: () {
              widget.onLanguageChanged(lang.code);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFFEAF1FF) : Colors.transparent,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SvgPicture.asset(
                      lang.svgAsset,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lang.code == 'en'
                          ? S.of(context).english
                          : S.of(context).georgian,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2F6BFF)
                            : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(0xFF2F6BFF),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PopoverArrowPainter extends CustomPainter {
  _PopoverArrowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
