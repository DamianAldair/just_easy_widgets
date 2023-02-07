import 'package:flutter/material.dart';

class JustButton extends StatefulWidget {
  final Widget icon;
  final Widget child;
  final Widget label;
  final double spaceBetween;
  final void Function() onPressed;
  final void Function()? onLongPress;
  final String? tooltip;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final Color? colorWhenOnPressed;
  final List<double>? opacities;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const JustButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.padding = const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
    this.margin = const EdgeInsets.all(8.0),
    this.color,
    this.colorWhenOnPressed,
    this.opacities,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 100),
  })  : icon = const SizedBox.shrink(),
        label = const SizedBox.shrink(),
        spaceBetween = 0.0,
        tooltip = null,
        super(key: key);

  const JustButton.withIcon({
    Key? key,
    required this.icon,
    required this.label,
    this.spaceBetween = 6.0,
    required this.onPressed,
    this.onLongPress,
    this.padding =
        const EdgeInsets.only(top: 6.0, left: 6.0, right: 13.0, bottom: 6.0),
    this.margin = const EdgeInsets.all(8.0),
    this.color,
    this.colorWhenOnPressed,
    this.opacities,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 100),
  })  : child = const SizedBox.shrink(),
        tooltip = null,
        super(key: key);

  const JustButton.onlyIcon({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.tooltip,
    this.padding = const EdgeInsets.all(6.0),
    this.margin = const EdgeInsets.all(8.0),
    this.color,
    this.colorWhenOnPressed,
    this.opacities,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 100),
  })  : child = const SizedBox.shrink(),
        label = const SizedBox.shrink(),
        spaceBetween = 0.0,
        super(key: key);

  @override
  State<JustButton> createState() => _JustButtonState();
}

class _JustButtonState extends State<JustButton> {
  bool buttonPressed = false;

  @override
  Widget build(BuildContext context) {
    const defaultColor = Colors.grey;
    List<double> opacities = [0.5, 0.8];
    if (widget.opacities != null) {
      if (widget.opacities!.length > 2 || widget.opacities!.isEmpty) {
        throw RangeError('opacities\' lenght must be 1 or 2');
      } else if (widget.opacities!.length == 1) {
        final temp = widget.opacities![0];
        opacities = [temp, temp];
      } else {
        opacities = widget.opacities!;
      }
    }
    final color = (widget.color ?? defaultColor).withOpacity(opacities[0]);
    final colorWhenOnPressed =
        (widget.colorWhenOnPressed ?? defaultColor).withOpacity(opacities[1]);

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.icon,
        SizedBox(width: widget.spaceBetween),
        widget.label,
        widget.child,
      ],
    );

    child = AnimatedContainer(
      duration: widget.animationDuration,
      decoration: BoxDecoration(
        color: buttonPressed ? colorWhenOnPressed : color,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: widget.padding,
        child: child,
      ),
    );

    if (widget.tooltip != null) {
      child = Tooltip(
        message: widget.tooltip,
        child: child,
      );
    }

    return Padding(
      padding: widget.margin,
      child: GestureDetector(
        onTapDown: (_) => setState(() => buttonPressed = true),
        onTapUp: (_) => setState(() => buttonPressed = false),
        onTapCancel: () => setState(() => buttonPressed = false),
        onLongPressUp: () => setState(() => buttonPressed = false),
        onLongPressCancel: () => setState(() => buttonPressed = false),
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: child,
      ),
    );
  }
}
