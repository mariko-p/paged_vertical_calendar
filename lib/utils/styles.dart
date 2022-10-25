import 'package:flutter/material.dart';

const primaryColor = Color(0xff7C4DFF);

const pinnedMonthTitle = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 14,
  height: 1.5,
  fontWeight: FontWeight.w500,
  color: Colors.black,
);

const monthTitle = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 14,
  height: 1.5,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);

var weekOfYear = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Color.alphaBlend(
    Color(0xd48f8f8f),
    Color(0xff2979FF),
  ),
);

var dayName = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  height: 2,
  fontWeight: FontWeight.w400,
  color: Color.alphaBlend(
    Color(0xd48f8f8f),
    Color(0xff2979FF),
  ),
);

var dayNumberInactive = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color.alphaBlend(
    Color(0x7DFFFFFF),
    Color.alphaBlend(
      Color(0xd48f8f8f),
      Color(0xff2979FF),
    ),
  ),
);

var dayNumberCurrentDate = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color.alphaBlend(
    Color(0x33000000),
    primaryColor,
  ),
);

var dayNumberSelectedDate = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Colors.white,
);

const dayNumber = TextStyle(
  fontFamily: 'Rubik',
  fontSize: 12,
  fontWeight: FontWeight.w300,
  color: Colors.black,
);
