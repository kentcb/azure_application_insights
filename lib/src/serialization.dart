import 'dart:math';

// Formats a [Duration] as `[d'.']hh':'mm':'ss['.'ffffff]`, which closely matches the format being provided from the .NET back-end.
String? formatDurationForDotNet(Duration? duration) {
  void writePadded(
    StringBuffer stringBuffer,
    int n, {
    int padding = 2,
  }) {
    if (n == 0) {
      for (var i = 0; i < padding; ++i) {
        stringBuffer.write('0');
      }

      return;
    }

    var nWithPadding = n;

    while (nWithPadding < pow(10, padding - 1)) {
      stringBuffer.write('0');
      nWithPadding *= 10;
    }

    stringBuffer.write(n);
  }

  if (duration == null) {
    return null;
  }

  final result = StringBuffer();
  final days = duration.inDays;

  if (days > 0) {
    result..write(days)..write('.');
  }

  writePadded(result, duration.inHours.remainder(24));
  result.write(':');
  writePadded(result, duration.inMinutes.remainder(60));
  result.write(':');
  writePadded(result, duration.inSeconds.remainder(60));

  // There are 1,000,000 microseconds in a second.
  final surplusMicroseconds = duration.inMicroseconds.remainder(1000000);

  if (surplusMicroseconds > 0) {
    result.write('.');
    writePadded(result, surplusMicroseconds, padding: 6);
  }

  return result.toString();
}
