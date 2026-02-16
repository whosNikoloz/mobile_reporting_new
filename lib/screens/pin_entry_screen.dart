import 'package:flutter/material.dart';
import 'package:mobile_reporting/helpers/helpers_module.dart';
import 'package:mobile_reporting/helpers/preferences_helper.dart';
import 'package:mobile_reporting/localization/generated/l10n.dart';
import 'package:mobile_reporting/screens/sign_in_screen.dart';
import 'package:mobile_reporting/theme/app_theme.dart';
import 'package:mobile_reporting/widgets/main_navigation.dart';
import 'package:mobile_reporting/services/pin_auth_service.dart';

class PinEntryScreen extends StatefulWidget {
  const PinEntryScreen({super.key});

  @override
  State<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<PinEntryScreen> {
  final List<int> _digits = [];
  final PinAuthService _pinAuthService = PinAuthService();
  bool _isLoading = false;

  void _onNumberTap(int number) {
    if (_digits.length == 4) return;
    setState(() {
      _digits.add(number);
    });

    if (_digits.length == 4) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    setState(() {
      _digits.removeLast();
    });
  }

  Future<void> _submitPin() async {
    if (_isLoading || _digits.length != 4) return;

    setState(() {
      _isLoading = true;
    });

    final pin = _digits.join();

    final result = await _pinAuthService.authenticatePin(pin);

    if (result == null || result.hasError) {
      if (mounted) {
        _showError('Incorrect PIN');
        setState(() {
          _isLoading = false;
          _digits.clear();
        });
      }
      return;
    }

    await getIt<PreferencesHelper>().setPinUserId(result.id);
    await getIt<PreferencesHelper>().setPinUserName(result.name);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _digits.clear();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final bool isFilled = index < _digits.length;
        return Container(
          width: 46,
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFilled ? AppTheme.primaryBlue : Colors.grey.shade300,
              width: 1.5,
            ),
            color: isFilled
                ? AppTheme.primaryBlue.withOpacity(0.05)
                : Colors.white,
          ),
          alignment: Alignment.center,
          child: isFilled
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryBlue,
                  ),
                )
              : const SizedBox.shrink(),
        );
      }),
    );
  }

  Widget _buildNumberButton({required String label, VoidCallback? onTap}) {
    final bool isNumber = int.tryParse(label) != null;

    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 90,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isNumber && label == '2'
              ? AppTheme.primaryBlue.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isNumber
            ? Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  color: label == '2' ? AppTheme.primaryBlue : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              )
            : label == 'backspace'
                ? const Icon(
                    Icons.backspace_outlined,
                    size: 22,
                    color: Colors.black87,
                  )
                : const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Icon(
              Icons.lock_outline,
              size: 60,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 8),
            Text(
              S.of(context).logIn,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 32),
            _buildPinBoxes(),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  const SizedBox(height: 16),
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                    ['', '0', 'backspace'],
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((label) {
                          if (label.isEmpty) {
                            return const SizedBox(width: 70, height: 70);
                          }

                          if (label == 'backspace') {
                            return _buildNumberButton(
                              label: label,
                              onTap: _onBackspace,
                            );
                          }

                          return _buildNumberButton(
                            label: label,
                            onTap: () => _onNumberTap(int.parse(label)),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                // Full company change: clear all company-related data
                await getIt<PreferencesHelper>().clearCompanyName();
                await getIt<PreferencesHelper>().clearType();
                await getIt<PreferencesHelper>().clearUserAuthToken();
                await getIt<PreferencesHelper>().clearUserName();
                await getIt<PreferencesHelper>().clearEmail();
                await getIt<PreferencesHelper>().clearAccountLang();
                await getIt<PreferencesHelper>().clearDatabase();
                await getIt<PreferencesHelper>().clearUrl();
                await getIt<PreferencesHelper>().clearPinUserId();
                await getIt<PreferencesHelper>().clearPinUserName();

                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Change Company',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
