import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/db_helper.dart';
import 'map_screen.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _imagePath;
  double? _latitude, _longitude;
  final ImagePicker _picker = ImagePicker();
  final DBHelper _dbHelper = DBHelper();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _selectLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        addressController.text = result['address'];
      });
    }
  }

  Future<void> _saveUser() async {
    if (nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        _latitude == null ||
        _longitude == null ||
        _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields!"),backgroundColor: Colors.red,),
      );
      return;
    }

    Map<String, dynamic> user = {
      "name": nameController.text,
      "contact": contactController.text,
      "email": emailController.text,
      "address": addressController.text,
      "latitude": _latitude,
      "longitude": _longitude,
      "image": _imagePath,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Customer added!"),backgroundColor: Colors.green,),
    );
    await _dbHelper.insertUser(user);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Customer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Profile Image Picker
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: _imagePath == null
                          ? const Icon(Icons.camera_alt,
                              size: 30, color: Colors.black54)
                          : null,
                    ),
                    if (_imagePath != null)
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, color: Colors.blueGrey),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Input Fields
              _buildTextField(nameController, "Full Name", Icons.person),
              const SizedBox(height: 10),
              _buildTextField(contactController, "Contact", Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField(emailController, "Email", Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),

              // Address Field with Map Button
              TextField(
                controller: addressController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon:
                      const Icon(Icons.location_on, color: Colors.blueGrey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blueGrey),
                    onPressed: _selectLocationFromMap,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Location Display
              Text(
                _latitude != null
                    ? "Lat: $_latitude, Lng: $_longitude"
                    : "No location chosen",
                style: const TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveUser,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    "Save User",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
      ),
    );
  }
}
