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
  int? month;
  int? year;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: PagedVerticalCalendar(
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
          ),
        ),
        Align(
          alignment: AlignmentDirectional(1, -1),
          child: Container(
            height: 62,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                this.year != null && this.month != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: monthTitleText(this.year!, this.month!, true),
                      )
                    : SizedBox(),
                dayNames(),
                Divider(
                  height: 1,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget monthBuilder(
    BuildContext context,
    int month,
    int year,
    bool isPinned,
    double stuckAmount,
  ) {
    if (isPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (this.month != month) {
          print("isPinned $month $isPinned $stuckAmount");
        }
        if (stuckAmount != 0.0) {
          setState(() {
            this.month = month;
            this.year = year;
          });
        }
      });
    }
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
              bottom: 8,
            ),
            child: monthTitleText(year, month, isPinned),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  Widget monthTitleText(int year, int month, bool isPinned) {
    return Container(
      height: 21,
      child: Text(
        DateFormat('MMM. yyyy').format(DateTime(year, month)),
        style: isPinned ? pinnedMonthTitle : monthTitle,
      ),
    );
  }

  Widget dayNames() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 39,
            child: SizedBox(),
          ),
          weekText('M'),
          Expanded(child: SizedBox()),
          weekText('T'),
          Expanded(child: SizedBox()),
          weekText('W'),
          Expanded(child: SizedBox()),
          weekText('T'),
          Expanded(child: SizedBox()),
          weekText('F'),
          Expanded(child: SizedBox()),
          weekText('S'),
          Expanded(child: SizedBox()),
          weekText('S'),
          Container(
            width: 15,
            child: SizedBox(),
          ),
        ],
      ),
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
    return Container(
      width: 32,
      height: 24,
      child: Center(
        child: Text(
          text,
          style: dayName,
        ),
      ),
    );
  }
}
