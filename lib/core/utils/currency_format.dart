String formatPeso(int centavos) {
  final amount = centavos / 100;
  final negative = amount < 0;
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts[0];
  final dec = parts[1];
  final buf = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
    buf.write(whole[i]);
  }
  return '${negative ? '-' : ''}₱$buf.$dec';
}
