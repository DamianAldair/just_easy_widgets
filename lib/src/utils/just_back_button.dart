import 'package:flutter/material.dart';
import 'package:just_easy_widgets/just_easy_widgets.dart';

class JustBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const JustBackButton({
    Key? key,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return JustButton.onlyIcon(
      icon: const Icon(Icons.chevron_left_rounded),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!.call();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

class JustCloseButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;

  const JustCloseButton({
    Key? key,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return JustButton.onlyIcon(
      icon: const Icon(Icons.close_rounded),
      color: color,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!.call();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}
