import 'package:flutter/material.dart';

class QuickStatisticsCard extends StatelessWidget {
  final String title;
  final String value;

  const QuickStatisticsCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(title: Text(title), subtitle: Text(value)));
  }
}
