import 'package:flutter/material.dart';
import '../services/theme_manager.dart' as theme_manager;

/// A reusable TDesign-styled tab selector component with square card design
/// Supports 2-5 tabs with icons and text labels
class TDesignTabSelector extends StatefulWidget {
  final List<TDesignTabItem> tabs;
  final int initialIndex;
  final Function(int) onTabChanged;
  final double? height;
  final double? width;

  const TDesignTabSelector({
    super.key,
    required this.tabs,
    required this.onTabChanged,
    this.initialIndex = 0,
    this.height = 44,
    this.width,
  }) : assert(
         tabs.length >= 2 && tabs.length <= 5,
         'TDesignTabSelector requires 2-5 tabs',
       );

  @override
  State<TDesignTabSelector> createState() => _TDesignTabSelectorState();
}

class _TDesignTabSelectorState extends State<TDesignTabSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void didUpdateWidget(TDesignTabSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _tabController.animateTo(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeManager = theme_manager.ThemeManager();
    final themeColor = themeManager.themeColor;

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final effectiveWidth = widget.width ?? constraints.maxWidth;
            final tabWidth = effectiveWidth / widget.tabs.length;
            final animationValue =
                _tabController.animation?.value ??
                _tabController.index.toDouble();
            final indicatorOffset = animationValue * tabWidth;

            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                children: [
                  // Animated sliding indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: indicatorOffset,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Tab buttons
                  Row(
                    children: List.generate(widget.tabs.length, (index) {
                      final tabItem = widget.tabs[index];
                      final isSelected = (animationValue - index).abs() < 0.5;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(
                              index,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOut,
                            );
                            widget.onTabChanged(index);
                          },
                          child: Container(
                            height: widget.height,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (tabItem.icon != null) ...[
                                  IconTheme(
                                    data: IconThemeData(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600]),
                                      size: 16,
                                    ),
                                    child: tabItem.icon!,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  tabItem.text,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode
                                              ? Colors.white70
                                              : Colors.grey[600]),
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Data class for tab items
class TDesignTabItem {
  final String text;
  final Widget? icon;

  const TDesignTabItem({required this.text, this.icon});
}
