import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/db_helper.dart';

class UserContactsScreen extends StatefulWidget {
  const UserContactsScreen({super.key});

  @override
  State<UserContactsScreen> createState() => _UserContactsScreenState();
}

class _UserContactsScreenState extends State<UserContactsScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _onTapCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid phone number!")),
      );
      return;
    }

    // Format phone number properly
    final Uri url = Uri.parse("tel:${Uri.encodeComponent(phoneNumber)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch dialer!")),
      );
    }
  }

  Future<void> _fetchContacts() async {
    List<Map<String, dynamic>> users = await _dbHelper.getUsers();
    setState(() {
      _contacts = users
          .map((user) => {
                "name": user["name"],
                "contact": user["contact"],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("User Contacts")),
      body: _contacts.isEmpty
          ? const Center(child: Text("No contacts found."))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: ListTile(
                    leading: InkWell(
                        child: Icon(Icons.phone, color: Colors.green),
                        onTap: () => _onTapCall(contact["contact"]),
                ),
                    title: Text(contact["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: InkWell(
                      child: Text(contact["contact"],
                          style: const TextStyle(fontSize: 16)),
                        onTap: () => _onTapCall(contact["contact"]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
