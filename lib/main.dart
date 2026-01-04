import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'services/fbi_service.dart';
import 'services/console_manager.dart';
import 'services/notification_service.dart';
import 'widgets/squircle_input.dart';
import 'widgets/centered_button.dart';
import 'widgets/download_progress_dialog.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/info_dialog.dart';
import 'credits.dart';
import 'debug_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SFYGameTransferrer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FBITransferPage(),
    );
  }
}

class FBITransferPage extends StatefulWidget {
  const FBITransferPage({super.key});

  @override
  State<FBITransferPage> createState() => _FBITransferPageState();
}

class _FBITransferPageState extends State<FBITransferPage> {
  late FBIService _fbiService;
  late ConsoleManager _consoleManager;
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController(
    text: '5000',
  );
  final TextEditingController _urlController = TextEditingController();
  final List<String> _logs = [];
  bool _isTransferring = false;
  bool _isDetecting = false;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _fbiService = FBIService(
      onLog: (message) {
        if (mounted) {
          setState(() {
            _logs.add(
              '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
            );
          });
        }
      },
    );
    _consoleManager = ConsoleManager(
      onLog: (message) {
        if (mounted) {
          setState(() {
            _logs.add(
              '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
            );
          });
        }
      },
    );

    NotificationService().onStopServerRequested = () async {
      debugPrint('Main: Stop server callback triggered');
      await _fbiService.stopServer();
      debugPrint('Main: Stop server completed');
    };

    _fbiService.onRequestPermissionExplanation = () async {
      if (!mounted) return false;

      final result = await InfoDialog.show(
        context: context,
        title: 'Notification Permission',
        message:
            'This app needs notification permission to keep downloads running in the background on Android. This allows the server to continue transferring files even when you leave the app.',
        icon: Icons.notifications_outlined,
        iconColor: Colors.blue,
        confirmText: 'Continue',
        cancelText: 'Cancel',
      );

      return result ?? false;
    };

