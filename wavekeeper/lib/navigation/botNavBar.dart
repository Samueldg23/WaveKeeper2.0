import 'package:flutter/material.dart';
import 'package:wavekeeper/screens/business/business.dart';
import 'package:wavekeeper/screens/home/home.dart';
import 'package:wavekeeper/screens/profile/profile.dart';

class BottomNavBar extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const BottomNavBar({Key? key, required this.userId, this.initialIndex = 0}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomeView(userId: widget.userId),
      BusinessView(userId: widget.userId),
      ProfileView(userId: widget.userId),
    ];

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Negócios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
