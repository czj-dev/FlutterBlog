import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_blog/utils/adaptive.dart';
import 'package:flutter_blog/widget/native_image.dart';

class HomeIndexPage extends StatefulWidget {
  @override
  _HomeIndexPageState createState() => _HomeIndexPageState();
}

class _HomeIndexPageState extends State<HomeIndexPage> {
  @override
  Widget build(BuildContext context) {
    var homeSliverHeaderFacotry = HomeSliverHeaderFacotry();
    return NestedScrollView(
        headerSliverBuilder: homeSliverHeaderFacotry.build,
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 80,
              color: Colors.primaries[index % Colors.primaries.length],
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          },
          itemCount: 20,
        ));
  }
}

class HomeSliverHeaderFacotry {
  SliverAppBar appBarBuilder(BuildContext context) {
    var scrrentSzie = MediaQuery.of(context).size;
    var expandedHeight;
    if (isDisplayDesktop(context)) {
      expandedHeight = scrrentSzie.height * 0.45;
    } else {
      expandedHeight = scrrentSzie.height / 3;
    }
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: HomeHeaderForegroundBar(
        title: Text("Base Station"),
        subTitle: Text("君子坐而论道,少年起而行之"),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: () {}),
          IconButton(icon: Icon(Icons.dangerous), onPressed: () {})
        ],
        background: NativeImage("home_bg",
            width: scrrentSzie.width, height: expandedHeight),
      ),
    );
  }

  List<Widget> build(BuildContext context, bool innerBoxIsScrolled) {
    return [appBarBuilder(context)];
  }
}

class HomeHeaderForegroundBar extends StatefulWidget {
  final Widget? title;
  final Widget? subTitle;
  final Widget? background;
  final List<StretchMode> stretchModes;
  final List<Widget>? actions;

  const HomeHeaderForegroundBar(
      {Key? key,
      this.title,
      this.subTitle,
      this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
      this.actions,
      this.background})
      : super(key: key);

  @override
  _HomeHeaderForegroundBarState createState() =>
      _HomeHeaderForegroundBarState();
}

class _HomeHeaderForegroundBarState extends State<HomeHeaderForegroundBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      final FlexibleSpaceBarSettings settings = context
          .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
      final List<Widget> children = <Widget>[];

      final double deltaExtent = settings.maxExtent - settings.minExtent;

      // 0.0 -> Expanded
      // 1.0 -> Collapsed to toolbar
      final double t =
          (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
              .clamp(0.0, 1.0);
      // background
      if (widget.background != null) {
        final double fadeStart =
            math.max(0.0, 1.0 - kToolbarHeight / deltaExtent);
        const double fadeEnd = 1.0;
        assert(fadeStart <= fadeEnd);
        final double opacity = 1.0 - Interval(fadeStart, fadeEnd).transform(t);
        double height = settings.maxExtent;

        // StretchMode.zoomBackground
        if (widget.stretchModes.contains(StretchMode.zoomBackground) &&
            constraints.maxHeight > height) {
          height = constraints.maxHeight;
        }
        var top =
            -Tween<double>(begin: 0.0, end: deltaExtent / 4.0).transform(t);
        children.add(Positioned(
          top: top,
          left: 0.0,
          right: 0.0,
          height: height,
          child: Opacity(
            // IOS is relying on this semantics node to correctly traverse
            // through the app bar when it is collapsed.
            alwaysIncludeSemantics: true,
            opacity: opacity,
            child: widget.background,
          ),
        ));

        // StretchMode.blurBackground
        if (widget.stretchModes.contains(StretchMode.blurBackground) &&
            constraints.maxHeight > settings.maxExtent) {
          final double blurAmount =
              (constraints.maxHeight - settings.maxExtent) / 10;
          children.add(Positioned.fill(
              child: BackdropFilter(
                  child: Container(
                    color: Colors.transparent,
                  ),
                  filter: ui.ImageFilter.blur(
                    sigmaX: blurAmount,
                    sigmaY: blurAmount,
                  ))));
        }
      }

      // title
      if (widget.title != null) {
        final ThemeData theme = Theme.of(context);

        Widget? title;
        switch (theme.platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            title = widget.title;
            break;
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            title = Semantics(
              namesRoute: true,
              child: widget.title,
            );
            break;
        }
        Widget? subTitle = widget.subTitle;
        // StretchMode.fadeTitle
        if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
            constraints.maxHeight > settings.maxExtent) {
          final double stretchOpacity = 1 -
              (((constraints.maxHeight - settings.maxExtent) / 100)
                  .clamp(0.0, 1.0));
          title = Opacity(
            opacity: stretchOpacity,
            child: title,
          );
        }
        final double stretchOpacity = 1 -
            (((constraints.maxHeight - settings.maxExtent) / 100)
                .clamp(0.0, 1.0));
        subTitle = Opacity(
          opacity: stretchOpacity,
          child: widget.subTitle,
        );
        final double opacity = settings.toolbarOpacity;
        if (opacity > 0.0) {
          TextStyle titleStyle = theme.primaryTextTheme.headline5!;
          titleStyle = titleStyle.copyWith(
              color: titleStyle.color!.withOpacity(opacity),
              fontSize: titleStyle.fontSize);
          final EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(
            start: 0.0,
            bottom: 0.0,
          );
          final double scaleValue =
              Tween<double>(begin: 1.5, end: 1.0).transform(t);
          final Matrix4 scaleTransform = Matrix4.identity()
            ..scale(scaleValue, scaleValue, 1.0);

          final Alignment titleAlignment = _getTitleAlignment(true);
          children.add(Container(
            padding: padding,
            child: Transform(
              alignment: titleAlignment,
              transform: scaleTransform,
              child: Align(
                alignment: titleAlignment,
                child: DefaultTextStyle(
                  style: titleStyle,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return Container(
                      width: constraints.maxWidth / scaleValue,
                      alignment: titleAlignment,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [title!,subTitle!],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ));
        }
      }
      return ClipRect(child: Stack(children: children));
    });
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) return Alignment.center;
    final TextDirection textDirection = Directionality.of(context);
    assert(textDirection != null);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }

    bool _getActionexpand(BuildContext context, ThemeData theme) {
      return isDisplayDesktop(context);
    }
  }
}
