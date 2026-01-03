import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

class ConsoleTarget {
  final String ipAddress;
  final int port;

  ConsoleTarget({required this.ipAddress, required this.port});
}

class DownloadProgress {
  final String clientIp;
  final String fileName;
  final int totalBytes;
  int downloadedBytes;
  DateTime startTime;
  bool isComplete;

  DownloadProgress({
    required this.clientIp,
    required this.fileName,
    required this.totalBytes,
    this.downloadedBytes = 0,
    required this.startTime,
    this.isComplete = false,
  });

  double get progress => totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
}

class FBIService {
  HttpServer? _httpServer;
  String? _localIpAddress;
  final List<FileItem> _files = [];
  final Function(String) onLog;
  final Map<String, List<DownloadProgress>> _downloadProgress = {};

  FBIService({required this.onLog});

  List<FileItem> get files => _files;

  List<DownloadProgress> getDownloadProgress(String fileName) {
    return _downloadProgress[fileName] ?? [];
  }

  void addFiles(List<String> filePaths) {
    for (final path in filePaths) {
      final file = File(path);
      if (file.existsSync()) {
        _files.add(
          FileItem(
            path: path,
            fileName: file.uri.pathSegments.last,
            size: file.lengthSync(),
            isExternalUrl: false,
          ),
        );
      }
    }
  }

