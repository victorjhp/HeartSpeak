import 'package:flutter/material.dart';

class NoScreen extends StatefulWidget {
  @override
  _NoScreenState createState() => _NoScreenState();
}

class _NoScreenState extends State<NoScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No!',
              style: TextStyle(fontSize: 84, color: Colors.white),
            ),
            SizedBox(height: 15),
            Image(
              image: AssetImage('images/no.jpeg'),
              width: 600,
              height: 600,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
