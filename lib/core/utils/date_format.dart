const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';
String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
String formatMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';
