import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:otakuplanner/screens/request.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> _categories = [
    "All", 
    "Work", 
    "Personal", 
    "Study", 
    "Health", 
    "Shopping", 
    "Entertainment"
  ]; // Default categories
  
  List<String> get categories => _categories;
  
  // Get categories without "All" for dropdowns
  List<String> get categoriesForDropdown => _categories.where((cat) => cat != "All").toList();
  
  void addCategory(String category) {
    if (!_categories.contains(category) && category.trim().isNotEmpty) {
      _categories.add(category.trim());
      notifyListeners();
    }
  }
  
  void removeCategory(String category) {
    // Don't allow removing default categories
    List<String> defaultCategories = ["All", "Work", "Personal", "Study", "Health", "Shopping", "Entertainment"];
    if (!defaultCategories.contains(category)) {
      _categories.remove(category);
      notifyListeners();
    }
  }
  
  bool categoryExists(String category) {
    return _categories.contains(category);
  }
  
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  
  // Load categories from database
  Future<void> loadCategoriesFromDatabase(int userId) async {
    try {
      log('Loading categories for user: $userId');
      final response = await getUserCategories(userId);
      
      if (response != null && response['data'] != null) {
        final categoriesData = response['data'] as List;
        log('Retrieved ${categoriesData.length} categories from database');
        
        // Start with default categories
        List<String> loadedCategories = [
          "All", 
          "Work", 
          "Personal", 
          "Study", 
          "Health", 
          "Shopping", 
          "Entertainment"
        ];
        
        // Add user-created categories
        for (final categoryJson in categoriesData) {
          final categoryName = categoryJson['name'] as String;
          if (!loadedCategories.contains(categoryName)) {
            loadedCategories.add(categoryName);
          }
        }
        
        _categories = loadedCategories;
        _isLoaded = true; // Mark as loaded
        notifyListeners();
        log('Categories loaded: $_categories');
      } else {
        log('No categories response or empty data');
        _isLoaded = true; // Still mark as loaded even if no custom categories
        notifyListeners();
      }
    } catch (e) {
      log('Error loading categories from database: $e');
      log('Stack trace: ${StackTrace.current}');
      _isLoaded = true; // Mark as loaded to prevent infinite loading
      notifyListeners();
    }
  }
  
  // Reset categories when user logs out
  void resetCategories() {
    _categories = [
      "All", 
      "Work", 
      "Personal", 
      "Study", 
      "Health", 
      "Shopping", 
      "Entertainment"
    ];
    _isLoaded = false;
    notifyListeners();
  }
  
  // Save new category to database
  Future<bool> saveCategoryToDatabase(String categoryName, int userId) async {
    try {
      // Don't save default categories
      List<String> defaultCategories = ["All", "Work", "Personal", "Study", "Health", "Shopping", "Entertainment"];
      if (defaultCategories.contains(categoryName)) {
        return true;
      }
      
      final response = await saveCategory(categoryName, userId);
      
      if (response != null) {
        log('Category saved to database: $categoryName');
        return true;
      } else {
        log('Failed to save category to database: $categoryName');
        return false;
      }
    } catch (e) {
      log('Error saving category to database: $e');
      return false;
    }
  }
  
  // Add category and save to database
  Future<bool> addAndSaveCategory(String categoryName, int userId) async {
    if (categoryName.trim().isEmpty || categoryExists(categoryName)) {
      return false;
    }
    
    // Add locally first
    addCategory(categoryName);
    
    // Then save to database
    final saved = await saveCategoryToDatabase(categoryName, userId);
    
    if (!saved) {
      // If database save failed, remove from local list
      removeCategory(categoryName);
      return false;
    }
    
    // Force notify listeners again to ensure UI updates
    notifyListeners();
    return true;
  }
  
  void clearCategories() {
    _categories = ["All", "Work", "Personal", "Study", "Health", "Shopping", "Entertainment"];
    notifyListeners();
  }
}