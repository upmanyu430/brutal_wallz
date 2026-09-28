import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class BrutalButton extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const BrutalButton({
    super.key,
    required this.child,
    required this.color,
    required this.shadowOffset,
    required this.onTap,
    this.decoration,
    this.isActive = false,
    this.borderWidth = 4.0,
  });

  final Widget child;

  final Color color;

  final double shadowOffset;

  final void Function() onTap;

  final BoxDecoration? decoration;

  final bool isActive;

  final double borderWidth;

  @override
  State<BrutalButton> createState() {
    return _BrutalButtonState();
  }
}

@NowaGenerated()
class _BrutalButtonState extends State<BrutalButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final active = isPressed || widget.isActive;
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          active ? widget.shadowOffset : 0,
          active ? widget.shadowOffset : 0,
          0,
        ),
        decoration: (widget.decoration ?? const BoxDecoration()).copyWith(
          color: widget.decoration == null ? widget.color : null,
          border: Border.all(color: Colors.black, width: widget.borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: active
                  ? Offset.zero
                  : Offset(widget.shadowOffset, widget.shadowOffset),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
