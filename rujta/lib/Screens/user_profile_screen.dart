import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Profile",
    style: TextStyle(color: Color(0xFF4CAF50)
    ,fontWeight: FontWeight.bold
    ),
    ),),
    body:SingleChildScrollView(
      child: Column(
     children: [
      const SizedBox(height: 20),
      Container(
        width:double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
          ],
        ),
      )
     ],
    )
    )
    );
  }
}
