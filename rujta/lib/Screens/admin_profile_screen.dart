import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const Color _green = Color(0xFF4CAF50);
  static const String _base = 'https://rujta-app-production.up.railway.app';

  final _storage = const FlutterSecureStorage();

  bool _loading = true;
  String _name    = '';
  String _email   = '';
  String _phone   = '';
  int    _adminId = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final results = await Future.wait([
        http.get(
          Uri.parse('$_base/api/v1/users/userprofile'),
          headers: headers,
        ),
        http.get(
          Uri.parse('$_base/api/v1/users/userprofile/admin'),
          headers: headers,
        ),
      ]);

      print('PROFILE RESP: ${results[0].body}');
      print('ADMIN ID RESP: ${results[1].body}');

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body);
        final user = data['data']?['result'] is List
            ? data['data']['result'][0]
            : data['data']?['result'] ?? {};
        setState(() {
          _name  = user['name']  ?? '';
          _email = user['email'] ?? '';
          _phone = user['phone'] ?? '';
        });
      }

      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body);
        setState(() => _adminId = data['adminId'] ?? 0);
      }
    } catch (e) {
      debugPrint('Load admin profile error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Edit Name ─────────────────────────────────────────────────────────────
  void _showEditNameDialog() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter your new name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () async {
              Navigator.pop(ctx);
              await _updateName(ctrl.text.trim());
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName(String newName) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.patch(
        Uri.parse('$_base/api/v1/users/userprofile/updates/name'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': newName}),
      );
      if (res.statusCode == 200) {
        setState(() => _name = newName);
        _snack('Name updated successfully!');
      }
    } catch (e) {
      _snack('Failed to update name');
    }
  }

  // ── Edit Phone ────────────────────────────────────────────────────────────
  void _showEditPhoneDialog() {
    final ctrl = TextEditingController(text: _phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          decoration:
              const InputDecoration(hintText: 'Enter your new phone number'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () async {
              Navigator.pop(ctx);
              await _updatePhone(ctrl.text.trim());
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhone(String newPhone) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.patch(
        Uri.parse('$_base/api/v1/users/userprofile/updates/phone'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phone': newPhone}),
      );
      if (res.statusCode == 200) {
        setState(() => _phone = newPhone);
        _snack('Phone updated successfully!');
      }
    } catch (e) {
      _snack('Failed to update phone');
    }
  }

  // ── Change Password ───────────────────────────────────────────────────────
  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Password',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password')),
            const SizedBox(height: 8),
            TextField(
                controller: newCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 8),
            TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm New Password')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: _green),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _changePassword(
                    current: currentCtrl.text,
                    newPass: newCtrl.text,
                    confirm: confirmCtrl.text,
                  );
                },
                child: const Text('Save New Password',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword({
    required String current,
    required String newPass,
    required String confirm,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final res = await http.patch(
        Uri.parse('$_base/api/v1/users/userprofile/updates/password'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword':    current,
          'newPassword':        newPass,
          'confirmNewPassword': confirm,
        }),
      );
      if (res.statusCode == 200) {
        _snack('Password updated successfully!');
      } else {
        final data = jsonDecode(res.body);
        _snack(data['message'] ?? 'Failed to update password');
      }
    } catch (e) {
      _snack('Something went wrong');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> _signOut() async {
    await _storage.deleteAll();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Info Card ─────────────────────────────────────────────────────────────
  Widget _infoCard({
    required IconData icon,
    required String   label,
    required String   value,
    Color?            iconColor,
    VoidCallback?     onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: iconColor ?? Colors.black54, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value.isEmpty ? '—' : value,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black87),
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit,
                        size: 18, color: Colors.black45),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Admin Profile',
          style: TextStyle(
            color: _green,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 28),

                  Text(
                    _name.isEmpty ? 'Admin' : _name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SENIOR PHARMACIST ADMINISTRATOR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black45,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _infoCard(
                    icon:      Icons.badge_outlined,
                    label:     'Admin ID',
                    value:     _adminId == 0
                        ? '—'
                        : 'ADM-${_adminId.toString().padLeft(5, '0')}',
                    iconColor: Colors.black54,
                  ),

                  _infoCard(
                    icon:      Icons.email_outlined,
                    label:     'Email',
                    value:     _email,
                    iconColor: Colors.black54,
                  ),

                  _infoCard(
                    icon:      Icons.person,
                    label:     'Full Name',
                    value:     _name,
                    iconColor: _green,
                    onEdit:    _showEditNameDialog,
                  ),

                  _infoCard(
                    icon:      Icons.phone,
                    label:     'Phone Number',
                    value:     _phone,
                    iconColor: _green,
                    onEdit:    _showEditPhoneDialog,
                  ),

                  const SizedBox(height: 20),

                  const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account Security',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: _showChangePasswordSheet,
                          leading: const Icon(Icons.lock_outline,
                              color: Colors.black54),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                        Divider(
                            height: 1,
                            indent: 54,
                            endIndent: 16,
                            color: Colors.grey.shade200),
                        ListTile(
                          onTap: _signOut,
                          leading:
                              const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

      // ✅ Nav Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Profile selected
        selectedItemColor: _green,
        unselectedItemColor: Colors.black38,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // ✅ يرجع للـ Inventory
            Navigator.pushReplacementNamed(context, '/InventoryManagement');
          }
        },
      ),
    );
  }
}