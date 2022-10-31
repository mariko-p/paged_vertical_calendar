import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/rendering.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:paged_vertical_calendar/utils/date_models.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';
import 'package:paged_vertical_calendar/utils/styles.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

/// enum indicating the pagination enpoint direction
enum PaginationDirection {
  up,
  down,
}

/// a minimalistic paginated calendar widget providing infinite customisation
/// options and usefull paginated callbacks. all paremeters are optional.
///
/// ```
/// PagedVerticalCalendar(
///       startDate: DateTime(2021, 1, 1),
///       endDate: DateTime(2021, 12, 31),
///       onDayPressed: (day) {
///            print('Date selected: $day');
///          },
///          onMonthLoaded: (year, month) {
///            print('month loaded: $month-$year');
///          },
///          onPaginationCompleted: () {
///            print('end reached');
///          },
///        ),
/// ```
class PagedVerticalCalendar extends StatefulWidget {
  PagedVerticalCalendar({
    this.minDate,
    this.maxDate,
    DateTime? initialDate,
    this.monthBuilder,
    this.dayBuilder,
    this.addAutomaticKeepAlives = false,
    this.onDayPressed,
    this.onMonthLoaded,
    this.onPaginationCompleted,
    this.invisibleMonthsThreshold = 1,
    this.physics,
    this.scrollController,
    this.listPadding = EdgeInsets.zero,
    this.startWeekWithSunday = false,
  }) : this.initialDate = initialDate ?? DateTime.now().removeTime();

  /// the [DateTime] to start the calendar from, if no [startDate] is provided
  /// `DateTime.now()` will be used
  final DateTime? minDate;

  /// optional [DateTime] to end the calendar pagination, of no [endDate] is
  /// provided the calendar can paginate indefinitely
  final DateTime? maxDate;

  /// the initial date displayed by the calendar.
  /// if inititial date is nulll, the start date will be used
  final DateTime initialDate;

  /// a Builder used for month header generation. a default [MonthBuilder] is
  /// used when no custom [MonthBuilder] is provided.
  /// * [context]
  /// * [int] year: 2021
  /// * [int] month: 1-12
  final MonthBuilder? monthBuilder;

  /// a Builder used for day generation. a default [DayBuilder] is
  /// used when no custom [DayBuilder] is provided.
  /// * [context]
  /// * [DateTime] date
  final DayBuilder? dayBuilder;

  /// if the calendar should stay cached when the widget is no longer loaded.
  /// this can be used for maintaining the last state. defaults to `false`
  final bool addAutomaticKeepAlives;

  /// callback that provides the [DateTime] of the day that's been interacted
  /// with
  final ValueChanged<DateTime>? onDayPressed;

  /// callback when a new paginated month is loaded.
  final OnMonthLoaded? onMonthLoaded;

  /// called when the calendar pagination is completed. if no [minDate] or [maxDate] is
  /// provided this method is never called for that direction
  final ValueChanged<PaginationDirection>? onPaginationCompleted;

  /// how many months should be loaded outside of the view. defaults to `1`
  final int invisibleMonthsThreshold;

  /// list padding, defaults to `EdgeInsets.zero`
  final EdgeInsetsGeometry listPadding;

  /// scroll physics, defaults to matching platform conventions
  final ScrollPhysics? physics;

  /// scroll controller for making programmable scroll interactions
  final ScrollController? scrollController;

  /// Select start day of the week to be Sunday
  final bool startWeekWithSunday;

  @override
  _PagedVerticalCalendarState createState() => _PagedVerticalCalendarState();
}

class _PagedVerticalCalendarState extends State<PagedVerticalCalendar> {
  late PagingController<int, Month> _pagingReplyUpController;
  late PagingController<int, Month> _pagingReplyDownController;

  final Key downListKey = UniqueKey();
  late bool hideUp;

  @override
  void initState() {
    super.initState();

    if (widget.minDate != null &&
        widget.initialDate.isBefore(widget.minDate!)) {
      throw ArgumentError("initialDate cannot be before minDate");
    }

    if (widget.maxDate != null && widget.initialDate.isAfter(widget.maxDate!)) {
      throw ArgumentError("initialDate cannot be after maxDate");
    }

    hideUp = !(widget.minDate == null ||
        !widget.minDate!.isSameMonth(widget.initialDate));

    _pagingReplyUpController = PagingController<int, Month>(
      firstPageKey: 0,
      invisibleItemsThreshold: widget.invisibleMonthsThreshold,
    );
    _pagingReplyUpController.addPageRequestListener(_fetchUpPage);
    _pagingReplyUpController.addStatusListener(paginationStatusUp);

    _pagingReplyDownController = PagingController<int, Month>(
      firstPageKey: 0,
      invisibleItemsThreshold: widget.invisibleMonthsThreshold,
    );
    _pagingReplyDownController.addPageRequestListener(_fetchDownPage);
    _pagingReplyDownController.addStatusListener(paginationStatusDown);
  }

