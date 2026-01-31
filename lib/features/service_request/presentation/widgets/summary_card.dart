import 'package:flutter/material.dart';

/// Summary card widget for displaying statistics
class SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 800;
    
    // Responsive sizing
    final iconSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final valueSize = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);
    final titleSize = isSmallScreen ? 9.0 : (isMediumScreen ? 11.0 : 13.0);
    final cardPadding = isSmallScreen ? 6.0 : (isMediumScreen ? 10.0 : 12.0);
    
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: color),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 1 : 2),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
