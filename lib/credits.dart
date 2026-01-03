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

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TDText(
                  title,
                  font: TDTheme.of(context).fontBodyMedium,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.black,
                ),
                const SizedBox(height: 2),
                TDText(
                  description,
                  font: TDTheme.of(context).fontBodySmall,
                  textColor: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            child: SingleChildScrollView(
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
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    TDText(
                      'Circumvent Censorship. Access the Open Internet.',
                      font: TDTheme.of(context).fontBodyMedium,
                      textColor: Colors.grey.shade600,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // About section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(
                            'About Shadowfly',
                            font: TDTheme.of(context).fontTitleMedium,
                            fontWeight: FontWeight.w600,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          TDText(
                            'Shadowfly is a dedicated VPN service designed to help users bypass internet censorship in highly restricted regions. We provide reliable access to the open internet using advanced protocols.',
                            font: TDTheme.of(context).fontBodyMedium,
                            textColor: Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Features section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TDText(
                            'Key Features',
                            font: TDTheme.of(context).fontTitleMedium,
                            fontWeight: FontWeight.w600,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem(
                            context,
                            'VLESS Protocol',
                            'Next-generation proxy protocol',
                          ),
                          _buildFeatureItem(
                            context,
                            'Shadowsocks Support',
                            'Lightweight and fast encryption',
                          ),
                          _buildFeatureItem(
                            context,
                            'China Optimized',
                            'Specialized servers designed to bypass China\'s Great Firewall and censorship',
                          ),
                          _buildFeatureItem(
                            context,
                            'Military-grade Encryption',
                            'Protect your privacy and data',
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
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 40,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 12),
                          TDText(
                            'Made with 3DS Love',
                            font: TDTheme.of(context).fontTitleMedium,
                            fontWeight: FontWeight.w600,
                            textColor: Colors.black,
                          ),
                          const SizedBox(height: 8),
                          TDText(
                            'The Shadowfly team created this app out of our passion for the Nintendo 3DS community. We believe everyone should have access to the tools and content they love, without restrictions.',
                            font: TDTheme.of(context).fontBodyMedium,
                            textColor: Colors.grey.shade700,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // CTA button
                    CenteredButton(
                      text: 'Discover Shadowfly VPN',
                      isPrimary: true,
                      isLarge: true,
                      onTap: _launchURL,
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 12),
                    TDText(
                      'https://shadowfly.net',
                      font: TDTheme.of(context).fontBodySmall,
                      textColor: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 40),
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
