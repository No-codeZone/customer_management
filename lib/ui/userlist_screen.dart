import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/db_helper.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _users = [];
  Set<int> _expandedUsers = {}; // Tracks which users are expanded

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<Map<String, dynamic>> users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri mapUri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _users.isEmpty
          ? const Center(child: Text("No users found."))
          : Container(
        decoration: const BoxDecoration(color: Color(0xfe8e8e8)),
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            bool isExpanded = _expandedUsers.contains(user["id"]);
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: user["image"] != null
                        ? Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        backgroundImage: FileImage(File(user["image"])),
                        radius: 25,
                      ),
                    )
                        : const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 25,
                      ),
                    ),
                    title: Text(
                      user["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedUsers.remove(user["id"]);
                          } else {
                            _expandedUsers.add(user["id"]);
                          }
                        });
                      },
                    ),
                  ),

                  // Expanded details when clicked
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.phone, "Contact", user["contact"]),
                              _buildInfoRow(Icons.email, "Email", user["email"]),

                              // Clickable Address
                              GestureDetector(
                                onTap: () {
                                  if (user["latitude"] != null && user["longitude"] != null) {
                                    _openMap(user["latitude"], user["longitude"]);
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.blueGrey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        user["address"],
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 5),
                              Text(
                                "Lat: ${user["latitude"]}, Lng: ${user["longitude"]}",
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),

                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: () => _deleteUser(user["id"]),
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  label: const Text(
                                    "Delete",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, "/addUser");
          if (result == true) {
            _fetchUsers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteUser(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Delete user",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          content: const Text(
            "Are you sure you want to delete user?",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _dbHelper.deleteUser(id);
                _fetchUsers();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
