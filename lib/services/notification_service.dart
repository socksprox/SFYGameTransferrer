import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isServerRunning = false;
  int _activeDownloads = 0;
  String _currentFileName = '';
  int _currentProgress = 0;

  static const String _channelId = 'download_channel';
  static const String _channelName = 'Download Progress';
  static const String _channelDescription =
      'Shows download progress and keeps server running';
  static const int _notificationId = 1;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!Platform.isAndroid) {
      _isInitialized = true;
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    await _createNotificationChannel();

    _isInitialized = true;
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissionsWithExplanation({
    Future<bool> Function()? showExplanationDialog,
  }) async {
    if (!Platform.isAndroid) {
      return true;
    }

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final alreadyGranted = await androidImplementation
        ?.areNotificationsEnabled();
    if (alreadyGranted == true) {
      return true;
    }

    if (showExplanationDialog != null) {
      final shouldProceed = await showExplanationDialog();
      if (!shouldProceed) {
        return false;
      }
    }

    final granted = await androidImplementation
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    if (response.actionId == 'stop_server') {
      await onStopServerRequested?.call();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onBackgroundNotificationTap(
    NotificationResponse response,
  ) async {
    if (response.actionId == 'stop_server') {
      await NotificationService().onStopServerRequested?.call();
    }
  }

  Future<void> Function()? onStopServerRequested;

  Future<void> startForegroundService() async {
    if (!Platform.isAndroid || !_isInitialized) {
      return;
    }

    _isServerRunning = true;
    await _updateNotification();
  }

  Future<void> updateDownloadProgress({
    required String fileName,
    required int progress,
    required int activeDownloads,
  }) async {
    if (!Platform.isAndroid || !_isInitialized) return;

    _currentFileName = fileName;
    _currentProgress = progress;
    _activeDownloads = activeDownloads;

    await _updateNotification();
  }

  Future<void> _updateNotification() async {
    if (!Platform.isAndroid || !_isInitialized || !_isServerRunning) {
      return;
    }

    final String title = _activeDownloads > 0
        ? 'Downloading files ($_activeDownloads active)'
        : 'Server running - Ready for downloads';

    final String body = _activeDownloads > 0
        ? '$_currentFileName - $_currentProgress%'
        : 'Tap to stop server';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: _activeDownloads > 0,
      autoCancel: false,
      showProgress: _activeDownloads > 0,
      maxProgress: 100,
      progress: _currentProgress,
      icon: '@mipmap/ic_launcher',
      actions: [
        const AndroidNotificationAction(
          'stop_server',
          'Stop Server',
          showsUserInterface: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(
        _notificationId,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {}
  }

  Future<void> stopForegroundService() async {
    if (!Platform.isAndroid || !_isInitialized) {
      return;
    }

    _isServerRunning = false;
    _activeDownloads = 0;
    _currentFileName = '';
    _currentProgress = 0;

    await _notifications.cancel(_notificationId);
  }

  bool get isServerRunning => _isServerRunning;
  int get activeDownloads => _activeDownloads;
}
