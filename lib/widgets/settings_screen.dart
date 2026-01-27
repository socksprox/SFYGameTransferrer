import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/theme_manager.dart' as theme_manager;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Color> _defaultColors = [
    const Color(0xFF0052D9),
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  void _showColorPicker() {
    final themeManager = theme_manager.ThemeManager();
    Color pickerColor = themeManager.themeColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                themeManager.setThemeColor(pickerColor);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
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
            _buildThemeOption(
              context,
              title: 'Light Mode',
              icon: Icons.light_mode,
              isSelected:
                  themeManager.themeMode == theme_manager.ThemeMode.light,
              onTap: () {
                themeManager.setThemeMode(theme_manager.ThemeMode.light);
                setState(() {});
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              title: 'Dark Mode',
              icon: Icons.dark_mode,
              isSelected:
                  themeManager.themeMode == theme_manager.ThemeMode.dark,
              onTap: () {
                themeManager.setThemeMode(theme_manager.ThemeMode.dark);
                setState(() {});
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context,
              title: 'System',
              icon: Icons.brightness_auto,
              isSelected:
                  themeManager.themeMode == theme_manager.ThemeMode.system,
              onTap: () {
                themeManager.setThemeMode(theme_manager.ThemeMode.system);
                setState(() {});
              },
              isDark: isDark,
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
                    isSelected: themeManager.themeColor.value == color.value,
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
      (c) => c.value == themeManager.themeColor.value,
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

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blue
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.shade50
                      : (isDark ? Colors.grey.shade700 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.blue.shade600
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TDText(
                  title,
                  font: TDTheme.of(context).fontBodyLarge,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
