import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();

  static final instance = ConnectivityService._();
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _online = false;
  int _checkId = 0;

  bool get online => _online;

  Future<void> initialize() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen((_) => refresh());
    await refresh();
  }

  Future<void> refresh() async {
    final current = ++_checkId;
    bool reachable = false;
    try {
      final types = await _connectivity.checkConnectivity()
          .timeout(const Duration(seconds: 2));
      if (types.any((type) => type != ConnectivityResult.none)) {
        const backend = String.fromEnvironment('SKINX_API_URL');
        final checks = [
          if (backend.isNotEmpty) '${backend.replaceAll(RegExp(r"/+$"), "")}/health',
          'https://www.google.com/generate_204',
          'https://connectivitycheck.gstatic.com/generate_204',
        ];
        for (final address in checks) {
          try {
            final response = await http.get(Uri.parse(address))
                .timeout(const Duration(seconds: 2));
            if (response.statusCode == 204 ||
                (address.endsWith('/health') && response.statusCode == 200)) {
              reachable = true;
              break;
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    if (current != _checkId) return;
    if (_online != reachable) {
      _online = reachable;
      notifyListeners();
    }
  }
}
