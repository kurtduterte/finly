class ReceiptOcrInsights {
  const ReceiptOcrInsights({
    this.merchant,
    this.amountCentavos,
  });

  factory ReceiptOcrInsights.fromText(String? ocrText) {
    final lines = _extractLines(ocrText);
    if (lines.isEmpty) return const ReceiptOcrInsights();
    return ReceiptOcrInsights(
      merchant: _extractMerchant(lines),
      amountCentavos: _extractAmountCentavos(lines),
    );
  }

  final String? merchant;
  final int? amountCentavos;

  static final _amountPattern = RegExp(
    r'(?:₱|PHP|Php|php)?\s*((?:[0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)(?:[.,][0-9]{1,2})?)',
  );
  static final _merchantNoisePattern = RegExp(
    '(official receipt|receipt no|invoice|vat|tin|cashier|qty|quantity|'
    'sub[- ]?total|amount due|balance due|total|change|date|time|thank you|'
    r'payment|terminal|trace|approve|auth|reference|ref\.)',
    caseSensitive: false,
  );
  static final _strongTotalPattern = RegExp(
    r'(grand\s*total|net\s*total|amount\s*due|balance\s*due|total\s*due|amount\s*payable)',
    caseSensitive: false,
  );
  static final _weakTotalPattern = RegExp(r'\btotal\b', caseSensitive: false);
  static final _subtotalPattern = RegExp(
    r'\bsub[- ]?total\b',
    caseSensitive: false,
  );
  static final _negativeAmountPattern = RegExp(
    '(sub[- ]?total|vat|tax|discount|change|cash|tendered|paid|round[- ]?off)',
    caseSensitive: false,
  );
  static final _paymentHintPattern = RegExp(
    '(cash|tendered|paid|change|received)',
    caseSensitive: false,
  );
  static final _idHintPattern = RegExp(
    '(or|o/r|ref|reference|trace|terminal|invoice|tin|txn|transaction|'
    r'auth|approval|receipt|account)\s*[:#-]?\s*$',
    caseSensitive: false,
  );
  static final _dateLikePattern = RegExp(r'\b\d{1,4}[/-]\d{1,2}[/-]\d{1,4}\b');
  static final _timeLikePattern = RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b');
  static final _amountOnlyLinePattern = RegExp(
    r'^(?:₱|PHP|Php|php)?\s*[0-9]+(?:[,.][0-9]+)*\s*$',
  );
  static final _hasLetterPattern = RegExp('[A-Za-z]');
  static final _hasDigitPattern = RegExp(r'\d');

  static List<String> _extractLines(String? ocrText) {
    if (ocrText == null || ocrText.trim().isEmpty) return const <String>[];
    return ocrText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  static String? _extractMerchant(List<String> lines) {
    String? bestLine;
    var bestScore = -1000;
    final limit = lines.length < 12 ? lines.length : 12;
    for (var i = 0; i < limit; i++) {
      final line = lines[i];
      final score = _scoreMerchantLine(line, i);
      if (score > bestScore) {
        bestScore = score;
        bestLine = line;
      }
    }
    return bestScore > 0 ? bestLine : null;
  }

  static int _scoreMerchantLine(String line, int index) {
    if (!_hasLetterPattern.hasMatch(line)) return -100;
    final lower = line.toLowerCase();

    var score = 0;
    if (index < 3) score += 4;
    if (index < 6) score += 2;
    if (_merchantNoisePattern.hasMatch(lower)) score -= 10;
    if (_amountPattern.hasMatch(line)) score -= 6;
    if (_hasDigitPattern.hasMatch(line)) score -= 2;
    if (line.length >= 3 && line.length <= 38) score += 2;
    if (line.length > 48) score -= 2;
    if (line == line.toUpperCase()) score += 1;
    if (line.contains(':')) score -= 1;
    return score;
  }

  static int? _extractAmountCentavos(List<String> lines) {
    final amountFrequency = _buildAmountFrequency(lines);
    int? bestAmountCentavos;
    var bestScore = -1000;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();
      final prevLower = i > 0 ? lines[i - 1].toLowerCase() : '';
      final nextLower = i + 1 < lines.length ? lines[i + 1].toLowerCase() : '';
      final hasStrongTotalInLine = _hasStrongTotalHint(lower);
      final hasWeakTotalInLine =
          !hasStrongTotalInLine && _hasWeakTotalHint(lower);
      final hasStrongTotalBefore = _hasStrongTotalHint(prevLower);
      final hasStrongTotalAfter = _hasStrongTotalHint(nextLower);
      final hasWeakTotalBefore = _hasWeakTotalHint(prevLower);
      final hasWeakTotalAfter = _hasWeakTotalHint(nextLower);
      final hasStrongTotalNearby =
          !hasStrongTotalInLine &&
          (hasStrongTotalBefore || hasStrongTotalAfter);
      final hasWeakTotalNearby =
          !hasStrongTotalInLine &&
          !hasWeakTotalInLine &&
          (hasWeakTotalBefore || hasWeakTotalAfter);
      final hasStrongTotal = hasStrongTotalInLine || hasStrongTotalNearby;
      final hasWeakTotal = hasWeakTotalInLine || hasWeakTotalNearby;
      final hasNegativeAmountHint = _negativeAmountPattern.hasMatch(lower);
      final hasCurrencyHint = line.contains('₱') || lower.contains('php');
      final isAmountOnlyLine = _amountOnlyLinePattern.hasMatch(line.trim());
      final totalLabelMatch = hasStrongTotalInLine
          ? _strongTotalPattern.firstMatch(lower)
          : hasWeakTotalInLine
          ? _weakTotalPattern.firstMatch(lower)
          : null;
      final totalLabelEnd = totalLabelMatch?.end ?? -1;
      final matches = _amountPattern.allMatches(line).toList();
      final hasDecimalInLine = matches.any(
        (match) {
          final raw = match.group(1) ?? '';
          return raw.contains('.') || _looksLikeDecimalComma(raw);
        },
      );

      final looksLikeDate = _dateLikePattern.hasMatch(lower);
      final looksLikeTime = _timeLikePattern.hasMatch(lower);
      if ((looksLikeDate || looksLikeTime) &&
          !hasStrongTotal &&
          !hasWeakTotal &&
          !hasCurrencyHint) {
        continue;
      }

      for (final match in matches) {
        final raw = match.group(1);
        if (raw == null) continue;
        final hasPaymentHint = _hasPaymentHint(line, match.start);
        if (hasPaymentHint && !hasStrongTotal) continue;
        final amount = _tryParseAmount(raw);
        if (amount == null || amount <= 0 || amount > 1000000) continue;

        final hasDecimalSeparator =
            raw.contains('.') || _looksLikeDecimalComma(raw);
        final isBareInteger = !hasDecimalSeparator;
        if (isBareInteger &&
            raw.length >= 6 &&
            !hasStrongTotal &&
            !hasWeakTotal &&
            !hasCurrencyHint) {
          continue;
        }

        final hasIdentifierHint = _hasIdentifierHint(line, match.start);
        var score = 0;
        if (hasStrongTotalInLine) score += 12;
        if (hasStrongTotalBefore) score += 10;
        if (hasStrongTotalAfter) score -= 6;
        if (hasWeakTotalInLine) score += 7;
        if (hasWeakTotalBefore) score += 4;
        if (hasWeakTotalAfter) score -= 2;
        if (hasCurrencyHint) score += 2;
        if (hasNegativeAmountHint) score -= 12;
        if (hasDecimalSeparator) score += 3;
        if (!hasDecimalSeparator && hasDecimalInLine) score -= 4;
        if (isBareInteger && raw.length >= 4) score -= 2;
        if (matches.length > 1 && amount >= 1000) score -= 2;
        if (hasIdentifierHint) score -= 10;
        if (isAmountOnlyLine && amount >= 20) score += 2;
        if (isAmountOnlyLine &&
            amount < 10 &&
            !hasStrongTotalInLine &&
            !hasStrongTotalBefore) {
          score -= 6;
        }
        if (amount < 10 && !hasCurrencyHint && !hasStrongTotalInLine) {
          score -= 4;
        }
        if (totalLabelEnd >= 0) {
          final distance = match.start - totalLabelEnd;
          if (distance >= 0 && distance <= 16) score += 4;
          if (distance < 0) score -= 2;
        }
        if (i >= lines.length ~/ 2) score += 1;

        final centavos = (amount * 100).round();
        final repeatedCount = amountFrequency[centavos] ?? 0;
        if (repeatedCount > 1) {
          score += (repeatedCount - 1) * 2;
        }
        if (score > bestScore ||
            (score == bestScore &&
                (bestAmountCentavos == null ||
                    centavos > bestAmountCentavos))) {
          bestScore = score;
          bestAmountCentavos = centavos;
        }
      }
    }

    if (bestScore < 7) return null;
    return bestAmountCentavos;
  }

  static bool _hasStrongTotalHint(String lowerLine) {
    if (lowerLine.isEmpty) return false;
    return _strongTotalPattern.hasMatch(lowerLine);
  }

  static bool _hasWeakTotalHint(String lowerLine) {
    if (lowerLine.isEmpty) return false;
    return _weakTotalPattern.hasMatch(lowerLine) &&
        !_subtotalPattern.hasMatch(lowerLine);
  }

  static Map<int, int> _buildAmountFrequency(List<String> lines) {
    final counts = <int, int>{};
    for (final line in lines) {
      for (final match in _amountPattern.allMatches(line)) {
        final raw = match.group(1);
        if (raw == null) continue;
        final amount = _tryParseAmount(raw);
        if (amount == null || amount <= 0 || amount > 1000000) continue;
        final centavos = (amount * 100).round();
        counts[centavos] = (counts[centavos] ?? 0) + 1;
      }
    }
    return counts;
  }

  static bool _looksLikeDecimalComma(String raw) {
    return RegExp(r'^\d+,\d{1,2}$').hasMatch(raw);
  }

  static double? _tryParseAmount(String raw) {
    if (_looksLikeDecimalComma(raw)) {
      return double.tryParse(raw.replaceFirst(',', '.'));
    }
    return double.tryParse(raw.replaceAll(',', ''));
  }

  static bool _hasIdentifierHint(String line, int matchStart) {
    if (matchStart <= 0) return false;
    final contextStart = matchStart - 24 < 0 ? 0 : matchStart - 24;
    final context = line.substring(contextStart, matchStart).toLowerCase();
    return _idHintPattern.hasMatch(context.trim());
  }

  static bool _hasPaymentHint(String line, int matchStart) {
    if (matchStart <= 0) return false;
    final contextStart = matchStart - 24 < 0 ? 0 : matchStart - 24;
    final context = line.substring(contextStart, matchStart).toLowerCase();
    return _paymentHintPattern.hasMatch(context.trim());
  }
}
