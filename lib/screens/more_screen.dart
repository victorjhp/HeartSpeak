import 'package:flutter/material.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
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
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'More!',
              style: TextStyle(fontSize: 84, color: Colors.white),
            ),
            SizedBox(height: 20),
            Image(
              image: AssetImage('images/more.jpeg'),
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
