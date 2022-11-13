import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar_controller.dart';
import 'package:paged_vertical_calendar/utils/styles.dart';

class VerticalScrollableCalendar extends StatefulWidget {
  final ValueChanged<DateTime?> onDayPressed;
  final DateTime minDate;
  final bool canSelectInPast;
  final Color backgroundColor;
  final bool isHeaderHiddenOnFirstMonth;
  final String? headerText;
  final PagedVerticalCalendarController? pagedVerticalCalendarController;

  VerticalScrollableCalendar({
    required this.onDayPressed,
    required this.minDate,
    required this.canSelectInPast,
    this.backgroundColor = Colors.white,
    this.isHeaderHiddenOnFirstMonth = false,
    this.headerText,
    this.pagedVerticalCalendarController,
  });

  @override
  VerticalScrollableCalendarState createState() =>
      VerticalScrollableCalendarState(minDate: minDate);
}

class VerticalScrollableCalendarState
    extends State<VerticalScrollableCalendar> {
  DateTime? chosenDate;
  DateTime minDate;
  late int month;
  late int year;

  VerticalScrollableCalendarState({required this.minDate}) {
    this.month = minDate.month;
    this.year = minDate.year;
  }

  void pinPreviousMonth(int unpinnedYear, int unpinnedMonth) {
    if (unpinnedYear > year ||
        (year == unpinnedYear && unpinnedMonth > month)) {
      return;
    }

    if (unpinnedYear == minDate.year && unpinnedMonth == minDate.month) {
      return;
    }

    var previousYear = unpinnedYear;
    var previousMonth = unpinnedMonth;
    if (unpinnedMonth == 1) {
      previousMonth = 12;
      previousYear = unpinnedYear - 1;
    } else {
      previousMonth = unpinnedMonth - 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (previousYear > year ||
          (previousYear == year && previousMonth > month)) {
        return;
      }

      setState(() {
        this.year = previousYear;
        this.month = previousMonth;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: widget.isHeaderHiddenOnFirstMonth
                  ? (widget.headerText != null ? 0.0 : 0.0)
                  : (widget.headerText != null ? 40.0 : 20.0),
            ),
            child: PagedVerticalCalendar(
              backgroundColor: widget.backgroundColor,
              scrollController: ScrollController(initialScrollOffset: 0),
              minDate: widget.canSelectInPast == false ? widget.minDate : null,
              initialDate: widget.minDate,
              monthBuilder: monthBuilder,
              firstMonthBuilder: firstMonthBuilder,
              dayBuilder: dayBuilder,
              onDayPressed: (DateTime? date, bool force) {
                if (force == false &&
                    chosenDate != null &&
                    date != null &&
                    chosenDate!.year == date.year &&
                    chosenDate!.month == date.month &&
                    chosenDate!.day == date.day) {
                  setState(() {
                    chosenDate = null;
                    widget.onDayPressed(null);
                  });
                } else {
                  setState(() {
                    chosenDate = date;
                  });
                  widget.onDayPressed(date);
                }
              },
              onMonthPinned: ((year, month) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    this.year = year;
                    this.month = month;
                  });
                });
              }),
              onMonthUnpinned: ((year, month) {
                pinPreviousMonth(year, month);
              }),
              canSelectInPast: widget.canSelectInPast,
              showPreviousWeeksInFirstMonth: widget.canSelectInPast,
              controller: widget.pagedVerticalCalendarController,
            ),
          ),
          Align(
            alignment: AlignmentDirectional(1, -1),
            child: widget.isHeaderHiddenOnFirstMonth &&
                    widget.minDate.year == year &&
                    widget.minDate.month == month
                ? SizedBox.shrink()
                : Container(
                    height: widget.headerText != null ? 83.0 : 62.0,
                    color: widget.backgroundColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: monthTitleText(this.year, this.month, true),
                        ),
                        dayNames(),
                        widget.headerText != null
                            ? Text(
                                widget.headerText!,
                                style: headerInfoText,
                                textAlign: TextAlign.center,
                              )
                            : SizedBox.shrink(),
                        Divider(
                          height: 1,
                        )
                      ],
                    ),
                  ),
          ),
        ],
      ),
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
        if (stuckAmount != 0.0) {
          setState(() {
            this.month = month;
            this.year = year;
          });
        }
      });
    }
    return widget.isHeaderHiddenOnFirstMonth &&
            widget.minDate.year == year &&
            widget.minDate.month == month
        ? SizedBox.shrink()
        : Container(
            color: widget.backgroundColor,
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

  Widget firstMonthBuilder(
    BuildContext context,
    int month,
    int year,
    bool isPinned,
    double stuckAmount,
  ) {
    if (isPinned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (stuckAmount != 0.0) {
          setState(() {
            this.month = month;
            this.year = year;
          });
        }
      });
    }
    return widget.isHeaderHiddenOnFirstMonth &&
            widget.minDate.year == year &&
            widget.minDate.month == month
        ? Container(
            height: widget.headerText != null ? 67.0 : 46.0,
            color: widget.backgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Divider(
                  height: 1,
                ),
                dayNames(),
                widget.headerText != null
                    ? Text(
                        widget.headerText!,
                        style: headerInfoText,
                        textAlign: TextAlign.center,
                      )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          )
        : SizedBox(
            height: 15,
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
    if (date.isBefore(widget.minDate)) {
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

    if (widget.minDate.isAfter(date)) {
      return inactiveDate(date);
    }

    return defaultDate(date);
  }

  bool isCurrentDate(DateTime date) {
    return widget.minDate.year == date.year &&
        widget.minDate.month == date.month &&
        widget.minDate.day == date.day;
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
        widget.backgroundColor,
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
