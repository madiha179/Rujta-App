import 'package:flutter/material.dart';

class email_dialog extends StatelessWidget {
  const email_dialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email_rounded,
            color: Color(0xFF69A03A),
            size: 50,
          ),
          SizedBox(height: 16),
          Text(
            "Check your email",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "We have sent password recovery instructions to your email",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        )
      ],
    );
  }
}