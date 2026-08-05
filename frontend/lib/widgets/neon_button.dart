import 'package:flutter/material.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';

/// A glowing neon-styled button with press animation.
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = CyberpunkColors.primary,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.isLoading ? null : widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: widget.isOutlined
                  ? Colors.transparent
                  : widget.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.color.withValues(alpha: _glowAnimation.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.color.withValues(alpha: _glowAnimation.value * 0.3),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.color,
                    ),
                  )
                else if (widget.icon != null)
                  Icon(widget.icon, color: widget.color, size: 18),
                if (widget.icon != null || widget.isLoading)
                  const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
