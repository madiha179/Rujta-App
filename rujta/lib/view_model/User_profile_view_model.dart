import 'package:Rujta/models/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProfileViewModel {
  Future<String> getUserCurrentAddress() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return 'service is unavaliable';
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return "Access denied";
    }
    Position position = await Geolocator.getCurrentPosition();
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      return "${place.locality},${place.country}";
    } catch (err) {
      return "Unable to fetch the region name";
    }
  }
}

Future<Usermodel> fetchUserProfile() async {
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  final url = Uri.parse(
    'https://rujta-app-production.up.railway.app/api/v1/users/userprofile',
  );
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final userData = responseData['data']['result'][0];
    return Usermodel.fromJson(userData);
  } else {
    throw Exception('Failed to load profile');
  }
}

Future<bool> updateUserName(String newName) async {
  final url = Uri.parse(
    'https://rujta-app-production.up.railway.app/api/v1/users/userprofile/updates/name',
  );
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({"name": newName}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['result']['affectedRows'] == 1;
  } else {
    return false;
  }
}

Future<bool> updatePhone(String newPhone) async {
  final url = Uri.parse(
    'https://rujta-app-production.up.railway.app/api/v1/users/userprofile/updates/phone',
  );
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({"phone": newPhone}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['result']['affectedRows'] == 1;
  } else {
    return false;
  }
}

Future<String> updatePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  final url = Uri.parse(
    'https://rujta-app-production.up.railway.app/api/v1/users/userprofile/updates/password',
  );
  const storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'auth_token');
  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      "currentPassword": currentPassword,
      "newPassword": newPassword,
      "confirmNewPassword": confirmPassword,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return "success";
  } else {
    return data['message'] ?? "Something went wrong";
  }
}
