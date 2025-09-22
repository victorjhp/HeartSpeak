import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 Future<void> logButtonClick(String userId, String buttonId) async {
  try {
    await _db.collection('users').doc(userId).collection('clicks').add({
      'buttonId': buttonId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Logged click for user $userId on button $buttonId"); // 디버깅 로그 추가
  } catch (e) {
    print("Error logging button click: $e");
  }
}

Future<List<Map<String, dynamic>>> getButtonClicks(String userId) async {
  try {
    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('clicks')
        .orderBy('timestamp')
        .get();

    List<Map<String, dynamic>> allClicks = snapshot.docs.map((doc) {
      return {
        'buttonId': doc['buttonId'],
        'timestamp': (doc['timestamp'] as Timestamp).toDate().toString(),
      };
    }).toList();

    print("Fetched clicks for user $userId: $allClicks"); 

    return allClicks;
  } catch (e) {
    print("Error fetching button clicks: $e");
    return [];
  }
}
  Future<void> createUserDocument(User user) async {
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getButtonClickData(String userId) async {
  try {
    List<Map<String, dynamic>> buttonClicks = await getButtonClicks(userId);

    Map<String, int> buttonClickCounts = {};
    for (var click in buttonClicks) {
      String buttonId = click['buttonId'];
      if (buttonClickCounts.containsKey(buttonId)) {
        buttonClickCounts[buttonId] = buttonClickCounts[buttonId]! + 1;
      } else {
        buttonClickCounts[buttonId] = 1;
      }
    }

    print("Grouped button click data for user $userId: $buttonClickCounts"); 

    return buttonClickCounts.entries.map((entry) => {
      'buttonId': entry.key,
      'count': entry.value,
    }).toList();
  } catch (e) {
    print("Error getting button click data: $e");
    return [];
  }
}

  Future<int> getButtonClickCount(String userId, String buttonId) async {
    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('clicks')
        .where('buttonId', isEqualTo: buttonId)
        .get();
    return snapshot.size;
  }

Future<Map<String, Map<String, int>>> getHourlyClickCountsForPeriod(
    String userId, Duration period) async {
  try {
    Map<String, Map<String, int>> hourlyCounts = {
      '08:00 - 09:00': {},
      '09:00 - 10:00': {},
      '10:00 - 11:00': {},
      '11:00 - 12:00': {},
      '12:00 - 13:00': {},
      '13:00 - 14:00': {},
      '14:00 - 15:00': {},
      '15:00 - 16:00': {},
    };

    DateTime periodStart = DateTime.now().subtract(period);

    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('clicks')
        .where('timestamp', isGreaterThanOrEqualTo: periodStart)
        .orderBy('timestamp')
        .get();

    for (var doc in snapshot.docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      String buttonId = doc['buttonId'];
      String hourRange = _getHourRange(timestamp);

      if (hourlyCounts[hourRange]!.containsKey(buttonId)) {
        hourlyCounts[hourRange]![buttonId] =
            hourlyCounts[hourRange]![buttonId]! + 1;
      } else {
        hourlyCounts[hourRange]![buttonId] = 1;
      }
    }

    print("Hourly click counts for user $userId: $hourlyCounts"); // 디버깅 로그 추가

    return hourlyCounts;
  } catch (e) {
    print("Error fetching hourly click counts: $e");
    return {};
  }
}
 Future<Map<String, Map<String, int>>> getDailyClickCountsForPeriod(
    String userId, Duration period) async {
  try {
    Map<String, Map<String, int>> dailyCounts = {
      'Monday': {},
      'Tuesday': {},
      'Wednesday': {},
      'Thursday': {},
      'Friday': {},
      'Saturday': {},
      'Sunday': {},
    };

    DateTime periodStart = DateTime.now().subtract(period);

    QuerySnapshot snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('clicks')
        .where('timestamp', isGreaterThanOrEqualTo: periodStart)
        .orderBy('timestamp')
        .get();

    for (var doc in snapshot.docs) {
      DateTime timestamp = (doc['timestamp'] as Timestamp).toDate();
      String buttonId = doc['buttonId'];
      String dayOfWeek = _getDayOfWeek(timestamp);

      if (dailyCounts[dayOfWeek]!.containsKey(buttonId)) {
        dailyCounts[dayOfWeek]![buttonId] =
            dailyCounts[dayOfWeek]![buttonId]! + 1;
      } else {
        dailyCounts[dayOfWeek]![buttonId] = 1;
      }
    }

    print("Daily click counts for user $userId: $dailyCounts"); // 디버깅 로그 추가

    return dailyCounts;
  } catch (e) {
    print("Error fetching daily click counts: $e");
    return {};
  }
}
  Future<Map<String, Map<String, int>>> getHourlyClickCountsForLastDay(
      String userId) async {
    return await getHourlyClickCountsForPeriod(userId, Duration(hours: 24));
  }

  String _getHourRange(DateTime timestamp) {
    int hour = timestamp.hour;
    if (hour >= 8 && hour < 9) return '08:00 - 09:00';
    if (hour >= 9 && hour < 10) return '09:00 - 10:00';
    if (hour >= 10 && hour < 11) return '10:00 - 11:00';
    if (hour >= 11 && hour < 12) return '11:00 - 12:00';
    if (hour >= 12 && hour < 13) return '12:00 - 13:00';
    if (hour >= 13 && hour < 14) return '13:00 - 14:00';
    if (hour >= 14 && hour < 15) return '14:00 - 15:00';
    if (hour >= 15 && hour < 16) return '15:00 - 16:00';
    if (hour >= 16 && hour < 17) return '16:00 - 17:00';
    return 'Unknown';
  }

  String _getDayOfWeek(DateTime timestamp) {
    switch (timestamp.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }
}