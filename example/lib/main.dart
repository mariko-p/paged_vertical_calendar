import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar_example/vertical_scrollable_calendar.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
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
            child: VerticalScrollableCalendar(
              onDayPressed: (date) {
                // TODO add date selection logic
              },
            ),
          ),
        ),
      );
}
