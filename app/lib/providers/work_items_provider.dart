import 'package:flutter/material.dart';
import '../models/work_item.dart';
import '../services/api_service.dart';

class WorkItemsProvider with ChangeNotifier {
  List<WorkItem> _workItems = [];
  bool _isLoading = false;
  String? _error;

  List<WorkItem> get workItems => _workItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<WorkItem> get activeItems =>
      _workItems.where((item) => item.currentStage != 'resolved').toList();

  List<WorkItem> get resolvedItems =>
      _workItems.where((item) => item.currentStage == 'resolved').toList();

  List<WorkItem> getItemsByStage(String stage) =>
      _workItems.where((item) => item.currentStage == stage).toList();

  Future<void> loadWorkItems(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workItems = await ApiService.getUserWorkItems(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load work items: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createWorkItem(Map<String, dynamic> workItem) async {
    try {
      await ApiService.createWorkItem(workItem);
      // Reload work items after creating
      await loadWorkItems(workItem['userId']);
    } catch (e) {
      throw Exception('Failed to create work item: $e');
    }
  }

  Future<WorkItem> getWorkItem(int workItemId) async {
    try {
      return await ApiService.getWorkItem(workItemId);
    } catch (e) {
      throw Exception('Failed to get work item: $e');
    }
  }

  Future<void> escalateWorkItem(int workItemId, int userId, String notes) async {
    try {
      await ApiService.escalateWorkItem(workItemId, notes);
      await loadWorkItems(userId);
    } catch (e) {
      throw Exception('Failed to escalate work item: $e');
    }
  }

  Future<void> resolveWorkItem(int workItemId, int userId, String notes) async {
    try {
      await ApiService.resolveWorkItem(workItemId, notes);
      await loadWorkItems(userId);
    } catch (e) {
      throw Exception('Failed to resolve work item: $e');
    }
  }

  Future<void> deleteWorkItem(int workItemId, int userId) async {
    try {
      await ApiService.deleteWorkItem(workItemId);
      await loadWorkItems(userId);
    } catch (e) {
      throw Exception('Failed to delete work item: $e');
    }
  }

  Future<void> addStandupUpdate(
    int workItemId,
    String updateText,
    String? date,
  ) async {
    try {
      await ApiService.addStandupUpdate(workItemId, updateText, date);
    } catch (e) {
      throw Exception('Failed to add standup update: $e');
    }
  }
}
