import 'package:intl/intl.dart' as intl;
String formatDateTime(Object dateTime) {
  var dt =
  DateTime.fromMillisecondsSinceEpoch(int.parse(dateTime.toString()));
  var d24 = intl.DateFormat('HH:mm, dd/MM/yyyy').format(dt);
  return d24.toString();
}