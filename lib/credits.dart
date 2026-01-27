import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/centered_button.dart';
import 'widgets/custom_app_bar.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://shadowfly.net');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildIconFeature(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 32, color: Colors.blue.shade600),
        ),
        const SizedBox(height: 8),
        TDText(
          label,
          font: TDTheme.of(context).fontBodySmall,
          textColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: const CustomAppBar(title: 'Credits'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo area
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/shadowfly.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // App name
              TDText(
                'Shadowfly',
                font: TDTheme.of(context).fontTitleLarge,
                fontWeight: FontWeight.w800,
                textColor: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 8),

              // Tagline
              TDText(
                'Break Through Censorship. Protect Your Privacy.',
                font: TDTheme.of(context).fontBodyLarge,
                textColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 40),

              // Mission statement
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade900.withValues(alpha: 0.3),
                            Colors.purple.shade900.withValues(alpha: 0.3),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade50, Colors.purple.shade50],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.blue.shade800 : Colors.blue.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    TDText(
                      'A VPN built to bypass the Great Firewall and protect your digital freedom—whether you\'re in China or anywhere else.',
                      font: TDTheme.of(context).fontBodyLarge,
                      textColor: isDark
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconFeature(
                          context,
                          Icons.shield_outlined,
                          'REALITY\nProtocol',
                          isDark,
                        ),
                        _buildIconFeature(
                          context,
                          Icons.public_off,
                          'Anti-\nCensorship',
                          isDark,
                        ),
                        _buildIconFeature(
                          context,
                          Icons.lock_outline,
                          'Privacy\nFirst',
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Why it matters
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.green.shade900.withValues(alpha: 0.3)
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.green.shade800
                        : Colors.green.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 36,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 12),
                    TDText(
                      'Why Privacy Tech Matters',
                      font: TDTheme.of(context).fontTitleMedium,
                      fontWeight: FontWeight.w600,
                      textColor: isDark ? Colors.white : Colors.black,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TDText(
                      'Our REALITY protocol hides your destination from ISPs and network monitors by masquerading as normal web traffic. What works against censorship also protects you from surveillance—everywhere.',
                      font: TDTheme.of(context).fontBodyMedium,
                      textColor: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Team dedication
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.purple.shade900.withValues(alpha: 0.3)
                      : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.purple.shade800
                        : Colors.purple.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, size: 40, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    TDText(
                      'Made with 3DS Love',
                      font: TDTheme.of(context).fontTitleMedium,
                      fontWeight: FontWeight.w600,
                      textColor: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 8),
                    TDText(
                      'The Shadowfly team built this app for the 3DS community. We believe in open access to content, without restrictions.',
                      font: TDTheme.of(context).fontBodyMedium,
                      textColor: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // CTA button
              CenteredButton(
                text: 'Try Shadowfly',
                isPrimary: true,
                isLarge: true,
                onTap: _launchURL,
                icon: Icons.public,
              ),
              const SizedBox(height: 12),
              TDText(
                'shadowfly.net',
                font: TDTheme.of(context).fontBodySmall,
                textColor: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
