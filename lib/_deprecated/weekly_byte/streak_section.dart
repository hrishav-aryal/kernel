import 'package:flutter/material.dart';

class StreakSection extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isStreakActive;

  const StreakSection({
    super.key,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isStreakActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Header with streak count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title and streak number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStreakTitle(),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color:
                            isStreakActive
                                ? Colors.orange[600]
                                : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$currentStreak day${currentStreak != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isStreakActive
                                  ? Colors.orange[600]
                                  : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Best streak badge
              if (longestStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Best: $longestStreak',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekly calendar view
          _buildWeeklyCalendar(context),
        ],
      ),
    );
  }

  Widget _buildWeeklyCalendar(BuildContext context) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              weekDays
                  .map(
                    (day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),

        const SizedBox(height: 12),

        // Activity dots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final dayDate = weekStart.add(Duration(days: index));
            final isToday = _isSameDay(dayDate, today);
            final hasActivity = _hasActivityOnDay(dayDate, today);

            return _buildActivityDot(context, hasActivity, isToday, dayDate);
          }),
        ),
      ],
    );
  }

  Widget _buildActivityDot(
    BuildContext context,
    bool hasActivity,
    bool isToday,
    DateTime date,
  ) {
    Color dotColor;
    Color borderColor;
    double size = 28;

    if (hasActivity) {
      dotColor = Theme.of(context).colorScheme.primary;
      borderColor = Theme.of(context).colorScheme.primary;
    } else if (isToday) {
      dotColor = Colors.transparent;
      borderColor = Colors.orange[600]!;
    } else {
      dotColor = Colors.grey[300]!;
      borderColor = Colors.grey[300]!;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        border:
            isToday && !hasActivity
                ? Border.all(color: borderColor, width: 2)
                : null,
      ),
      child:
          isToday && hasActivity
              ? Icon(Icons.local_fire_department, size: 16, color: Colors.white)
              : null,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasActivityOnDay(DateTime date, DateTime today) {
    final daysDifference = today.difference(date).inDays;

    // Mock data: simulate activity based on current streak
    // In real implementation, this would check actual reading data
    if (daysDifference < 0) return false; // Future dates
    if (daysDifference == 0) return isStreakActive; // Today

    // Past days: show activity if within current streak
    return daysDifference <= currentStreak;
  }

  String _getStreakTitle() {
    if (currentStreak == 0) {
      return 'Start Your Streak';
    } else if (currentStreak == 1) {
      return 'Great Start!';
    } else if (currentStreak < 7) {
      return 'Building Momentum';
    } else if (currentStreak < 30) {
      return 'On Fire!';
    } else {
      return 'Streak Master';
    }
  }
}
