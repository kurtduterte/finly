import 'package:finly/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(kRadius12),
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed == null
                  ? [cs.outline, cs.outline]
                  : [cs.primary, cs.inversePrimary],
            ),
            borderRadius: BorderRadius.circular(kRadius12),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(kRadius12),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
