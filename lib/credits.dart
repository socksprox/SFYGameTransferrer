import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/centered_button.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://shadowfly.net');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TDText(
                      'Credits',
                      font: TDTheme.of(context).fontTitleLarge,
                      textColor: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 80, color: Colors.red.shade400),
                    const SizedBox(height: 24),
                    TDText(
                      'Made with love by',
                      font: TDTheme.of(context).fontTitleMedium,
                      textColor: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    TDText(
                      'Shadowfly Team',
                      font: TDTheme.of(context).fontTitleLarge,
                      fontWeight: FontWeight.w700,
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 32),
                    CenteredButton(
                      text: 'Try out Shadowfly here',
                      isPrimary: true,
                      isLarge: true,
                      onTap: _launchURL,
                      icon: Icons.link,
                    ),
                    const SizedBox(height: 8),
                    TDText(
                      'https://shadowfly.net',
                      font: TDTheme.of(context).fontBodySmall,
                      textColor: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
