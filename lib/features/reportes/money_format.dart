String formatSolesFromCentavos(int centavos) {
  final sign = centavos < 0 ? '-' : '';
  final absCentavos = centavos.abs();
  final soles = absCentavos ~/ 100;
  final cents = (absCentavos % 100).toString().padLeft(2, '0');
  return '$sign${sign.isEmpty ? '' : ' '}${_formatSoles(soles)}.$cents';
}

String _formatSoles(int soles) {
  final digits = soles.toString();
  final buffer = StringBuffer('S/ ');

  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  return buffer.toString();
}
