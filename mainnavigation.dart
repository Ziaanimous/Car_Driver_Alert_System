import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'screens/home.dart';
import 'screens/data.dart';
import 'screens/settings.dart';
import 'screens/logic/data_logic.dart';
import 'screens/logic/camera_service.dart';

class MainNavigation extends StatefulWidget {
  final String username;
  final List<CameraDescription> cameras;
  const MainNavigation({
    super.key,
    required this.username,
    required this.cameras,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  late CameraService _cameraService;
  late List<Widget> _screens;
  late AnimationController _controller;
  Animation<double>? _circleXPosition;

  final List<GlobalKey> _iconKeys = [GlobalKey(), GlobalKey(), GlobalKey()];

  double _circleLeft = 0;

  @override
  void initState() {
    super.initState();

    // Initialize camera service
    _cameraService = CameraService();
    _cameraService.initializeCamera(widget.cameras);

    _screens = [
      const DataScreen(),
      HomePage(),
      SettingsScreen(username: widget.username),
      HomePage(),
      SettingsScreen(username: widget.username),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCirclePosition(_selectedIndex, animate: false);
    });
  }

  void _onItemTapped(int index) {
    // Add haptic feedback for better UX
    // HapticFeedback.lightImpact();

    _updateCirclePosition(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateCirclePosition(int index, {bool animate = true}) {
    final context = _iconKeys[index].currentContext;
    if (context == null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final newLeft = position.dx + renderBox.size.width / 2 - 30;

    if (!animate) {
      setState(() {
        _circleLeft = newLeft;
      });
      return;
    }

    final oldLeft = _circleLeft;
    final tween = Tween<double>(begin: oldLeft, end: newLeft);

    _circleXPosition = tween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _circleLeft = newLeft;
        _circleXPosition = null;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DataLogic>(
          create: (context) => DataLogic(),
        ),
        ChangeNotifierProvider<CameraService>(
          create: (context) => _cameraService,
        ),
      ],
      child: Scaffold(
        extendBody: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
        bottomNavigationBar: Stack(
          children: [
            Container(
              height: 75,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavIcon(Icons.storage_outlined, 0, 'Data'),
                  _buildNavIcon(Icons.home_outlined, 1, 'Home'),
                  _buildNavIcon(Icons.settings_outlined, 2, 'Settings'),
                ],
              ),
            ),
            if (_circleXPosition != null)
              AnimatedBuilder(
                animation: _circleXPosition!,
                builder: (context, child) {
                  return _buildCircle(_circleXPosition!.value);
                },
              )
            else
              _buildCircle(_circleLeft),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double left) {
    return Positioned(
      bottom: 12,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF018ABD),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF018ABD).withAlpha(76),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            _selectedIndex == 0
                ? Icons.storage_outlined
                : _selectedIndex == 1
                ? Icons.home_outlined
                : Icons.settings_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        key: _iconKeys[index],
        width: 60,
        height: 75,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isSelected ? 0.0 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 0.8 : 1.0,
                child: Icon(icon, color: Colors.grey[600], size: 30),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? const Color(0xFF018ABD) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
