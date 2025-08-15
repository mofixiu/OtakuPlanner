import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:provider/provider.dart';

class Categories {
  // This is now deprecated - use CategoryProvider instead
  static final List<String> categories = ["All", "Work", "Personal", "Other"];
  
  // Helper method to get categories from provider
  static List<String> getCategories(BuildContext context) {
    return Provider.of<CategoryProvider>(context, listen: false).categories;
  }
  
  // Helper method to get categories for dropdowns (without "All")
  static List<String> getCategoriesForDropdown(BuildContext context) {
    return Provider.of<CategoryProvider>(context, listen: false).categoriesForDropdown;
  }
}