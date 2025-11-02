import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/work_item.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';
  // For Android emulator use: 'http://10.0.2.2:3000/api'
  // For iOS simulator use: 'http://localhost:3000/api'
  // For physical device use your computer's IP: 'http://192.168.x.x:3000/api'

  // Users
  static Future<User> createUser(String displayName, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/onboard'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'displayName': displayName, 'role': role}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to create user');
    }
  }

  static Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user');
    }
  }

  static Future<void> updateFcmToken(int userId, String fcmToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId/fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update FCM token');
    }
  }

  // Work Items
  static Future<WorkItem> createWorkItem(Map<String, dynamic> workItem) async {
    final response = await http.post(
      Uri.parse('$baseUrl/work-items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(workItem),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return WorkItem.fromJson(data['workItem']);
    } else {
      throw Exception('Failed to create work item');
    }
  }

  static Future<List<WorkItem>> getUserWorkItems(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/work-items/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => WorkItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get work items');
    }
  }

  static Future<WorkItem> getWorkItem(int workItemId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/work-items/$workItemId'),
    );

    if (response.statusCode == 200) {
      return WorkItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get work item');
    }
  }

  static Future<void> deleteWorkItem(int workItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/work-items/$workItemId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete work item');
    }
  }

  static Future<WorkItem> resolveWorkItem(int workItemId, String notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/work-items/$workItemId/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notes': notes}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WorkItem.fromJson(data['workItem']);
    } else {
      throw Exception('Failed to resolve work item');
    }
  }

  // Escalations
  static Future<WorkItem> escalateWorkItem(int workItemId, String notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/escalations/$workItemId/escalate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notes': notes}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WorkItem.fromJson(data['workItem']);
    } else {
      throw Exception('Failed to escalate work item');
    }
  }

  // Standup Updates
  static Future<void> addStandupUpdate(
    int workItemId,
    String updateText,
    String? date,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/standups'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'workItemId': workItemId,
        'updateText': updateText,
        'date': date,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add standup update');
    }
  }
}
