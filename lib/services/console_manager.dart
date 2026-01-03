import 'dart:io';
import 'dart:async';

class ConsoleManager {
  final List<ConsoleItem> _consoles = [];
  final Function(String) onLog;

  ConsoleManager({required this.onLog});

  List<ConsoleItem> get consoles => _consoles;

  void addConsole(String ipAddress, int port) {
    if (!_consoles.any((c) => c.ipAddress == ipAddress && c.port == port)) {
      _consoles.add(ConsoleItem(ipAddress: ipAddress, port: port));
      onLog('Added console: $ipAddress:$port');
    }
  }

  void removeConsole(int index) {
    if (index >= 0 && index < _consoles.length) {
      final console = _consoles[index];
      _consoles.removeAt(index);
      onLog('Removed console: ${console.ipAddress}:${console.port}');
    }
  }

  void clearConsoles() {
    _consoles.clear();
    onLog('Cleared all consoles');
  }

  Future<void> detectConsoles() async {
    onLog('Scanning for 3DS consoles...');

    if (Platform.isAndroid || Platform.isIOS) {
      await _detectConsolesAndroid();
    } else {
      await _detectConsolesMacOS();
    }
  }

  Future<void> _detectConsolesAndroid() async {
    try {
      final localIp = await _getLocalIpAddress();
      if (localIp == null) {
        onLog('Could not determine local IP address');
        return;
      }

      onLog('Scanning network from $localIp...');
      final subnet = localIp.substring(0, localIp.lastIndexOf('.'));

      int foundCount = 0;
      final scanTasks = <Future<void>>[];

      for (int i = 1; i <= 254; i++) {
        final ip = '$subnet.$i';
        scanTasks.add(
          _checkHost(ip).then((found) {
            if (found) foundCount++;
          }),
        );
      }

      await Future.wait(scanTasks);

      if (foundCount == 0) {
        onLog('No 3DS consoles detected');
      } else {
        onLog('Found $foundCount 3DS console(s)');
      }
    } catch (e) {
      onLog('Error during Android detection: $e');
    }
  }

  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
            return addr.address;
          }
        }
      }

      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && addr.address.startsWith('10.')) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      onLog('Error getting local IP: $e');
    }
    return null;
  }

  Future<bool> _checkHost(String ip) async {
    try {
      final host = await _getHostname(ip);
      if (host.toLowerCase().contains('nintendo3ds')) {
        addConsole(ip, 5000);
        return true;
      }
    } catch (e) {}
    return false;
  }

  Future<String> _getHostname(String ip) async {
    try {
      final result = await InternetAddress(ip).reverse();
      return result.host;
    } catch (e) {
      return '';
    }
  }

  Future<void> _detectConsolesMacOS() async {
    try {
      final result = await Process.run('arp', ['-a']);
      if (result.exitCode != 0) {
        onLog('ARP scan failed');
        return;
      }

      final output = result.stdout as String;
      final ipPattern = RegExp(r'\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b');
      final macPattern = RegExp(r' ([0-9a-fA-F]{1,2}:){2}([0-9a-fA-F]{1,2})');

      final nintendoMACs = [
        'e8:4e:ce',
        'e0:e7:51',
        'e0:c:7f',
        'd8:6b:f7',
        'cc:fb:65',
        'cc:9e:0',
        'b8:ae:6e',
        'a4:c0:e1',
        'a4:5c:27',
        '9c:e6:35',
        '98:b6:e9',
        '8c:cd:e8',
        '8c:56:c5',
        '7c:bb:8a',
        '78:a2:a0',
        '58:bd:a3',
        '40:f4:7',
        '40:d2:8a',
        '34:af:2c',
        '2c:10:c1',
        '18:2a:7b',
        '0:27:9',
        '0:26:59',
        '0:25:a0',
        '0:24:f3',
        '0:24:44',
        '0:24:1e',
        '0:23:cc',
        '0:23:31',
        '0:22:d7',
        '0:22:aa',
        '0:22:4c',
        '0:21:bd',
        '0:21:47',
        '0:1f:c5',
        '0:1f:32',
        '0:1e:a9',
        '0:1e:35',
        '0:1d:bc',
        '0:1c:be',
        '0:1b:ea',
        '0:1b:7a',
        '0:1a:e9',
        '0:19:fd',
        '0:19:1d',
        '0:17:ab',
        '0:16:56',
        '0:9:bf',
      ];

      final lines = output.split('\n');
      final ipMatches = <String>[];
      final macMatches = <String>[];

      for (final line in lines) {
        final ipMatch = ipPattern.firstMatch(line);
        final macMatch = macPattern.firstMatch(line);

        if (ipMatch != null) {
          ipMatches.add(ipMatch.group(0)!);
        }
        if (macMatch != null) {
          var mac = macMatch.group(0)!.trim();
          macMatches.add(mac);
        }
      }

      int foundCount = 0;
      for (int i = 0; i < macMatches.length && i < ipMatches.length; i++) {
        var cleanedMAC = macMatches[i].trim();

        if (nintendoMACs.contains(cleanedMAC)) {
          addConsole(ipMatches[i], 5000);
          foundCount++;
        }
      }

      if (foundCount == 0) {
        onLog('No 3DS consoles detected');
      } else {
        onLog('Found $foundCount 3DS console(s)');
      }
    } catch (e) {
      onLog('Error during detection: $e');
    }
  }
}

class ConsoleItem {
  final String ipAddress;
  final int port;

  ConsoleItem({required this.ipAddress, required this.port});

  @override
  String toString() => '$ipAddress:$port';
}
