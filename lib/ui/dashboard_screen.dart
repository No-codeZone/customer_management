import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:employee_management/ui/user_contact_screen.dart';
import 'package:employee_management/ui/user_profile_screen.dart';
import 'package:employee_management/ui/userlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_user_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NotchBottomBarController _controller = NotchBottomBarController();
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UserListScreen(),
    const UserContactsScreen(),
    const UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddUser() async {
    bool? userAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddUserScreen()),
    );

    if (userAdded == true) {
      setState(() {});
    }
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Confirm Logout",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
            ),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Destroy session

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              color: Colors.white,
              onPressed: (){
                _showLogoutDialog();
              }, icon: Icon(Icons.power_settings_new,),
            ),
          )
        ],
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUser,
        backgroundColor: Colors.blueGrey,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        kIconSize: 24,
        kBottomRadius: 20,
        color: Colors.blueGrey,
        showLabel: true,
        onTap: _onItemTapped,
        bottomBarItems: const [
          BottomBarItem(
              inActiveItem: Icon(Icons.groups, color: Colors.white),
              activeItem: Icon(Icons.groups, color: Colors.blueGrey),
              itemLabel: 'Users'),
          BottomBarItem(
              inActiveItem: Icon(Icons.phone, color: Colors.white),
              activeItem: Icon(Icons.phone, color: Colors.blueGrey),
              itemLabel: 'Contacts'),
          BottomBarItem(
              inActiveItem: Icon(Icons.person, color: Colors.white),
              activeItem: Icon(Icons.person, color: Colors.blueGrey),
              itemLabel: 'Profile'),
        ],
      ),
    );
  }
}
