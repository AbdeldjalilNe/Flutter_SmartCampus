import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart' show GoRouter;

/// Adapts any stream into a [ChangeNotifier] so that [GoRouter]'s
/// `refreshListenable` can react to external state changes (e.g., AuthBloc).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
