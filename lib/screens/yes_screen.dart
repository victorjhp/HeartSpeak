import 'package:flutter/material.dart';

class YesScreen extends StatefulWidget {
  @override
  _YesScreenState createState() => _YesScreenState();
}

class _YesScreenState extends State<YesScreen> {
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
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Yes!',
              style: TextStyle(fontSize: 84, color: Colors.white),
            ),
            SizedBox(height: 20),
            Image(
              image: AssetImage('images/yes.jpeg'),
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
