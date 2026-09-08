import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadii {
  static const Radius control = Radius.circular(12);
  static const Radius card = Radius.circular(16);
  static const Radius sheet = Radius.circular(24);
}

abstract final class AppTypography {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
}
