import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

class BluetoothSettingsScreen extends StatefulWidget {
  const BluetoothSettingsScreen({super.key});

  @override
  State<BluetoothSettingsScreen> createState() => _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState extends State<BluetoothSettingsScreen> {
  bool _isBluetoothOn = false;
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  StreamSubscription<BluetoothAdapterState>? _bluetoothStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Check if Bluetooth is on
    _isBluetoothOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
    if (mounted) setState(() {});

    // Subscribe to Bluetooth state changes
    _bluetoothStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() {
          _isBluetoothOn = state == BluetoothAdapterState.on;
        });
      }
    });

    // Subscribe to scan results
    _scanResultsSubscription = FlutterBluePlus.onScanResults.listen((results) {
      if (mounted) {
        setState(() {
          _devices = results.map((r) => r.device).toList();
        });
      }
    });
  }

  Future<void> _toggleBluetooth() async {
    if (!mounted) return;
    
    final BuildContext currentContext = context;
    try {
      if (_isBluetoothOn) {
        // Note: turnOff is deprecated in Android SDK 33 with no replacement
        // This will only work on older Android versions
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Please turn off Bluetooth from system settings')),
        );
      } else {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error toggling Bluetooth: $e')),
      );
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;
    if (!mounted) return;
    
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    final BuildContext currentContext = context;
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error starting scan: $e')),
      );
    }
  }

  Future<void> _stopScan() async {
    if (!mounted) return;
    
    final BuildContext currentContext = context;
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error stopping scan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (!mounted) return;
    
    final BuildContext currentContext = context;
    try {
      await device.connect();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Connected to device')),
      );
      
      // Navigate back to previous screen after successful connection
      Navigator.of(currentContext).pop();
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error connecting to device: $e')),
      );
    }
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bluetooth status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bluetooth',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isBluetoothOn ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: _isBluetoothOn ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isBluetoothOn,
                    onChanged: (value) => _toggleBluetooth(),
                    activeColor: const Color(0xFF018ABD),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Scan section
            Text(
              'Available Devices',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            // Scan button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isBluetoothOn
                    ? (_isScanning ? _stopScan : _startScan)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF018ABD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isScanning ? 'Scanning...' : 'Scan for Devices',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Device list
            if (_devices.isEmpty && !_isScanning)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No devices found. Tap "Scan for Devices" to search.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(device.platformName ?? 'Unknown Device'),
                      subtitle: Text(device.remoteId.str),
                      trailing: ElevatedButton(
                        onPressed: () => _connectToDevice(device),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF018ABD),
                        ),
                        child: const Text('Connect', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
