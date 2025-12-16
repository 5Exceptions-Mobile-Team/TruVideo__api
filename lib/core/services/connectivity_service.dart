import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to check internet connectivity status
/// Provides reusable functions to check if user has internet/wifi connected
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();

  ConnectivityService._internal();

  /// Check if device has any network connection (WiFi or Mobile Data)
  /// Returns true if connected to WiFi or Mobile Data, false otherwise
  Future<bool> hasConnection() async {
    try {
      final List<ConnectivityResult> connectivityResults = await _connectivity
          .checkConnectivity();

      return connectivityResults.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Check if device is connected to WiFi
  /// Returns true if connected to WiFi, false otherwise
  Future<bool> isConnectedToWifi() async {
    try {
      final List<ConnectivityResult> connectivityResults = await _connectivity
          .checkConnectivity();

      return connectivityResults.contains(ConnectivityResult.wifi);
    } catch (e) {
      print('Error checking WiFi connectivity: $e');
      return false;
    }
  }

  /// Check if device is connected to Mobile Data
  /// Returns true if connected to Mobile Data, false otherwise
  Future<bool> isConnectedToMobileData() async {
    try {
      final List<ConnectivityResult> connectivityResults = await _connectivity
          .checkConnectivity();

      return connectivityResults.contains(ConnectivityResult.mobile);
    } catch (e) {
      print('Error checking mobile data connectivity: $e');
      return false;
    }
  }

  /// Check if device has actual internet access (not just network connection)
  /// This performs a real network request to verify internet connectivity
  /// Returns true if device can reach the internet, false otherwise
  Future<bool> hasInternetAccess() async {
    try {
      // First check if there's any network connection
      final bool hasNetwork = await hasConnection();
      if (!hasNetwork) {
        return false;
      }

      // Try to reach a reliable server to verify actual internet access
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('Error checking internet access: $e');
      return false;
    }
  }

  /// Get the current connectivity type
  /// Returns ConnectivityResult indicating the type of connection
  Future<List<ConnectivityResult>> getConnectivityType() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      print('Error getting connectivity type: $e');
      return [];
    }
  }

  /// Stream of connectivity changes
  /// Listen to this stream to get real-time updates on connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
