import 'package:daily_habit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarHeaderWidget extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarHeaderWidget({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<CalendarHeaderWidget> createState() => _CalendarHeaderWidgetState();
}

class _CalendarHeaderWidgetState extends State<CalendarHeaderWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(widget.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          widget.onDaySelected(selectedDay);
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          todayTextStyle: const TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(
            color: AppTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          titleTextStyle: AppTheme.textTheme.titleLarge!,
        ),
      ),
    );
  }
}
