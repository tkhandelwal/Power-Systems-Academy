import 'package:flutter/material.dart';

class RecentActivity {
  final String title;
  final String description;
  final String time;
  final IconData iconData;
  final Color iconColor;

  RecentActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.iconData,
    required this.iconColor,
  });
}