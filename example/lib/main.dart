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
                Row(
                  children: [
                    CupertinoButton(
                      child: Text("Today"),
                      onPressed: () {
                        _pagedVerticalCalendarController
                            .scrollToDateAndSelect(DateTime.now());
                      },
                    ),
                    CupertinoButton(
                      child: Text("2020/03/25"),
                      onPressed: () {
                        _pagedVerticalCalendarController
                            .scrollToDateAndSelect(DateTime(2020, 3, 25));
                      },
                    ),
                    CupertinoButton(
                      child: Text("2030/03/25"),
                      onPressed: () {
                        _pagedVerticalCalendarController
                            .scrollToDateAndSelect(DateTime(2030, 3, 25));
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: VerticalScrollableCalendar(
                    onDayPressed: (date) {
                      // TODO add date selection logic
                    },
                    minDate: DateTime.now(),
                    chosenDate: DateTime(2023, 4, 23),
                    initialDate: DateTime(2023, 3, 23),
                    canSelectInPast: true,
                    backgroundColor: Colors.amber,
                    headerText: "monday 28 mar.  •  20 activities this day",
                    isHeaderHiddenOnFirstMonth: false,
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
