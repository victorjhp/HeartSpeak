import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> recommendedWords = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendedWords();
    // 2시간마다 추천 단어를 갱신
    Timer.periodic(Duration(hours: 2), (Timer t) => fetchRecommendedWords());
  }

Future<void> fetchRecommendedWords() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    print('Fetching recommended words for user: ${user.uid}');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5001/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': user.uid}),
    );

    if (response.statusCode == 200) {
      // 서버로부터 받은 JSON 응답을 Map 형식으로 디코딩
      final Map<String, dynamic> data = json.decode(response.body);

      // positive_recommendations와 negative_recommendations를 각각 리스트로 변환
      List<String> positiveRecommendations = List<String>.from(data['positive_recommendations']);
      List<String> negativeRecommendations = List<String>.from(data['negative_recommendations']);

      print('Received positive recommendations: $positiveRecommendations');
      print('Received negative recommendations: $negativeRecommendations');

      // 추천 단어들을 병합하여 각각 첫 번째 단어를 선택
      List<String> words = [];
      if (positiveRecommendations.isNotEmpty) {
        words.add(positiveRecommendations.first);
      }
      if (negativeRecommendations.isNotEmpty) {
        words.add(negativeRecommendations.first);
      }

      // 추천 단어가 두 개보다 적을 경우 기본값으로 채우기
      if (words.isEmpty) {
        words = ["No recommendation available", "No recommendation available"];
      } else if (words.length < 2) {
        words.add("No recommendation available");
      }

      setState(() {
        recommendedWords = words;
      });
    } else {
      throw Exception('Failed to load recommendations');
    }
  } catch (error) {
    print('Error: $error');
    setState(() {
      recommendedWords = ["Error loading recommendations", "Error loading recommendations"];
    });
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EduBridge', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchRecommendedWords(); 
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AnalysisScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3, // 3 columns
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          children: <Widget>[
            buildGridItem(context, 'More!', Colors.blue),
            buildGridItem(context, 'Yes!', Colors.green),
            buildGridItem(context, 'No!', Colors.red),
            buildGridItem(context, 'Thank you!', Colors.orange),
            buildRandomWordGridItem(context, 0),
            buildRandomWordGridItem(context, 1),
          ],
        ),
      ),
    );
  }

Widget buildGridItem(BuildContext context, String label, Color buttonColor) {
  return Container(
    decoration: BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
      ],
    ),
    child: ElevatedButton(
      onPressed: () async {
        User? user = _auth.currentUser;
        if (user != null) {
          await updateClickFrequency(user.uid, label);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          fontSize: 24,  // 글자 크기를 24로 설정 (원하는 크기로 조절 가능)
        ),
      ),
    ),
  );
}

Widget buildRandomWordGridItem(BuildContext context, int index) {
  if (index >= recommendedWords.length) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Center(
        child: Text(
          'No recommendation available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,  // 글자 크기를 24로 설정
          ),
        ),
      ),
    );
  }

  String label = recommendedWords[index];
  return buildGridItem(context, label, Colors.purple);
}

  Future<void> updateClickFrequency(String userId, String word) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5001/update_click'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'word': word}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update click frequency');
      }
    } catch (error) {
      print('Error updating click frequency: $error');
    }
  }
}
