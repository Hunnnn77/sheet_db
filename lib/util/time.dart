import "package:intl/intl.dart";
import "package:timezone/timezone.dart" as tz;

final class TimeUtil {
  static final DateTime _now = DateTime.now().toUtc();
  static final tz.Location _timezone = tz.getLocation("Asia/Seoul");
  static final DateFormat _format = DateFormat("yyyy-MM-dd_HH:mm:ss");

  tz.TZDateTime get getTime => tz.TZDateTime.from(_now, _timezone);

  String get getFormat => _format.format(getTime);
}
