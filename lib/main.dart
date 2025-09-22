import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart'; 
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseAuth>(
          create: (_) => FirebaseAuth.instance,
        ),
        StreamProvider<User?>(
          create: (context) => context.read<FirebaseAuth>().authStateChanges(),
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'EduBridge',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.blueGrey[900],
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Colors.orangeAccent,
          ),
          textTheme: TextTheme(
            headlineLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey[700],
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthenticationWrapper(),
          '/register': (context) => RegisterScreen(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user != null) {
      return HomeScreen();
    }
    return LoginScreen();
  }
}
