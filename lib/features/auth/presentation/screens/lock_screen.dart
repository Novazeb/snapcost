import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/haptic_feedback.dart';
import '../../../../services/biometric_service.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    final success = await BiometricService.authenticate();

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
      });

      if (success) {
        AppHaptic.successNotification();
        widget.onUnlocked();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'SnapCost Terkunci',
                style: AppTypography.titleLarge(isDark: isDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Gunakan FaceID atau Sidik Jari untuk melanjutkan',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(isDark: isDark),
              ),
              const Spacer(),
              CustomButton(
                label: 'Buka dengan Biometrik',
                icon: Icons.fingerprint_rounded,
                isLoading: _isAuthenticating,
                onPressed: _authenticate,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
