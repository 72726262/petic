import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts a [Stream] into a [ChangeNotifier] so that GoRouter
/// can watch auth state changes and trigger its redirect guard
/// whenever the auth session is created or destroyed.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
