/// Tolerant numeric parsing for values that come from the network.
///
/// Values such as a call duration or a chat timestamp arrive as strings from
/// the server and cannot be trusted to be numeric - a backend change, a legacy
/// row, or a message written by another client can all produce a non-numeric
/// value. These parse inside widget builders, so a raw `int.parse` there throws
/// during `build` and takes down the whole screen.
library;

/// Parses an int, or returns [fallback] when [value] is null or non-numeric.
int safeInt(Object? value, {int fallback = 0}) =>
    safeIntOrNull(value) ?? fallback;

/// Parses an int, or null when [value] is null or non-numeric.
///
/// Use this instead of [safeInt] when a missing value should be rendered
/// differently rather than as zero - showing "01 Jan 1970" for an unparseable
/// timestamp is worse than showing nothing.
int? safeIntOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
