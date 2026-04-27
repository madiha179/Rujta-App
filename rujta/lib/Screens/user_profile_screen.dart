import 'package:Rujta/models/userModel.dart';
import 'package:Rujta/view_model/User_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserProfileScreen> {
  late Future<Usermodel> futureUser;
  String _currentAddress = "Cairo, Egypt";

  @override
  void initState() {
    super.initState();
    futureUser = fetchUserProfile();
    _handleLocationUpdate();
  }

  void _handleLocationUpdate() async {
    String newAddress = await UserProfileViewModel().getUserCurrentAddress();
    if (mounted) {
      setState(() {
        _currentAddress = newAddress;
      });
    }
  }

  void _showEditNameDialog(String currentName) {
    TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Name"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Enter your new name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool success = await updateUserName(nameController.text);
              if (success) {
                Navigator.pop(context);
                setState(() {
                  futureUser = fetchUserProfile();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Name updated successfully!")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog(String currentPhone) {
    TextEditingController phoneController = TextEditingController(text: currentPhone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Phone Number"),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(hintText: "Enter your new Phone Number"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool success = await updatePhone(phoneController.text);
              if (success) {
                Navigator.pop(context);
                setState(() {
                  futureUser = fetchUserProfile();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Phone Number updated successfully!")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Change Password", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: currentPasswordController, decoration: const InputDecoration(labelText: "Current Password"), obscureText: true),
            TextField(controller: newPasswordController, decoration: const InputDecoration(labelText: "New Password"), obscureText: true),
            TextField(controller: confirmPasswordController, decoration: const InputDecoration(labelText: "Confirm New Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String result = await updatePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                  confirmPassword: confirmPasswordController.text,
                );
                if (result == "success") {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password Updated!"), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("Save New Password"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'auth_token');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signed out successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/Home');
          if (index == 1) Navigator.pushNamed(context, '/Drugstore');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Drugstore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Usermodel>(
        future: futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text("USER", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Color(0xFF4CAF50)),
                        title: Text("Email", style: TextStyle(fontSize: 14, color: const Color.fromARGB(82, 189, 189, 189))),
                        subtitle: Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Color(0xFF4CAF50)),
                        title: Text("Full Name", style: TextStyle(fontSize: 14, color: const Color.fromARGB(82, 189, 189, 189))),
                        subtitle: Text(user.name, style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditNameDialog(user.name)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
                        title: Text("Phone Number", style: TextStyle(color: const Color.fromARGB(82, 189, 189, 189))),
                        subtitle: Text(user.phone, style: const TextStyle(fontSize: 16)),
                        trailing: IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showEditPhoneDialog(user.phone)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text("Location", style: TextStyle(color: const Color.fromARGB(82, 189, 189, 189))),
                        subtitle: Text(_currentAddress),
                        trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _handleLocationUpdate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 10, top: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: const Text("Account Security", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            onTap: _showChangePasswordSheet,
                            leading: const Icon(Icons.lock, color: Color(0xFF454B3E)),
                            title: const Text("Change Password"),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                          Divider(height: 1, indent: 50, endIndent: 20, color: Colors.grey.shade200),
                          ListTile(
                            onTap: () => _handleSignOut(context),
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text("Sign Out", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          return const Center(child: Text('No profile data available.'));
        },
      ),
    );
  }
}