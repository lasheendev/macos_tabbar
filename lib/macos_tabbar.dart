import 'package:flutter/material.dart';

class MacosTabData {
  final String id;
  final String title;
  final Widget? favicon;

  MacosTabData({required this.id, required this.title, this.favicon});
}

class MacosTabbar extends StatefulWidget implements PreferredSizeWidget {
  MacosTabbar({
    super.key,
    required this.tabs,
    this.selectedTabId,
    required this.onTabSelected,
    required this.onTabDeleted,

    /// Width of each tab.
    this.tabWidth = 120,

    /// Peek width helps to create a stacking effect of non active tabs.
    this.peekWidth,

    /// If you want to shrink the tabbar size, you can set a shrinkWidth.
    /// Helps when you want to show the tabbar along with other widgets in a row.
    this.shrinkWidth = 0,

    /// Spacing between tabs.
    this.tabSpacing = 0,

    /// Text style of the tab title.
    this.textStyle,

    /// Border of the tab.
    this.border,

    /// Background color of the tab.
    this.backgroundColor,

    /// Foreground color of the tab.
    this.foregroundColor,

    /// Background color of the active tab.
    this.activeBackgroundColor,

    /// Foreground color of the active tab.
    this.activeForegroundColor,
  })  : assert(tabs.isNotEmpty, 'Tabs must not be empty'),
        assert(
          selectedTabId == null ||
              tabs.any((MacosTabData tab) => tab.id == selectedTabId),
          'Selected tab id must be in tabs',
        ),
        assert(
          tabs.map((MacosTabData tab) => tab.id).toSet().length == tabs.length,
          'All ids must be unique',
        );

  final List<MacosTabData> tabs;
  final String? selectedTabId;
  final ValueChanged<String> onTabSelected;
  final ValueChanged<String> onTabDeleted;
  final double tabWidth;
  final double? peekWidth;
  final double shrinkWidth;
  final double tabSpacing;
  final TextStyle? textStyle;
  final BoxBorder? border;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;

  @override
  State<MacosTabbar> createState() => _MacosTabbarState();

  @override
  Size get preferredSize => const Size.fromHeight(30);
}

class _MacosTabbarState extends State<MacosTabbar> {
  double scrollOffset = 0.0;

  late List<(int, MacosTabData)> arrangedTabs;
  late (int, MacosTabData) middle;

  void _updateTabs() {
    final int selectedIndex = widget.tabs
        .indexWhere((MacosTabData tab) => tab.id == widget.selectedTabId);

    final List<(int, MacosTabData)> indexedTabs = widget.tabs.indexed.toList();
    final List<(int, MacosTabData)> firstHalf =
        indexedTabs.take(selectedIndex).toList();
    middle = indexedTabs.elementAt(selectedIndex);
    final List<(int, MacosTabData)> secondHalf =
        indexedTabs.skip(selectedIndex + 1).toList().reversed.toList();

    arrangedTabs = <(int, MacosTabData)>[...firstHalf, ...secondHalf, middle];
  }

  @override
  void initState() {
    _updateTabs();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MacosTabbar oldWidget) {
    _updateTabs();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width - widget.shrinkWidth;
    final double maxOffset =
        widget.tabs.length * (widget.tabWidth + widget.tabSpacing);
    final int tabCount = widget.tabs.length;

    Widget buildTab((int, MacosTabData) tab) {
      return Positioned(
        bottom: 0,
        top: 0,
        left: getLeftOffset(
          index: tab.$1,
          scrollOffset: scrollOffset,
          width: width,
          tabWidth: widget.tabWidth,
          tabCount: tabCount,
          tabSpacing: widget.tabSpacing,
          peekWidth: widget.peekWidth ?? 0,
        ),
        child: Padding(
          padding: EdgeInsets.only(right: widget.tabSpacing),
          child: SizedBox(
            width: widget.tabWidth,
            child: MacosTab(
              title: tab.$2.title,
              favicon: tab.$2.favicon,
              textStyle: widget.textStyle,
              border: widget.border,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              activeBackgroundColor: widget.activeBackgroundColor,
              activeForegroundColor: widget.activeForegroundColor,
              isMiddle: tab.$1 == middle.$1,
              onTap: () {
                widget.onTabSelected(tab.$2.id);
              },
              onCloseTap: () {
                widget.onTabDeleted(tab.$2.id);
              },
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ...arrangedTabs.map(buildTab),
        NotificationListener<Notification>(
          onNotification: (Object? notification) {
            if (notification
                case (ScrollUpdateNotification(
                      metrics: final ScrollMetrics metrics
                    ) ||
                    ScrollMetricsNotification(
                      metrics: final ScrollMetrics metrics
                    ))) {
              setState(() {
                scrollOffset = metrics.pixels;
              });
            }
            return true;
          },
          child: SingleChildScrollView(
            hitTestBehavior: HitTestBehavior.translucent,
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: maxOffset, height: double.infinity),
          ),
        ),
      ],
    );
  }
}

double getLeftOffset({
  required int index,
  required double scrollOffset,
  required double width,
  required double tabWidth,
  required int tabCount,
  required double tabSpacing,
  required double peekWidth,
}) {
  final double tabWidthWithSpacing = tabWidth + tabSpacing;
  final double actualPosition = index * tabWidthWithSpacing;
  final double newScrollOffset = actualPosition - scrollOffset;
  final double peek = tabWidthWithSpacing * peekWidth;

  // ——— LEFT-SIDE STACKING ———
  final double leftThreshold = index * peek;
  if (newScrollOffset < leftThreshold) {
    return leftThreshold;
  }

  // ——— RIGHT-SIDE STACKING ———
  final double maxRightOffset = width - tabWidthWithSpacing;
  final double rightThreshold =
      maxRightOffset - ((tabCount - index - 1) * peek);
  if (newScrollOffset > rightThreshold) {
    return rightThreshold;
  }

  return newScrollOffset.clamp(0, width - tabWidthWithSpacing);
}

class MacosTab extends StatelessWidget {
  final String title;

  final bool isMiddle;
  final VoidCallback onTap;
  final VoidCallback onCloseTap;
  final Widget? favicon;
  final TextStyle? textStyle;
  final BoxBorder? border;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? activeBackgroundColor;
  final Color? activeForegroundColor;
  const MacosTab({
    super.key,
    required this.title,
    this.isMiddle = false,
    required this.onTap,
    required this.onCloseTap,
    this.favicon,
    this.textStyle,
    this.border,
    this.backgroundColor,
    this.foregroundColor,
    this.activeBackgroundColor,
    this.activeForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isMiddle
        ? activeBackgroundColor ?? const Color(0xFF363636)
        : backgroundColor ?? const Color(0xFF1E1E1E);
    final Color fgColor = isMiddle
        ? activeForegroundColor ?? Colors.white
        : foregroundColor ?? const Color(0xFF979797);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          border:
              border ?? Border.all(color: const Color(0xFF474747), width: 0.5),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 10),
            GestureDetector(
                onTap: onCloseTap,
                child: Icon(Icons.close, color: fgColor, size: 12)),
            const SizedBox(width: 10),
            if (favicon != null) ...<Widget>[
              favicon!,
              const SizedBox(width: 5)
            ],
            Expanded(
              child: Text(
                title,
                style: textStyle ??
                    TextStyle(
                        color: fgColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
