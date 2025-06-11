import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../models/activity.dart'; // pastikan import ini ada

class ActivityProvider extends ChangeNotifier {
  final ActivityService activityService;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructor dengan default ActivityService jika tidak diberikan
  ActivityProvider({ActivityService? activityService})
    : activityService = activityService ?? ActivityService();

  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await activityService.fetchActivities();
      _activities = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
