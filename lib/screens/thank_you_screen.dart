import 'package:flutter/material.dart';

class ThankYouScreen extends StatefulWidget {
  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
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
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Thank You!',
              style: TextStyle(fontSize: 84, color: Colors.white),
            ),
            SizedBox(height: 20),
            Image(
              image: AssetImage('images/thankyou.jpeg'),
              width: 580,
              height: 580,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
