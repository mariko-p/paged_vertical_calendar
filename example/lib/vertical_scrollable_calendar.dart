import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/styles.dart';

class VerticalScrollableCalendar extends StatefulWidget {
  final ValueChanged<DateTime> onDayPressed;

  VerticalScrollableCalendar({required this.onDayPressed});

  @override
  _VerticalScrollableCalendarState createState() =>
      _VerticalScrollableCalendarState();
}

class _VerticalScrollableCalendarState
    extends State<VerticalScrollableCalendar> {
  DateTime? chosenDate;

  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      minDate: DateTime.now(),
      initialDate: DateTime.now(),
      monthBuilder: monthBuilder,
      dayBuilder: dayBuilder,
      onDayPressed: (date) {
        setState(() {
          chosenDate = date;
        });
        widget.onDayPressed(date);
      },
    );
  }

  Widget monthBuilder(
    BuildContext context,
    int month,
    int year,
    bool isPinned,
    double stuckAmount,
  ) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 5,
              right: 5,
            ),
            child: monthTitleText(year, month, isPinned),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 15,
              // left: 39,
            ),
            child: dayNames(),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  Widget monthTitleText(int year, int month, bool isPinned) {
    return Text(
      DateFormat('MMM. yyyy').format(DateTime(year, month)),
      style: isPinned ? pinnedMonthTitle : monthTitle,
    );
  }

  Widget dayNames() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: SizedBox()),
        weekText('M'),
        weekText('T'),
        weekText('W'),
        weekText('T'),
        weekText('F'),
        weekText('S'),
        weekText('S'),
      ],
    );
  }

  Widget dayBuilder(BuildContext context, DateTime date) {
    if (isSelectedDate(date)) {
      return selectedDate(date);
    } else {
      return nonSelectedDate(date);
    }
  }

  Widget selectedDate(DateTime date) {
    if (isCurrentDate(date)) {
      return currentDateSelected(date);
    }
    if (date.isBefore(DateTime.now())) {
      return Opacity(
        opacity: 0.5,
        child: selectedNonCurrentDate(date),
      );
    }
    return selectedNonCurrentDate(date);
  }

  Widget nonSelectedDate(DateTime date) {
    if (isCurrentDate(date)) {
      return currentDate(date, dayNumberCurrentDate, primaryColor);
    }

    if (DateTime.now().isAfter(date)) {
      return inactiveDate(date);
    }

    return defaultDate(date);
  }

  bool isCurrentDate(DateTime date) {
    return DateTime.now().year == date.year &&
        DateTime.now().month == date.month &&
        DateTime.now().day == date.day;
  }

  bool isSelectedDate(DateTime date) {
    return chosenDate != null &&
        chosenDate!.year == date.year &&
        chosenDate!.month == date.month &&
        chosenDate!.day == date.day;
  }

  Widget currentDateSelected(DateTime date) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: new BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: currentDate(
        date,
        dayNumberSelectedDate,
        Colors.white,
      ),
    );
  }

  Widget currentDate(DateTime date, TextStyle style, Color color) {
    return Column(
      children: [
        Spacer(),
        Text(
          DateFormat('d').format(date),
          style: style,
        ),
        Expanded(
          child: Container(
            width: 2.0,
            height: 2.0,
            decoration: new BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget selectedNonCurrentDate(DateTime date) {
    return Container(
      width: 32.0,
      height: 32.0,
      decoration: new BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          DateFormat('d').format(date),
          style: dayNumberSelectedDate,
        ),
      ),
    );
  }

  Widget inactiveDate(DateTime date) {
    return baseDate(date, dayNumberInactive);
  }

  Widget defaultDate(DateTime date) {
    return baseDate(date, dayNumber);
  }

  Widget baseDate(DateTime date, TextStyle style) {
    return Center(
      child: Text(
        DateFormat('d').format(date),
        style: style,
      ),
    );
  }

  Widget weekText(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: dayName,
        ),
      ),
    );
  }
}
