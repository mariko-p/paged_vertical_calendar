import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar_controller.dart';
import 'package:paged_vertical_calendar/vertical_scrollable_calendar.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  final PagedVerticalCalendarController _pagedVerticalCalendarController =
      PagedVerticalCalendarController();

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Paged Vertical Calendar'),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                CupertinoButton(
                  child: Text("Today"),
                  onPressed: () {
                    _pagedVerticalCalendarController.scrollToStart();
                    _pagedVerticalCalendarController.selectDate(DateTime.now());
                  },
                ),
                Expanded(
                  child: VerticalScrollableCalendar(
                    onDayPressed: (date) {
                      // TODO add date selection logic
                    },
                    minDate: DateTime.now(),
                    chosenDate: DateTime(2023, 4, 23),
                    initialDate: DateTime(2023, 3, 23),
                    canSelectInPast: false,
                    backgroundColor: Colors.amber,
                    headerText: "monday 28 mar.  •  20 activities this day",
                    isHeaderHiddenOnFirstMonth: true,
                    pagedVerticalCalendarController:
                        _pagedVerticalCalendarController,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
