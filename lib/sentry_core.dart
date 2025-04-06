import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'main.dart';

/// guided by
/// https://www.youtube.com/watch?v=4djseRVSan8
///
/// A comprehensive service for managing error tracking and reporting with Sentry
class SentryService {
  /// Singleton instance for global access
  static final SentryService _instance = SentryService._internal();

  factory SentryService() => _instance;

  SentryService._internal();

  /// Initialize Sentry with configuration
  Future<void> initializeSentry({
    required String sentryDsn,
    bool enableAutoSessionTracking = true,
    double tracesSampleRate = 1, //  look at sentry pricing
    bool collectIP = false,
  }) async => await SentryFlutter.init((options) {
    options.dsn = sentryDsn;
    options.tracesSampleRate = tracesSampleRate;
    options.enableAutoSessionTracking = enableAutoSessionTracking;

    /// those are errors that are cached in local until reaching internet
    options.maxCacheItems = 5;
    options.sendDefaultPii = collectIP;
    // options.debug = false;

    /// Performance Related
    options.enableAutoPerformanceTracing = false;

    // Only enable release tracking in production
    // if (kReleaseMode) {
    //   options.environment = '';
    // }
  }, appRunner: () => runApp(const MyApp()));

  /// Capture a handled exception with optional context
  Future<SentryId> captureException({
    required dynamic exception,
    dynamic stackTrace,
    Hint? hint,
    FutureOr<void> Function(Scope)? withScope,
  }) async {
    debugPrint('create exception $exception');
    return Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint,
      withScope: withScope,
    );
  }

  /// Log a custom message to Sentry
  Future<SentryId> captureMessage({
    required String message,
    SentryLevel? level,
    Hint? hint,
    FutureOr<void> Function(Scope)? withScope,
  }) async {
    // we already handled it, but still want to log it
    debugPrint('capture message $message');
    return Sentry.captureMessage(
      message,
      level: level,
      hint: hint,
      withScope: withScope,
    );
  }

  /// Add custom breadcrumb for detailed tracking
  void addBreadcrumb({
    required String message,
    String category = 'default',
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(
      Breadcrumb(category: category, message: message, data: data),
    );
  }

  /// Set user context for better error tracking
  Future<void> setUserContext({
    required String id,
    String? email,
    String? username,
  }) async {
    final user = SentryUser(id: id, email: email, username: username);

    await Sentry.configureScope((scope) => scope.setUser(user));
  }

  /// Add custom tags to all future events
  Future<void> setTag({required String key, required String value}) async {
    await Sentry.configureScope((scope) => scope.setTag(key, value));
  }

  /// Capture and report unhandled errors Automatically
  void captureUnhandledErrors() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error to Sentry in both debug and release modes
      Sentry.captureException(details.exception, stackTrace: details.stack);

      // Also print to console in debug mode
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
  }
}
