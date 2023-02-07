import 'package:flutter/widgets.dart';

class JustAnimatedIcon extends StatelessWidget {
  final Icon icon;
  final Icon? secondIcon;
  final Animation<double> progress;

  const JustAnimatedIcon({
    Key? key,
    required this.icon,
    required this.secondIcon,
    required this.progress,
  })  : assert(secondIcon != null),
        super(key: key);

  const JustAnimatedIcon.rotate({
    Key? key,
    required this.icon,
    required this.progress,
  })  : secondIcon = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        Widget child;

        if (secondIcon != null) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 1 - progress.value,
                child: icon,
              ),
              Opacity(
                opacity: progress.value,
                child: secondIcon,
              ),
            ],
          );
        } else {
          child = Transform.rotate(
            angle: progress.value,
            child: icon,
          );
        }

        return child;
      },
    );
  }
}
