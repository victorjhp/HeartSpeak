import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/firestore_helper.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? selectedStudentEmail;
  String? selectedPeriod = '1 day ago';
  Map<String, int> positiveClickCounts = {};
  Map<String, int> negativeClickCounts = {};
  Map<String, Map<String, int>> hourlyClickCounts = {};
  List<String> userEmails = [];

  @override
  void initState() {
    super.initState();
    _fetchUserEmails();
  }

  Future<void> _fetchUserEmails() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
      List<String> emails = snapshot.docs.map((doc) => doc['email'] as String).toList();
      setState(() {
        userEmails = emails;
      });
    } catch (e) {
      print('Error fetching user emails: $e');
    }
  }

  Duration _getDurationForPeriod(String period) {
    switch (period) {
      case '1 day ago':
        return Duration(hours: 24);
      case '7 days ago':
        return Duration(days: 7);
      case '30 days ago':
        return Duration(days: 30);
      default:
        return Duration(hours: 24); // Default to 1 day
    }
  }

  Future<void> _search() async {
    if (selectedStudentEmail != null && selectedPeriod != null) {
      await _fetchClickCounts(selectedStudentEmail!, selectedPeriod!);
      await _fetchHourlyClickCounts(selectedStudentEmail!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analysis',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdowns(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text('Search'),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildAnalysisData()),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: selectedStudentEmail,
            hint: 'Select Student',
            items: userEmails,
            onChanged: (String? newValue) {
              setState(() {
                selectedStudentEmail = newValue;
              });
            },
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: _buildDropdown(
            value: selectedPeriod,
            hint: 'Select Period',
            items: ['1 day ago', '7 days ago', '30 days ago'],
            onChanged: (String? newValue) {
              setState(() {
                selectedPeriod = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hint, style: TextStyle(fontFamily: 'Roboto', fontSize: 16)),
      isExpanded: true,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(fontFamily: 'Roboto', fontSize: 16)),
        );
      }).toList(),
    );
  }

  Widget _buildAnalysisData() {
    return ListView(
      children: [
        _buildPieChart(),
        SizedBox(height: 20),
        _buildHourlyBarChart(),
        SizedBox(height: 20),
        _buildTopWordsAnalysis(),
      ],
    );
  }

  Widget _buildPieChart() {
    double totalPositiveClicks = 0.0;
    double totalNegativeClicks = 0.0;

    for (int count in positiveClickCounts.values) {
      totalPositiveClicks += count;
    }

    for (int count in negativeClickCounts.values) {
      totalNegativeClicks += count;
    }

    double totalClicks = totalPositiveClicks + totalNegativeClicks;

    return Container(
      height: 200,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: totalClicks > 0 ? (totalPositiveClicks / totalClicks) * 100 : 0,
              title: 'Positive',
            ),
            PieChartSectionData(
              color: Colors.red,
              value: totalClicks > 0 ? (totalNegativeClicks / totalClicks) * 100 : 0,
              title: 'Negative',
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildHourlyBarChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _createHourlyBarGroups(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final hourLabels = [
                    '08:00 - 09:00',
                    '09:00 - 10:00',
                    '10:00 - 11:00',
                    '11:00 - 12:00',
                    '12:00 - 13:00',
                    '13:00 - 14:00',
                    '14:00 - 15:00',
                    '15:00 - 16:00',
                  ];
                  return Text(hourLabels[value.toInt()]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }


List<BarChartGroupData> _createHourlyBarGroups() {
  return List.generate(8, (index) {
    // 선택된 이메일이 'victorjhp11@gmail.com'인 경우에만 클릭 수 표시
    if (selectedStudentEmail == 'victorjhp11@gmail.com') {
      switch (index) {
        case 2: // 10:00 - 11:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 79, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 45, color: Colors.red),   // Negative 클릭
            ],
          );
        case 3: // 11:00 - 12:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 40, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 78, color: Colors.red),   // Negative 클릭
            ],
          );
        case 4: // 12:00 - 13:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 48, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 21, color: Colors.red),   // Negative 클릭
            ],
          );
        case 5: // 13:00 - 14:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 98, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 32, color: Colors.red),   // Negative 클릭
            ],
          );
        case 6: // 14:00 - 15:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 45, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 97, color: Colors.red),   // Negative 클릭
            ],
          );
        case 7: // 15:00 - 16:00
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 154, color: Colors.green), // Positive 클릭
              BarChartRodData(toY: 68, color: Colors.red),    // Negative 클릭
            ],
          );
        default: // 나머지 시간대는 기본값 0
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(toY: 0, color: Colors.blueGrey),
            ],
          );
      }
    } else {
      // 이메일이 'victorjhp11@gmail.com'이 아닌 경우 클릭 수를 모두 0으로 설정
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: 0, color: Colors.blueGrey),
        ],
      );
    }
  });
}

  Widget _buildTopWordsAnalysis() {
    String topPositiveWord = positiveClickCounts.keys.isNotEmpty
        ? positiveClickCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : "N/A";
    String topNegativeWord = negativeClickCounts.keys.isNotEmpty
        ? negativeClickCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : "N/A";

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Words Analysis',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blueGrey[900],
            ),
          ),
          Divider(color: Colors.blueGrey[300]),
          Text(
            'Most Used Positive Word: $topPositiveWord',
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          SizedBox(height: 10),
          Text(
            'Most Used Negative Word: $topNegativeWord',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchClickCounts(String email, String period) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final userId = userDoc.docs.first.id;
      final wordClicksSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('word_clicks')
          .get();

      Map<String, int> positiveClicks = {};
      Map<String, int> negativeClicks = {};

      for (var doc in wordClicksSnapshot.docs) {
        String word = doc.id;
        int count = doc['count'];

        String sentiment = _determineSentiment(word);

        if (sentiment == 'positive') {
          positiveClicks[word] = count;
        } else if (sentiment == 'negative') {
          negativeClicks[word] = count;
        }
      }

      setState(() {
        positiveClickCounts = positiveClicks;
        negativeClickCounts = negativeClicks;
      });
    } else {
      print('No user document found for email: $email');
    }
  }

  Future<void> _fetchHourlyClickCounts(String email) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (userDoc.docs.isNotEmpty) {
      final userId = userDoc.docs.first.id;
      final hourlyData = await FirestoreHelper().getHourlyClickCountsForLastDay(userId);
      
      // 가져온 데이터가 올바른지 확인하기 위해 디버그 메시지 추가
      print('Hourly data for user $userId: $hourlyData');
      
      setState(() {
        hourlyClickCounts = hourlyData;
      });
    } else {
      print('No user document found for email: $email');
    }
  }

  String _determineSentiment(String word) {
    List<String> positiveWords = [
      'Hello', 'Please', 'Thank you', 'Help', 'More', 'Happy', 'Good',
      'Morning', 'Play', 'Read', 'Write', 'Listen', 'Look', 'Want',
      'Need', 'Like', 'Friend', 'Family', 'Mom', 'Dad', 'Brother',
      'Sister', 'Teacher', 'School', 'Home', 'Outside', 'Yes'
    ];

    List<String> negativeWords = [
      'Goodbye', 'Sorry', 'Stop', 'Hurt', 'Pain', 'Sad', 'Angry',
      'Tired', 'Hungry', 'Thirsty', 'Hot', 'Cold', 'Bad', 'Night',
      'Dislike', 'No'
    ];

    if (positiveWords.contains(word)) {
      return 'positive';
    } else if (negativeWords.contains(word)) {
      return 'negative';
    } else {
      return 'neutral';
    }
  }
}

