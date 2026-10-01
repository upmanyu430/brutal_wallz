import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

/// A custom neo-brutalist styled button featuring high-contrast borders,
/// hard offset drop shadows (no blur), and physical translation animations upon interaction.
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

  /// The widget content rendered inside the button (e.g. text or icon).
  final Widget child;

  /// Background fill color when no custom [decoration] is supplied.
  final Color color;

  /// The distance (in pixels) the hard shadow extends diagonally when unpressed.
  final double shadowOffset;

  /// Callback triggered when the user taps and releases the button.
  final void Function() onTap;

  /// Optional custom decoration to override or augment background and border styling.
  final BoxDecoration? decoration;

  /// Whether the button is locked in an active/pressed state (e.g., in navigation bars).
  final bool isActive;

  /// Width of the solid black border surrounding the button.
  final double borderWidth;

  @override
  State<BrutalButton> createState() {
    return _BrutalButtonState();
  }
}

@NowaGenerated()
class _BrutalButtonState extends State<BrutalButton> {
  /// Tracks whether the button is currently held down by the user.
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Button is rendered in pressed state if tapped or marked active externally
    final active = isPressed || widget.isActive;

    return GestureDetector(
      // When tap starts, sink the button into its shadow
      onTapDown: (_) => setState(() => isPressed = true),
      // When tap completes, reset position and fire the callback
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onTap();
      },
      // When tap is aborted/cancelled, reset position without triggering onTap
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        // Translate button down and right by shadowOffset when active to simulate tactile physical click
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
              // Shadow collapses to zero offset when pressed as button translates into it
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
