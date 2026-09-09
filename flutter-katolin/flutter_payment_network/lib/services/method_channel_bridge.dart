import 'package:flutter/services.dart';

/// Communication Bridge between Flutter and Native Kotlin Android
class MethodChannelBridge {
  static const MethodChannel _channel = MethodChannel('com.example.shopik/telecom');
  static const MethodChannel _legacyChannel = MethodChannel('com.example.shopik/payment_network');

  static Function(String phone)? onContactPicked;
  static Function()? onSyncBalanceRequested;
  static Function(String route, Map<String, dynamic> args)? onNavigateToScreen;

  /// Initialize MethodChannel listener
  static void initialize() {
    _channel.setMethodCallHandler(_handleCall);
    _legacyChannel.setMethodCallHandler(_handleCall);
  }

  static Future<dynamic> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'onContactSelected':
        final phone = call.arguments?['phone']?.toString();
        if (phone != null && onContactPicked != null) {
          onContactPicked!(phone);
        }
        break;
      case 'onSyncBalance':
        if (onSyncBalanceRequested != null) {
          onSyncBalanceRequested!();
        }
        break;
      case 'navigateToRoute':
        final route = call.arguments?['route']?.toString() ?? '';
        final args = call.arguments != null ? Map<String, dynamic>.from(call.arguments) : <String, dynamic>{};
        if (onNavigateToScreen != null) {
          onNavigateToScreen!(route, args);
        }
        break;
      default:
        break;
    }
  }

  /// Request Android Native Contact Picker
  static Future<String?> pickContactFromNative() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('pickContact');
      if (result is Map) {
        return result['phone']?.toString();
      } else if (result is String) {
        return result;
      }
      return null;
    } on PlatformException catch (e) {
      print('Error picking contact from native: ${e.message}');
      return null;
    }
  }

  /// Notify Native to sync wallet balance
  static Future<void> syncWalletBalance() async {
    try {
      await _channel.invokeMethod('syncWalletBalance');
    } catch (_) {}
  }

  /// Close Flutter screen and return to Kotlin Compose navigation
  static Future<void> closeScreen() async {
    try {
      await _channel.invokeMethod('closeScreen');
    } catch (_) {}
  }

  /// Navigate back or trigger native route
  static Future<void> openNativeScreen(String routeName, [Map<String, dynamic>? params]) async {
    try {
      await _channel.invokeMethod('openNativeScreen', {
        'route': routeName,
        'params': params ?? {},
      });
    } catch (_) {}
  }

  /// Get initial session data passed from Kotlin
  static Future<Map<String, dynamic>> getInitialSession() async {
    try {
      final data = await _channel.invokeMethod<dynamic>('getInitialSession');
      return data != null && data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (_) {
      return {};
    }
  }
}
