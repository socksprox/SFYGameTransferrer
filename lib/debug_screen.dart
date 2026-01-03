import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'services/fbi_service.dart';
import 'services/console_manager.dart';
import 'widgets/custom_app_bar.dart';

class DebugScreen extends StatefulWidget {
  final FBIService fbiService;
  final ConsoleManager consoleManager;

  const DebugScreen({
    super.key,
    required this.fbiService,
    required this.consoleManager,
  });

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    final isServerActive = widget.fbiService.httpServer != null;
    final serverUrl = isServerActive
        ? 'http://${widget.fbiService.localIpAddress}:${widget.fbiService.httpServer!.port}'
        : 'Not running';

    return Scaffold(
      appBar: const CustomAppBar(title: 'Debug Information'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              context,
              title: 'Web Server Status',
              icon: Icons.dns,
              iconColor: isServerActive ? Colors.green : Colors.grey,
              children: [
                _buildInfoRow(
                  context,
                  'Status',
                  isServerActive ? 'Active' : 'Inactive',
                  isServerActive ? Colors.green : Colors.grey,
                ),
                if (isServerActive) ...[
                  _buildInfoRow(context, 'Server URL', serverUrl, Colors.blue),
                  _buildInfoRow(
                    context,
                    'Port',
                    '${widget.fbiService.httpServer!.port}',
                    Colors.blue,
                  ),
                  _buildInfoRow(
                    context,
                    'Local IP',
                    widget.fbiService.localIpAddress ?? 'Unknown',
                    Colors.blue,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Hosted Files',
              icon: Icons.folder,
              iconColor: Colors.orange,
              children: [
                _buildInfoRow(
                  context,
                  'Total Files',
                  '${widget.fbiService.files.length}',
                  Colors.black,
                ),
                _buildInfoRow(
                  context,
                  'Local Files',
                  '${widget.fbiService.files.where((f) => !f.isExternalUrl).length}',
                  Colors.black,
                ),
                _buildInfoRow(
                  context,
                  'External URLs',
                  '${widget.fbiService.files.where((f) => f.isExternalUrl).length}',
                  Colors.black,
                ),
                const SizedBox(height: 12),
                if (widget.fbiService.files.isNotEmpty) ...[
                  TDText(
                    'File List:',
                    font: TDTheme.of(context).fontBodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  ...widget.fbiService.files.map((file) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                file.isExternalUrl
                                    ? Icons.link
                                    : Icons.insert_drive_file,
                                size: 16,
                                color: file.isExternalUrl
                                    ? Colors.blue
                                    : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TDText(
                                  file.fileName,
                                  font: TDTheme.of(context).fontBodyMedium,
                                  fontWeight: FontWeight.w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TDText(
                            file.isExternalUrl
                                ? 'External URL'
                                : 'Size: ${_formatBytes(file.size)}',
                            font: TDTheme.of(context).fontBodySmall,
                            textColor: Colors.grey.shade600,
                          ),
                          if (!file.isExternalUrl) ...[
                            const SizedBox(height: 4),
                            TDText(
                              'Path: ${file.clientPath}',
                              font: TDTheme.of(context).fontBodySmall,
                              textColor: Colors.grey.shade500,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Connected Consoles',
              icon: Icons.videogame_asset,
              iconColor: Colors.blue,
              children: [
                _buildInfoRow(
                  context,
                  'Total Consoles',
                  '${widget.consoleManager.consoles.length}',
                  Colors.black,
                ),
                const SizedBox(height: 12),
                if (widget.consoleManager.consoles.isNotEmpty) ...[
                  TDText(
                    'Console List:',
                    font: TDTheme.of(context).fontBodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  ...widget.consoleManager.consoles.map((console) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.videogame_asset,
                            size: 20,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TDText(
                                  console.ipAddress,
                                  font: TDTheme.of(context).fontBodyMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                                TDText(
                                  'Port: ${console.port}',
                                  font: TDTheme.of(context).fontBodySmall,
                                  textColor: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: 'Download Progress',
              icon: Icons.download,
              iconColor: Colors.purple,
              children: [
                _buildInfoRow(
                  context,
                  'Active Downloads',
                  '${_getActiveDownloadsCount()}',
                  Colors.black,
                ),
                const SizedBox(height: 12),
                if (_hasDownloadProgress()) ...[
                  TDText(
                    'Recent Downloads:',
                    font: TDTheme.of(context).fontBodyMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  ..._buildDownloadProgressWidgets(context),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              TDText(
                title,
                font: TDTheme.of(context).fontTitleMedium,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TDText(
            label,
            font: TDTheme.of(context).fontBodyMedium,
            textColor: Colors.grey.shade700,
          ),
          TDText(
            value,
            font: TDTheme.of(context).fontBodyMedium,
            fontWeight: FontWeight.w600,
            textColor: valueColor,
          ),
        ],
      ),
    );
  }

  int _getActiveDownloadsCount() {
    int count = 0;
    for (final file in widget.fbiService.files) {
      final progress = widget.fbiService.getDownloadProgress(file.fileName);
      count += progress.where((p) => !p.isComplete).length;
    }
    return count;
  }

  bool _hasDownloadProgress() {
    for (final file in widget.fbiService.files) {
      final progress = widget.fbiService.getDownloadProgress(file.fileName);
      if (progress.isNotEmpty) return true;
    }
    return false;
  }

  List<Widget> _buildDownloadProgressWidgets(BuildContext context) {
    final widgets = <Widget>[];
    for (final file in widget.fbiService.files) {
      final progressList = widget.fbiService.getDownloadProgress(file.fileName);
      for (final progress in progressList.take(5)) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: progress.isComplete
                  ? Colors.green.shade50
                  : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: progress.isComplete
                    ? Colors.green.shade200
                    : Colors.purple.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      progress.isComplete
                          ? Icons.check_circle
                          : Icons.downloading,
                      size: 16,
                      color: progress.isComplete
                          ? Colors.green.shade600
                          : Colors.purple.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TDText(
                        progress.fileName,
                        font: TDTheme.of(context).fontBodyMedium,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TDText(
                  'Client: ${progress.clientIp}',
                  font: TDTheme.of(context).fontBodySmall,
                  textColor: Colors.grey.shade600,
                ),
                const SizedBox(height: 4),
                TDText(
                  'Progress: ${(progress.progress * 100).toStringAsFixed(1)}% (${_formatBytes(progress.downloadedBytes)} / ${_formatBytes(progress.totalBytes)})',
                  font: TDTheme.of(context).fontBodySmall,
                  textColor: Colors.grey.shade600,
                ),
                if (!progress.isComplete) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
