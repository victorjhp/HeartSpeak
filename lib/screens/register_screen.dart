import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/firestore_helper.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC), 
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/edubridge_logo.png', height: 100),
              SizedBox(height: 40),
              Text(
                'Register to EduBridge',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown[700]),
              ),
              SizedBox(height: 20),
              _buildTextField(emailController, 'Email', Icons.email),
              SizedBox(height: 10),
              _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
              SizedBox(height: 5),
              _buildErrorText(),
              SizedBox(height: 30),
              _buildRegisterButton(context),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.brown[700],
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown[700]),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.brown[700]),
        filled: true,
        fillColor: Color(0xFFFFEFD5), // 베이지 색상
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.brown[300]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.brown[500]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      obscureText: isPassword,
    );
  }

  Widget _buildErrorText() {
    return errorMessage.isEmpty
        ? Container()
        : Text(
            errorMessage,
            style: TextStyle(color: Colors.red, fontSize: 12),
          );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _register(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text('Register'),
    );
  }

  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (userCredential.user != null) {
        await FirestoreHelper().createUserDocument(userCredential.user!);
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString(); // 에러 메시지를 자세히 출력
      });
    }
  }
}
