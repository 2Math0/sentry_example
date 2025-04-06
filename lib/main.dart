import 'package:flutter/material.dart';
import 'package:sentry_example/sentry_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  // Initialize Sentry before running the app
  await SentryService().initializeSentry(
    sentryDsn: 'https://149be919067515710e88b576b60505af@o4509032007008256.ingest.de.sentry.io/4509032008253520',
    tracesSampleRate: 1.0,
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SentryService _sentryService = SentryService();

  @override
  void initState() {
    super.initState();

    // Capture unhandled errors
    _sentryService.captureUnhandledErrors();

    // Optional: Add some example breadcrumbs and context
    _sentryService.addBreadcrumb(
      message: 'App Initialized',
      category: 'lifecycle',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Sentry Error Tracking Demo')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _triggerTestException,
                child: const Text('Trigger Test Exception'),
              ),
              ElevatedButton(
                onPressed: _triggerManualMessage,
                child: const Text('Log Manual Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Method to demonstrate exception capturing
  void _triggerTestException() {
    try {
      throw Exception('Test deliberate exception');
    } catch (e, stackTrace) {
      _sentryService.captureException(
        exception: e,
        stackTrace: stackTrace,
        hint: Hint(),
      );
    }
  }

  /// Method to demonstrate manual message logging
  void _triggerManualMessage() {
    _sentryService.captureMessage(message: 'Manual message log triggered');
  }
}
