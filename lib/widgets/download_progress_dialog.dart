import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../services/fbi_service.dart';
import 'centered_button.dart';

class DownloadProgressDialog extends StatefulWidget {
  final FBIService fbiService;
  final String fileName;

  const DownloadProgressDialog({
    super.key,
    required this.fbiService,
    required this.fileName,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloads = widget.fbiService.getDownloadProgress(widget.fileName);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: TDTheme.of(context).brandNormalColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TDText(
                    'Download Progress',
                    font: TDTheme.of(context).fontTitleLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TDText(
              widget.fileName,
              font: TDTheme.of(context).fontBodyMedium,
              textColor: Colors.grey.shade600,
            ),
            const SizedBox(height: 24),
            Flexible(
              child: downloads.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_download_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          TDText(
                            'No downloads yet',
                            font: TDTheme.of(context).fontBodyLarge,
                            textColor: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          TDText(
                            'Clients will appear here when they download this file',
                            font: TDTheme.of(context).fontBodySmall,
                            textColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: downloads.length,
                      itemBuilder: (context, index) {
                        final download = downloads[index];
                        final duration = DateTime.now().difference(
                          download.startTime,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: download.isComplete
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: download.isComplete
                                  ? Colors.green.shade200
                                  : Colors.blue.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    download.isComplete
                                        ? Icons.check_circle
                                        : Icons.cloud_download,
                                    color: download.isComplete
                                        ? Colors.green.shade600
                                        : Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TDText(
                                      download.clientIp,
                                      font: TDTheme.of(context).fontBodyMedium,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TDText(
                                    download.isComplete
                                        ? 'Complete'
                                        : 'Downloading',
                                    font: TDTheme.of(context).fontBodySmall,
                                    textColor: download.isComplete
                                        ? Colors.green.shade700
                                        : Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: download.progress,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    download.isComplete
                                        ? Colors.green.shade600
                                        : Colors.blue.shade600,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TDText(
                                    '${_formatBytes(download.downloadedBytes)} / ${_formatBytes(download.totalBytes)}',
                                    font: TDTheme.of(context).fontBodySmall,
                                    textColor: Colors.grey.shade600,
                                  ),
                                  TDText(
                                    _formatDuration(duration),
                                    font: TDTheme.of(context).fontBodySmall,
                                    textColor: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            CenteredButton(
              text: 'Close',
              isPrimary: true,
              isBlock: true,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ago';
    } else {
      return '${duration.inHours}h ago';
    }
  }
}
