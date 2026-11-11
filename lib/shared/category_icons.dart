import 'package:flutter/material.dart';

/// One outlined icon per known category, for places that still want an icon
/// (badges, task details). Task rows use the category's screentone instead.
IconData categoryIconFor(String category) {
  return switch (category.trim().toLowerCase()) {
    'anime' => Icons.live_tv_outlined,
    'manga' => Icons.menu_book_outlined,
    'gaming' => Icons.sports_esports_outlined,
    'study' || 'education' => Icons.school_outlined,
    'work' || 'meeting' => Icons.work_outline,
    'personal' => Icons.person_outline,
    'health' || 'fitness' => Icons.favorite_border,
    'shopping' => Icons.shopping_bag_outlined,
    'entertainment' => Icons.movie_outlined,
    'travel' => Icons.flight_outlined,
    'social' => Icons.groups_outlined,
    'finance' => Icons.account_balance_wallet_outlined,
    'food' || 'cooking' => Icons.restaurant_outlined,
    'home' => Icons.home_outlined,
    _ => Icons.label_outline,
  };
}