  @override
  void didUpdateWidget(covariant PagedVerticalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.minDate != oldWidget.minDate) {
      _pagingReplyUpController.refresh();

      hideUp = !(widget.minDate == null ||
          !widget.minDate!.isSameMonth(widget.initialDate));
    }
  }

  void paginationStatusUp(PagingStatus state) {
    if (state == PagingStatus.completed)
      return widget.onPaginationCompleted?.call(PaginationDirection.up);
  }

  void paginationStatusDown(PagingStatus state) {
    if (state == PagingStatus.completed)
      return widget.onPaginationCompleted?.call(PaginationDirection.down);
  }

  /// fetch a new [Month] object based on the [pageKey] which is the Nth month
  /// from the start date
  void _fetchUpPage(int pageKey) async {
    try {
      final month = DateUtils.getMonth(
        DateTime(widget.initialDate.year, widget.initialDate.month - 1, 1),
        widget.minDate,
        pageKey,
        true,
        startWeekWithSunday: widget.startWeekWithSunday,
      );

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onMonthLoaded?.call(month.year, month.month),
      );

      final newItems = [month];
      final isLastPage = widget.minDate != null &&
          widget.minDate!.isSameDayOrAfter(month.weeks.first.firstDay);

      if (isLastPage) {
        return _pagingReplyUpController.appendLastPage(newItems);
      }

      final nextPageKey = pageKey + newItems.length;
      _pagingReplyUpController.appendPage(newItems, nextPageKey);
    } catch (_) {
      _pagingReplyUpController.error;
    }
  }

  void _fetchDownPage(int pageKey) async {
    try {
      final month = DateUtils.getMonth(
        DateTime(widget.initialDate.year, widget.initialDate.month, 1),
        widget.maxDate,
        pageKey,
        false,
        startWeekWithSunday: widget.startWeekWithSunday,
      );

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onMonthLoaded?.call(month.year, month.month),
      );

      final newItems = [month];
      final isLastPage = widget.maxDate != null &&
          widget.maxDate!.isSameDayOrBefore(month.weeks.last.lastDay);

      if (isLastPage) {
        return _pagingReplyDownController.appendLastPage(newItems);
      }

      final nextPageKey = pageKey + newItems.length;
      _pagingReplyDownController.appendPage(newItems, nextPageKey);
    } catch (_) {
      _pagingReplyDownController.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      controller: widget.scrollController,
      physics: widget.physics,
      viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Viewport(
          offset: position,
          center: downListKey,
          slivers: [
            if (!hideUp)
              PagedSliverList(
                pagingController: _pagingReplyUpController,
                builderDelegate: PagedChildBuilderDelegate<Month>(
                  itemBuilder: (BuildContext context, Month month, int index) {
                    return _MonthView(
                      month: month,
                      monthBuilder: widget.monthBuilder,
                      dayBuilder: widget.dayBuilder,
                      onDayPressed: widget.onDayPressed,
                      startWeekWithSunday: widget.startWeekWithSunday,
                    );
                  },
                ),
              ),
            PagedSliverList(
              key: downListKey,
              pagingController: _pagingReplyDownController,
              builderDelegate: PagedChildBuilderDelegate<Month>(
                itemBuilder: (BuildContext context, Month month, int index) {
                  return _MonthView(
                    month: month,
                    monthBuilder: widget.monthBuilder,
                    dayBuilder: widget.dayBuilder,
                    onDayPressed: widget.onDayPressed,
                    startWeekWithSunday: widget.startWeekWithSunday,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pagingReplyUpController.dispose();
    _pagingReplyDownController.dispose();
    super.dispose();
  }
}

class _MonthView extends StatefulWidget {
  _MonthView({
    required this.month,
    this.monthBuilder,
    this.dayBuilder,
    this.onDayPressed,
    required this.startWeekWithSunday,
  });

  final Month month;
  final MonthBuilder? monthBuilder;
  final DayBuilder? dayBuilder;
  final ValueChanged<DateTime>? onDayPressed;
  final bool startWeekWithSunday;

  final rowSpacer = TableRow(
    children: [
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
    ],
  );

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<_MonthView> {
  final rowSpacer = TableRow(
    children: [
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
      SizedBox(
        height: 8,
      ),
    ],
  );

  ScrollController? scrollController = ScrollController(
      // initialScrollOffset: 0.0,
      // keepScrollOffset: true,
      );

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   scrollController!.addListener(_scrollListener);
    // });
  }

  Future<void> _scrollListener() async {
    // if (scrollController!.offset >=
    //         scrollController!.position.maxScrollExtent &&
    //     !scrollController!.position.outOfRange) {
    //   print("scroll ${scrollController!.offset}");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return StickyHeaderBuilder(
      // controller: scrollController,
      overlapHeaders: false,
      content: Padding(
        padding: const EdgeInsets.only(
          top: 15,
        ),
        child: Column(
          children: <Widget>[
            Table(
              columnWidths: {
                0: IntrinsicColumnWidth(),
                1: IntrinsicColumnWidth(),
                2: IntrinsicColumnWidth(),
                4: IntrinsicColumnWidth(),
                6: IntrinsicColumnWidth(),
                8: IntrinsicColumnWidth(),
                10: IntrinsicColumnWidth(),
                12: IntrinsicColumnWidth(),
                14: IntrinsicColumnWidth(),
                15: IntrinsicColumnWidth(),
              },
              children: List<TableRow>.generate(
                // 16,
                widget.month.weeks.length * 2 - 1,
                (int position) {
                  if (position % 2 != 0) {
                    return rowSpacer;
                  } else {
                    return _generateWeekRow(
                      context,
                      widget.month.weeks[position ~/ 2],
                      widget.startWeekWithSunday,
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      builder: (BuildContext context, double stuckAmount) {
        var stuckAmount2 = 1.0 - stuckAmount.clamp(0.0, 1.0);
        return widget.monthBuilder?.call(
              context,
              widget.month.month,
              widget.month.year,
              stuckAmount2 > 0.5,
              stuckAmount,
            ) ??
            _DefaultMonthView(
              month: widget.month.month,
              year: widget.month.year,
            );
      },
    );
  }

  TableRow _generateWeekRow(
    BuildContext context,
    Week week,
    bool startWeekWithSunday,
  ) {
    DateTime firstDay = week.firstDay;

    return TableRow(
      children: List<Widget>.generate(
        16,
        (int position) {
          if (position == 0) {
            return Container(
              height: 32,
              width: 24,
              child: Center(
                child: Text(
                  week.weekOfYear.toString(),
                  style: weekOfYear,
                ),
              ),
            );
          }

          if (position == 1 || position == 15) {
            return Container(
              height: 32,
              width: 15,
              child: SizedBox(),
            );
          }

          if (position % 2 != 0) {
            return Container();
          }

          int dayPosition = position ~/ 2 - 1;

          DateTime day = DateTime(
            week.firstDay.year,
            week.firstDay.month,
            firstDay.day +
                ((dayPosition) -
                    (DateUtils.getWeekDay(firstDay, startWeekWithSunday) - 1)),
          );

          if ((dayPosition + 1) <
                  DateUtils.getWeekDay(week.firstDay, startWeekWithSunday) ||
              (dayPosition + 1) >
                  DateUtils.getWeekDay(week.lastDay, startWeekWithSunday)) {
            return const SizedBox();
          } else {
            return Container(
              height: 32,
              width: 32,
              child: InkWell(
                customBorder: new CircleBorder(),
                onTap: onDayTap(day),
                child: widget.dayBuilder?.call(context, day) ??
                    _DefaultDayView(date: day),
              ),
            );
          }
        },
        growable: false,
      ),
    );
  }

  GestureTapCallback? onDayTap(day) {
    if (widget.onDayPressed == null) {
      return null;
    }

    return () => widget.onDayPressed!(day);
  }
}

class _DefaultMonthView extends StatelessWidget {
  final int month;
  final int year;

  _DefaultMonthView({required this.month, required this.year});

  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        '${months[month - 1]} $year',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}

class _DefaultDayView extends StatelessWidget {
  final DateTime date;

  _DefaultDayView({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        date.day.toString(),
      ),
    );
  }
}

typedef MonthBuilder = Widget Function(
  BuildContext context,
  int month,
  int year,
  bool isPinned,
  double stuckAmount,
);
typedef DayBuilder = Widget Function(BuildContext context, DateTime date);

typedef OnMonthLoaded = void Function(int year, int month);
