import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  StreamSubscription<ConnectivityResult>? _subscription;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void initialize() {
    _subscription = Connectivity().onConnectivityChanged.transform(
      StreamTransformer<List<ConnectivityResult>, ConnectivityResult>.fromHandlers(
        handleData: (data, sink) {
          // Just take the first result for simplicity
          sink.add(data.first);
        },
      ),
    ).listen((ConnectivityResult result) {
      _showStatus(result);
    });
  }

  void _showStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _showSnackBar(
        'You are offline. Please check your internet connection.',
        Colors.red,
        Duration(days: 1), // Keep persistent until back online
      );
    } else {
      // Only show "Back online" if we were previously offline (tracking this state is complex without a variable, 
      // but for now we'll just clear the persistent snackbar)
      
      // We can try to remove the current snackbar
      final state = scaffoldMessengerKey.currentState;
      if (state != null) {
        state.clearSnackBars();
        // Optional: Show "Back online" briefly
        // _showSnackBar('Back online!', Colors.green, Duration(seconds: 3));
      }
    }
  }

  void _showSnackBar(String message, Color color, Duration duration) {
    final state = scaffoldMessengerKey.currentState;
    if (state != null) {
      state.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
