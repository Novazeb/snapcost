import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'haptic_feedback.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isDanger;
  final bool isLoading;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isDanger = false,
    this.isLoading = false,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    if (isDanger) {
      bg = AppColors.danger;
      fg = Colors.white;
    } else if (isSecondary) {
      bg = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;
      fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    } else {
      bg = isDark ? AppColors.darkAccent : AppColors.lightTextPrimary;
      fg = isDark ? AppColors.darkBackground : Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (onPressed != null && !isLoading)
            ? () {
                AppHaptic.lightImpact();
                onPressed!();
              }
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: (onPressed == null && !isLoading) ? bg.withOpacity(0.5) : bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: isSecondary
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  )
                : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: fg,
                          letterSpacing: -0.2,
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
