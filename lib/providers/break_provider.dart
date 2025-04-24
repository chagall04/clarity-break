// lib/providers/break_provider.dart
import 'package:flutter/material.dart';
import '../services/break_service.dart';
import '../models/break_details.dart';

// Manages the application's break state using ChangeNotifier
class BreakProvider with ChangeNotifier {
  final BreakService _breakService = BreakService(); // Service for storage
  BreakDetails _currentBreak = BreakDetails.none; // Initial state

  // Getter for the current break details
  BreakDetails get currentBreak => _currentBreak;

  // Flag to indicate if state is currently being loaded
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Constructor: Load initial state when the provider is created
  BreakProvider() {
    loadBreakDetails();
  }

  // Load the current break details from storage
  Future<void> loadBreakDetails() async {
    _isLoading = true;
    notifyListeners(); // Notify UI that loading has started

    _currentBreak = await _breakService.getCurrentBreakDetails();

    _isLoading = false;
    notifyListeners(); // Notify UI that loading is complete and state is updated
  }

  // Start a new break
  Future<void> startNewBreak(String userWhy) async {
    if (_currentBreak.isActive) return; // Prevent starting if already active

    await _breakService.startBreak(userWhy);
    await loadBreakDetails(); // Reload state from storage to reflect changes
    // No need to call notifyListeners here as loadBreakDetails does it
  }

  // End the current break
  Future<void> endCurrentBreak() async {
    if (!_currentBreak.isActive) return; // Can't end if not active

    await _breakService.endBreak();
    await loadBreakDetails(); // Reload state to reflect inactive status
  }
}