    // Auto-discover 3DS consoles on app boot
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectConsoles();
    });
  }

  @override
  void dispose() {
    NotificationService().onStopServerRequested = null;
    _fbiService.dispose();
    _ipController.dispose();
    _portController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _fbiService.addFiles(result.paths.whereType<String>().toList());
        });
        _addLog('Added ${result.files.length} file(s)');
      }
    } catch (e) {
      _addLog('Error picking files: $e');
    }
  }

  void _addUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      TDToast.showText('Please enter a URL', context: context);
      return;
    }

    try {
      setState(() {
        _fbiService.addUrl(url);
        _urlController.clear();
      });
    } catch (e) {
      TDToast.showFail('Invalid URL: $e', context: context);
    }
  }

  void _addLog(String message) {
    setState(() {
      _logs.add(
        '${DateTime.now().toIso8601String().substring(11, 19)}: $message',
      );
    });
  }

  Future<void> _detectConsoles() async {
    setState(() {
      _isDetecting = true;
    });

    try {
      await _consoleManager.detectConsoles();
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  void _addConsole() {
    final ip = _ipController.text.trim();
    final portStr = _portController.text.trim();
    final port = int.tryParse(portStr) ?? 5000;

    if (ip.isEmpty) {
      TDToast.showText('Please enter an IP address', context: context);
      return;
    }

    setState(() {
      _consoleManager.addConsole(ip, port);
      _ipController.clear();
    });
  }

  Future<void> _toggleServer() async {
    if (_fbiService.httpServer != null) {
      setState(() {
        _isTransferring = true;
      });
      try {
        await _fbiService.stopServer();
        if (mounted) {
          TDToast.showSuccess('Server stopped', context: context);
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          TDToast.showFail('Error stopping server: $e', context: context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isTransferring = false;
          });
        }
      }
    } else {
      if (_fbiService.files.isEmpty) {
        TDToast.showText('Please add files first', context: context);
        return;
      }

      if (_consoleManager.consoles.isEmpty) {
        TDToast.showText('Please add at least one console', context: context);
        return;
      }

      setState(() {
        _isTransferring = true;
      });

      try {
        final consoleTargets = _consoleManager.consoles
            .map((c) => ConsoleTarget(ipAddress: c.ipAddress, port: c.port))
            .toList();
        await _fbiService.sendToConsoles(consoleTargets);
        if (mounted) {
          TDToast.showText('Server started and files sent!', context: context);
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          TDToast.showFail('Error: $e', context: context);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isTransferring = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'SFY Game Transferrer',
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onLongPress: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DebugScreen(
                  fbiService: _fbiService,
                  consoleManager: _consoleManager,
                ),
              ),
            );
          },
          child: const Icon(
            Icons.videogame_asset,
            color: Colors.black,
            size: 24,
          ),
        ),
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreditsPage()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red.shade400,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [_buildConsolesTab(), _buildFilesTab()],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          enableFeedback: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.videogame_asset_outlined),
              activeIcon: Icon(Icons.videogame_asset),
              label: 'Consoles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Files',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsolesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TDText(
            '3DS Consoles (${_consoleManager.consoles.length})',
            font: TDTheme.of(context).fontTitleLarge,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CenteredButton(
                  text: _isDetecting ? 'Detecting...' : 'Auto-Detect',
                  isPrimary: true,
                  onTap: _isDetecting ? null : _detectConsoles,
                  icon: Icons.search,
                  disabled: _isDetecting,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CenteredButton(
                  text: 'Clear All',
                  isPrimary: false,
                  onTap: () {
                    setState(() {
                      _consoleManager.clearConsoles();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SquircleInput(
                  controller: _ipController,
                  hintText: 'Console IP',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: SquircleInput(
                  controller: _portController,
                  hintText: 'Port',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              CenteredButton(
                text: 'Add',
                isPrimary: true,
                onTap: _addConsole,
                icon: Icons.add,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _consoleManager.consoles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videogame_asset_outlined,
                          size: 32,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 8),
                        TDText(
                          'No consoles added',
                          textColor: Colors.grey,
                          font: TDTheme.of(context).fontBodyMedium,
                        ),
                        const SizedBox(height: 4),
                        TDText(
                          'Use Auto-Detect or add manually',
                          textColor: Colors.grey.shade400,
                          font: TDTheme.of(context).fontBodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: _consoleManager.consoles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final console = _consoleManager.consoles[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.videogame_asset,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
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
                                    const SizedBox(height: 2),
                                    TDText(
                                      'Port: ${console.port}',
                                      font: TDTheme.of(context).fontBodySmall,
                                      textColor: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _consoleManager.removeConsole(index);
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TDText(
            'Files (${_fbiService.files.length})',
            font: TDTheme.of(context).fontTitleLarge,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CenteredButton(
                  text: 'Add Files',
                  isPrimary: true,
                  onTap: _pickFiles,
                  icon: Icons.add,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CenteredButton(
                  text: 'Clear All',
                  isPrimary: false,
                  onTap: () {
                    setState(() {
                      _fbiService.clearFiles();
                    });
                    _addLog('Cleared all files');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SquircleInput(
                  controller: _urlController,
                  hintText:
                      'Enter external URL (e.g., https://example.com/game.cia)',
                  keyboardType: TextInputType.url,
                ),
              ),
              const SizedBox(width: 8),
              CenteredButton(
                text: 'Add URL',
                isPrimary: true,
                onTap: _addUrl,
                icon: Icons.link,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _fbiService.files.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 32,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 8),
                          TDText(
                            'No files added',
                            textColor: Colors.grey,
                            font: TDTheme.of(context).fontBodyMedium,
                          ),
                          const SizedBox(height: 4),
                          TDText(
                            'Add local files or external URLs',
                            textColor: Colors.grey.shade400,
                            font: TDTheme.of(context).fontBodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _fbiService.files.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final file = _fbiService.files[index];
                        final isUrl = file.isExternalUrl;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isUrl
                                        ? Colors.blue.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isUrl
                                        ? Icons.link
                                        : Icons.insert_drive_file,
                                    color: isUrl
                                        ? Colors.blue.shade600
                                        : Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TDText(
                                        file.fileName,
                                        font: TDTheme.of(
                                          context,
                                        ).fontBodyMedium,
                                        fontWeight: FontWeight.w600,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      TDText(
                                        isUrl
                                            ? 'External URL'
                                            : _formatBytes(file.size),
                                        font: TDTheme.of(context).fontBodySmall,
                                        textColor: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            DownloadProgressDialog(
                                              fbiService: _fbiService,
                                              fileName: file.fileName,
                                            ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _fbiService.removeFile(index);
                                      });
                                      _addLog('Removed ${file.fileName}');
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          CenteredButton(
            text: _isTransferring
                ? (_fbiService.httpServer != null
                      ? 'Stopping...'
                      : 'Starting...')
                : (_fbiService.httpServer != null
                      ? 'Stop Server'
                      : 'Start Server'),
            isPrimary: _fbiService.httpServer == null,
            isLarge: true,
            onTap: _isTransferring ? null : _toggleServer,
            isBlock: true,
            disabled: _isTransferring,
            icon: _fbiService.httpServer != null
                ? Icons.stop
                : Icons.play_arrow,
            backgroundColor: _fbiService.httpServer != null ? Colors.red : null,
          ),
          const SizedBox(height: 16),
          TDText(
            'Transfer Log',
            font: TDTheme.of(context).fontTitleMedium,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: TDText('No logs yet', textColor: Colors.grey),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