  void addUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
      throw ArgumentError('Invalid URL: $url');
    }

    final fileName = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : 'file';

    _files.add(
      FileItem(path: url, fileName: fileName, size: 0, isExternalUrl: true),
    );
    onLog('Added external URL: $fileName');
  }

  void removeFile(int index) {
    if (index >= 0 && index < _files.length) {
      _files.removeAt(index);
    }
  }

  void clearFiles() {
    _files.clear();
  }

  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            if (addr.address.startsWith('192.168.') ||
                addr.address.startsWith('10.') ||
                addr.address.startsWith('172.')) {
              return addr.address;
            }
          }
        }
      }

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      onLog('Error getting local IP: $e');
    }
    return null;
  }

  Future<void> startServer() async {
    if (_httpServer != null) {
      return;
    }

    _localIpAddress = await _getLocalIpAddress();
    if (_localIpAddress == null) {
      throw Exception('Could not determine local IP address');
    }

    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(_handleRequest);

    _httpServer = await shelf_io.serve(handler, InternetAddress.anyIPv4, 0);
    onLog('HTTP Server started at $_localIpAddress:${_httpServer!.port}');
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    if (request.url.path.isEmpty) {
      final html = _generateIndexHTML();
      return shelf.Response.ok(html, headers: {'Content-Type': 'text/html'});
    }

    final decodedPath = Uri.decodeComponent(request.url.path);
    onLog('Request for: $decodedPath');

    final fileItem = _files.firstWhere(
      (f) => !f.isExternalUrl && f.clientPath == '/${request.url.path}',
      orElse: () => FileItem(path: '', fileName: '', size: 0),
    );

    if (fileItem.path.isEmpty) {
      onLog('File not found: $decodedPath');
      return shelf.Response.notFound('File not found');
    }

    final file = File(fileItem.path);
    if (!file.existsSync()) {
      onLog('File does not exist: ${fileItem.path}');
      return shelf.Response.notFound('File does not exist');
    }

    String clientIp = 'Unknown';
    try {
      final connectionInfo = request.context['shelf.io.connection_info'];
      if (connectionInfo != null && connectionInfo is HttpConnectionInfo) {
        clientIp = connectionInfo.remoteAddress.address;
      }
    } catch (e) {
      clientIp = 'Unknown';
    }

    final fileSize = await file.length();
    onLog('Sending: ${fileItem.fileName} to $clientIp');

    if (!_downloadProgress.containsKey(fileItem.fileName)) {
      _downloadProgress[fileItem.fileName] = [];
    }

    final progress = DownloadProgress(
      clientIp: clientIp,
      fileName: fileItem.fileName,
      totalBytes: fileSize,
      downloadedBytes: 0,
      startTime: DateTime.now(),
      isComplete: false,
    );
    _downloadProgress[fileItem.fileName]!.add(progress);

    final stream = file.openRead().transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          progress.downloadedBytes += data.length;
          sink.add(data);
        },
        handleDone: (sink) {
          progress.isComplete = true;
          onLog('Completed sending ${fileItem.fileName} to $clientIp');
          sink.close();
        },
        handleError: (error, stackTrace, sink) {
          progress.isComplete = true;
          onLog('Error sending ${fileItem.fileName} to $clientIp: $error');
          sink.addError(error, stackTrace);
        },
      ),
    );

    return shelf.Response.ok(
      stream,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="${fileItem.fileName}"',
        'Content-Length': '$fileSize',
      },
    );
  }

  String _generateIndexHTML() {
    final buffer = StringBuffer();
    buffer.write('<html><body><p><table cellspacing="2" cellpadding="0">');
    buffer.write('<tr><th>File</th><th>Size</th></tr>');

    for (final file in _files) {
      if (!file.isExternalUrl) {
        buffer.write(
          '<tr><td><a href="${file.clientPath}">${file.fileName}</a></td>',
        );
        buffer.write('<td>${_formatBytes(file.size)}</td></tr>');
      }
    }

    buffer.write('</table></p></body></html>');
    return buffer.toString();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  Future<void> sendToConsoles(List<ConsoleTarget> consoles) async {
    if (_httpServer == null) {
      await startServer();
    }

    if (_localIpAddress == null) {
      throw Exception('Server not properly initialized');
    }

    final serverUrl = 'http://$_localIpAddress:${_httpServer!.port}';
    final urlData = StringBuffer();

    for (final file in _files) {
      final fileUrl = file.isExternalUrl
          ? file.clientPath
          : '$serverUrl${file.clientPath}';
      urlData.write('$fileUrl\n');
    }

    final urlBytes = Uint8List.fromList(urlData.toString().codeUnits);
    final urlLength = ByteData(4)..setUint32(0, urlBytes.length, Endian.big);
    final dataPayload = <int>[...urlLength.buffer.asUint8List(), ...urlBytes];

    final List<Future<void>> connections = [];

    for (final console in consoles) {
      connections.add(
        _sendToSingleConsole(console.ipAddress, console.port, dataPayload),
      );
    }

    await Future.wait(connections);
  }

  Future<void> _sendToSingleConsole(
    String ipAddress,
    int port,
    List<int> dataPayload,
  ) async {
    try {
      onLog('Connecting to $ipAddress:$port...');
      final socket = await Socket.connect(ipAddress, port);
      onLog('Connected to $ipAddress:$port');

      socket.add(dataPayload);
      await socket.flush();

      onLog('Sent ${_files.length} file(s) to $ipAddress:$port');

      socket.listen(
        (data) {
          if (data.length == 1) {
            onLog('$ipAddress confirmed receipt');
            socket.close();
          }
        },
        onDone: () {
          onLog('$ipAddress finished downloading');
        },
        onError: (error) {
          onLog('Socket error on $ipAddress: $error');
        },
      );
    } catch (e) {
      onLog('Error connecting to $ipAddress:$port - $e');
    }
  }

  Future<void> stopServer() async {
    await _httpServer?.close();
    _httpServer = null;
    onLog('HTTP Server stopped');
  }

  void dispose() {
    stopServer();
  }
}

class FileItem {
  final String path;
  final String fileName;
  final int size;
  final bool isExternalUrl;
  late final String clientPath;

  FileItem({
    required this.path,
    required this.fileName,
    required this.size,
    this.isExternalUrl = false,
  }) {
    if (isExternalUrl) {
      clientPath = path;
    } else {
      final parts = path.split(Platform.pathSeparator);
      final lastTwo = parts.length >= 2
          ? parts.sublist(parts.length - 2)
          : [fileName];
      clientPath = '/${lastTwo.map((p) => Uri.encodeComponent(p)).join('/')}';
    }
  }
}
