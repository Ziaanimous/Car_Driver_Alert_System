import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:developer' as developer;

class BluetoothLogic {
  // Store the connected device
  BluetoothDevice? _connectedDevice;
  
  // Check if already connected to a device
  bool get isConnected => _connectedDevice != null;

  /// Check if already connected to a Bluetooth device
  ///
  /// Returns true if connected, false otherwise
  Future<bool> checkConnection() async {
    if (_connectedDevice != null) {
      // Check if the device is still connected
      try {
        final state = await _connectedDevice!.connectionState.first;
        if (state == BluetoothConnectionState.connected) {
          return true;
        } else {
          // Device is no longer connected, clear the reference
          _connectedDevice = null;
          return false;
        }
      } catch (e) {
        developer.log('Error checking connection: $e');
        _connectedDevice = null;
        return false;
      }
    }
    return false;
  }

  /// Go back to previous state (disconnect from current device)
  ///
  /// Returns true if successfully disconnected, false otherwise
  Future<bool> goBack() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        final String deviceName = _connectedDevice!.platformName ?? _connectedDevice!.remoteId.str;
        developer.log('Disconnected from $deviceName');
        _connectedDevice = null;
        return true;
      } catch (e) {
        developer.log('Failed to disconnect: $e');
        return false;
      }
    }
    return false;
  }

  /// Scan for available Bluetooth devices
  ///
  /// This method will scan for all available Bluetooth devices for 4 seconds
  /// and return the list of found devices.
  Future<List<ScanResult>> scanForDevices() async {
    List<ScanResult> foundDevices = [];

    // Start scanning
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    await FlutterBluePlus.scanResults.first.then((results) {
      foundDevices.addAll(results);
      for (ScanResult r in results) {
        final String deviceName = r.device.platformName ?? r.device.remoteId.str;
        developer.log('$deviceName found! rssi: ${r.rssi}');
      }
    });

    // Stop scanning after timeout
    await FlutterBluePlus.stopScan();
    
    return foundDevices;
  }

  /// Connect to a specific Bluetooth device
  ///
  /// [device] The Bluetooth device to connect to
  /// Returns true if successfully connected, false otherwise
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      final String deviceName = device.platformName ?? device.remoteId.str;
      developer.log('Connected to $deviceName');
      _connectedDevice = device;
      return true;
    } catch (e) {
      final String deviceName = device.platformName ?? device.remoteId.str;
      developer.log('Failed to connect to $deviceName: $e');
      return false;
    }
  }

  /// Disconnect from a Bluetooth device
  ///
  /// [device] The Bluetooth device to disconnect from
  /// Returns true if successfully disconnected, false otherwise
  Future<bool> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      final String deviceName = device.platformName ?? device.remoteId.str;
      developer.log('Disconnected from $deviceName');
      if (_connectedDevice == device) {
        _connectedDevice = null;
      }
      return true;
    } catch (e) {
      final String deviceName = device.platformName ?? device.remoteId.str;
      developer.log('Failed to disconnect from $deviceName: $e');
      return false;
    }
  }
  
  /// Get the currently connected device
  ///
  /// Returns the connected BluetoothDevice or null if not connected
  BluetoothDevice? get connectedDevice => _connectedDevice;
}