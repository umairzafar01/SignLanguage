import 'package:flutter/material.dart';
import '../../core/widgets/common_widgets.dart';
import '../dashboard/dashboard_screen.dart';
import '../dictionary/dictionary_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  /// Pass an initial tab index (0=Home, 1=Dictionary, 2=Profile)
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 2);
  }

  late final _screens = [
    const DashboardScreen(),
    const DictionaryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
