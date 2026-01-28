import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/theme_manager.dart' as theme_manager;
import 'theme_tab_selector.dart';
import 'centered_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Color> _defaultColors = [
    const Color(0xFF0052D9),
    const Color(0xFF5BD700),
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  int _getThemeModeIndex(theme_manager.ThemeMode mode) {
    switch (mode) {
      case theme_manager.ThemeMode.light:
        return 0;
      case theme_manager.ThemeMode.dark:
        return 1;
      case theme_manager.ThemeMode.system:
        return 2;
    }
  }

  void _showColorPicker() {
    final themeManager = theme_manager.ThemeManager();
    Color pickerColor = themeManager.themeColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                          ),
                        ),
                      ),
                      child: TDText(
                        'Pick a color',
                        font: TDTheme.of(context).fontTitleMedium,
                        fontWeight: FontWeight.w600,
                        textColor: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (Color color) {
                            setState(() {
                              pickerColor = color;
                            });
                          },
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                    ),
                    // Actions
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50,
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CenteredButton(
                              text: 'Cancel',
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CenteredButton(
                              text: 'Select',
                              isPrimary: true,
                              backgroundColor: pickerColor,
                              onTap: () {
                                themeManager.setThemeColor(pickerColor);
                                this.setState(() {});
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = theme_manager.ThemeManager();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TDText(
              'Settings',
              font: TDTheme.of(context).fontTitleLarge,
              fontWeight: FontWeight.w600,
              textColor: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 24),
            TDText(
              'Appearance',
              font: TDTheme.of(context).fontTitleMedium,
              fontWeight: FontWeight.w600,
              textColor: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 16),
            TDesignTabSelector(
              tabs: [
                TDesignTabItem(
                  text: 'Light',
                  icon: Icon(Icons.light_mode, size: 16),
                ),
                TDesignTabItem(
                  text: 'Dark',
                  icon: Icon(Icons.dark_mode, size: 16),
                ),
                TDesignTabItem(
                  text: 'System',
                  icon: Icon(Icons.brightness_auto, size: 16),
                ),
              ],
              initialIndex: _getThemeModeIndex(themeManager.themeMode),
              onTabChanged: (index) {
                switch (index) {
                  case 0:
                    themeManager.setThemeMode(theme_manager.ThemeMode.light);
                    break;
                  case 1:
                    themeManager.setThemeMode(theme_manager.ThemeMode.dark);
                    break;
                  case 2:
                    themeManager.setThemeMode(theme_manager.ThemeMode.system);
                    break;
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 32),
            TDText(
              'Theme Color',
              font: TDTheme.of(context).fontTitleMedium,
              fontWeight: FontWeight.w600,
              textColor: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._defaultColors.map(
                  (color) => _buildColorOption(
                    context,
                    color: color,
                    isSelected:
                        themeManager.themeColor.toARGB32() == color.toARGB32(),
                    onTap: () {
                      themeManager.setThemeColor(color);
                      setState(() {});
                    },
                    isDark: isDark,
                  ),
                ),
                _buildCustomColorOption(context, isDark: isDark),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context, {
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? Icon(Icons.check, color: _getContrastColor(color), size: 28)
            : null,
      ),
    );
  }

  Widget _buildCustomColorOption(BuildContext context, {required bool isDark}) {
    final themeManager = theme_manager.ThemeManager();
    final isCustomColor = !_defaultColors.any(
      (c) => c.toARGB32() == themeManager.themeColor.toARGB32(),
    );

    return GestureDetector(
      onTap: _showColorPicker,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.red,
              Colors.orange,
              Colors.yellow,
              Colors.green,
              Colors.blue,
              Colors.purple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCustomColor
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isCustomColor ? Icons.check : Icons.colorize,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
