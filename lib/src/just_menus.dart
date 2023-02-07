import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_easy_widgets/just_easy_widgets.dart';

typedef JustPopupMenuOpened = void Function();
typedef JustPopupMenuItemSelected<T> = void Function(T value);
typedef JustPopupMenuCanceled = void Function();

class JustPopupMenu<T> extends StatefulWidget {
  final Widget child;
  final Widget? icon;
  final bool isButton;
  final List<PopupMenuEntry<T>> items;
  final JustPopupMenuOpened? onOpened;
  final JustPopupMenuItemSelected? onSelected;
  final JustPopupMenuCanceled? onCanceled;
  final BorderRadius? menuBorderRadius;
  final Color menuColor;

  const JustPopupMenu({
    Key? key,
    required this.child,
    required this.items,
    this.menuBorderRadius,
    this.menuColor = const Color.fromARGB(220, 230, 230, 230),
    this.onOpened,
    this.onSelected,
    this.onCanceled,
  })  : icon = null,
        isButton = false,
        super(key: key);

  const JustPopupMenu.button({
    Key? key,
    this.icon,
    required this.items,
    this.menuBorderRadius,
    this.menuColor = const Color.fromARGB(220, 230, 230, 230),
    this.onOpened,
    this.onSelected,
    this.onCanceled,
  })  : child = const SizedBox.shrink(),
        isButton = true,
        super(key: key);

  @override
  State<JustPopupMenu<T>> createState() => _JustPopupMenuState<T>();
}

class _JustPopupMenuState<T> extends State<JustPopupMenu<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController iconController;
  double dy = 5.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => dy = widget.isButton
          ? 5.0
          : (context.findRenderObject()! as RenderBox).size.height / 3);
    });
    iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void dispose() {
    iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (widget.isButton) {
      child = AbsorbPointer(
        child: JustButton.onlyIcon(
          icon: widget.icon ??
              JustAnimatedIcon(
                icon: const Icon(Icons.more_horiz_rounded),
                secondIcon: const Icon(Icons.arrow_drop_up_rounded),
                progress: Tween(begin: 0.0, end: 1.0).animate(iconController),
              ),
          onPressed: () {},
        ),
      );
    } else {
      child = widget.child;
    }

    return InkWell(
      child: Ink(
        padding: const EdgeInsets.all(2.0),
        child: child,
      ),
      onTap: () async {
        final RenderBox button = context.findRenderObject()! as RenderBox;
        final RenderBox overlay = Navigator.of(context)
            .overlay!
            .context
            .findRenderObject()! as RenderBox;
        final Offset offset = Offset(0.0, button.size.height) + Offset(0.0, dy);
        final RelativeRect position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(offset, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
                ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        iconController.forward();

        widget.onOpened?.call();

        await showMenu<T?>(
          context: context,
          position: position,
          shape: RoundedRectangleBorder(
            borderRadius:
                widget.menuBorderRadius ?? BorderRadius.circular(10.0),
          ),
          color: widget.menuColor,
          items: widget.items,
          elevation: 8.0,
        ).then<void>(
          (T? newValue) {
            iconController.reverse();
            if (newValue == null) {
              widget.onCanceled?.call();
              return null;
            }
            widget.onSelected?.call(newValue);
          },
        );
      },
    );
  }
}

class JustContextMenu extends StatelessWidget {
  final Widget child;
  final List<Widget> items;
  final Duration animationDuration;

  const JustContextMenu({
    Key? key,
    required this.child,
    required this.items,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heroTag = UniqueKey();

    return GestureDetector(
      child: Hero(
        tag: heroTag,
        child: child,
      ),
      onTap: () async {
        final renderBox = context.findRenderObject()! as RenderBox;

        await Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: animationDuration,
            fullscreenDialog: true,
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastLinearToSlowEaseIn,
                ),
                child: _JustContextMenuPage(
                  heroTag: heroTag,
                  animationDuration: animationDuration,
                  items: items,
                  renderBox: renderBox,
                  child: child,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _JustContextMenuPage extends StatefulWidget {
  final Object heroTag;
  final Duration animationDuration;
  final Widget child;
  final RenderBox renderBox;
  final List<Widget> items;

  const _JustContextMenuPage({
    Key? key,
    required this.heroTag,
    required this.animationDuration,
    required this.child,
    required this.renderBox,
    required this.items,
  }) : super(key: key);

  @override
  State<_JustContextMenuPage> createState() => _JustContextMenuPageState();
}

class _JustContextMenuPageState extends State<_JustContextMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController menuController;

  @override
  void initState() {
    menuController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await menuController.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusItemHeight = widget.renderBox.size.height;
    const double spaceBetween = 20.0;
    final size = MediaQuery.of(context).size;
    final menuHeight = size.height / 3;
    final menuWidth = size.width * 2 / 3;

    backFunction() {
      menuController.duration =
          Duration(milliseconds: widget.animationDuration.inMilliseconds ~/ 4);
      menuController.reverse().then((_) => Navigator.pop(context));
    }

    return WillPopScope(
      onWillPop: () async {
        backFunction();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            GestureDetector(
              onTap: backFunction,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4,
                  sigmaY: 4,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Positioned(
              top: (size.height / 2) - focusItemHeight - (spaceBetween / 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: widget.heroTag,
                    child: widget.child,
                  ),
                  AnimatedBuilder(
                    animation: menuController,
                    builder: (_, __) {
                      return SizedBox(
                          height: spaceBetween +
                              lerpDouble(20.0, 0, menuController.value)!);
                    },
                  ),
                  AnimatedBuilder(
                    animation: menuController,
                    builder: (_, __) {
                      return Opacity(
                        opacity: menuController.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: menuHeight,
                          width: menuWidth,
                          child: ListView(
                            children: widget.items,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
