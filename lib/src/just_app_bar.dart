import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_easy_widgets/just_easy_widgets.dart';

// const double _kLeadingWidth = kToolbarHeight;
// So the leading button is square.
// const double _kMaxTitleTextScaleFactor = 1.34;

// Bottom justify the toolbarHeight child which may overflow the top.
// class _ToolbarContainerLayout extends SingleChildLayoutDelegate {
//   const _ToolbarContainerLayout(this.toolbarHeight);

//   final double toolbarHeight;

//   @override
//   BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
//     return constraints.tighten(height: toolbarHeight);
//   }

//   @override
//   Size getSize(BoxConstraints constraints) {
//     return Size(constraints.maxWidth, toolbarHeight);
//   }

//   @override
//   Offset getPositionForChild(Size size, Size childSize) {
//     return Offset(0.0, size.height - childSize.height);
//   }

//   @override
//   bool shouldRelayout(_ToolbarContainerLayout oldDelegate) =>
//       toolbarHeight != oldDelegate.toolbarHeight;
// }

class _PreferredAppBarSize extends Size {
  final double? toolbarHeight;
  final double? bottomHeight;

  _PreferredAppBarSize(
    this.toolbarHeight,
    this.bottomHeight,
  ) : super.fromHeight((toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));
}

class JustAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final String? actionsTooltip;
  final List<String>? actionsLabels;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  @override
  final Size preferredSize;
  final double? toolbarHeight;

  JustAppBar({
    Key? key,
    this.leading,
    this.title,
    this.actions,
    this.actionsTooltip,
    this.actionsLabels,
    this.backgroundColor,
    this.bottom,
    this.toolbarHeight,
  })  : preferredSize = _PreferredAppBarSize(
          toolbarHeight,
          bottom?.preferredSize.height,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;

    Widget? leading = this.leading;
    if (leading == null) {
      if (hasDrawer) {
        leading = JustButton.onlyIcon(
          icon: const Icon(Icons.menu_rounded),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      } else if (!hasEndDrawer && canPop) {
        leading =
            useCloseButton ? const JustCloseButton() : const JustBackButton();
      }
    }

    Widget? actionButton;
    if (actions != null) {
      if (actions!.length == 1 && actionsTooltip != null) {
        log('"actionsTooltip" is not used when "actions.length == 1"');
      }
      List<PopupMenuEntry<dynamic>> items = [];
      if (actions!.length > 1) {
        assert(actionsLabels != null,
            'When "actions.length > 1", "actionsLabels" must be provided');
        assert(actionsLabels!.length == actions!.length);
        for (int i = 0; i < actions!.length; i++) {
          items.add(
            PopupMenuItem(
              child: ListTile(
                iconColor: Colors.black,
                leading: (actions![i] as JustButton).icon,
                title: Text(actionsLabels![i]),
              ),
            ),
          );
        }
      }

      actionButton = actions!.isEmpty
          ? null
          : actions!.length == 1
              ? actions!.first
              : JustPopupMenu.button(items: items);
    }
    if (actionButton == null && hasEndDrawer) {
      actionButton = JustButton.onlyIcon(
        icon: const Icon(Icons.menu_rounded),
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        onPressed: () => Scaffold.of(context).openEndDrawer(),
      );
    }

    final buttons = <Widget>[
      if (leading != null) leading,
      const Expanded(child: SizedBox.shrink()),
      if (actionButton != null) actionButton,
    ];

    Widget? title = this.title;
    if (title != null) {
      if (title is Text) {
        title = Text(
          title.data!,
          style: title.style ??
              const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
          strutStyle: title.strutStyle,
          textAlign: title.textAlign ?? TextAlign.center,
          textDirection: title.textDirection,
          locale: title.locale,
          softWrap: title.softWrap,
          overflow: title.overflow ?? TextOverflow.ellipsis,
          textScaleFactor: title.textScaleFactor,
          maxLines: title.maxLines ?? 1,
          semanticsLabel: title.semanticsLabel,
          textWidthBasis: title.textWidthBasis,
          textHeightBehavior: title.textHeightBehavior,
        );
      }
      title = Padding(
        padding: const EdgeInsets.only(
          top: 14.0,
          left: 50.0,
          right: 50.0,
        ),
        child: title,
      );
    }

    return Container(
      color: backgroundColor ?? Colors.white.withOpacity(0.5),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (title != null) title,
            Row(
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }
}
