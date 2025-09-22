import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/firestore_helper.dart';

class AACButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color buttonColor;

  AACButton({
    required this.label,
    required this.onPressed,
    required this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        onPressed();
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirestoreHelper().logButtonClick(user.uid, label);
        }
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
