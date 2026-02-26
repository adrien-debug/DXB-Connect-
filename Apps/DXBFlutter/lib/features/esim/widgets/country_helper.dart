String flagEmoji(String countryCode) {
  final code = countryCode.toUpperCase();
  if (code.length != 2) return '\u{1F30D}';
  final first = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
  final second = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
  return String.fromCharCodes([first, second]);
}

String flagFromName(String name) {
  final lower = name.toLowerCase();
  const mapping = <String, String>{
    'france': 'FR',
    'usa': 'US',
    'united states': 'US',
    'uk': 'GB',
    'united kingdom': 'GB',
    'japan': 'JP',
    'germany': 'DE',
    'spain': 'ES',
    'italy': 'IT',
    'thailand': 'TH',
    'turkey': 'TR',
    'uae': 'AE',
    'united arab emirates': 'AE',
    'dubai': 'AE',
    'china': 'CN',
    'india': 'IN',
    'australia': 'AU',
    'canada': 'CA',
    'brazil': 'BR',
    'mexico': 'MX',
    'south korea': 'KR',
    'korea': 'KR',
    'singapore': 'SG',
    'malaysia': 'MY',
    'indonesia': 'ID',
    'vietnam': 'VN',
    'philippines': 'PH',
    'egypt': 'EG',
    'south africa': 'ZA',
    'portugal': 'PT',
    'netherlands': 'NL',
    'switzerland': 'CH',
    'austria': 'AT',
    'greece': 'GR',
    'sweden': 'SE',
    'norway': 'NO',
    'denmark': 'DK',
    'finland': 'FI',
    'ireland': 'IE',
    'poland': 'PL',
    'czech': 'CZ',
    'hungary': 'HU',
    'romania': 'RO',
    'croatia': 'HR',
    'global': '',
  };

  for (final entry in mapping.entries) {
    if (lower.contains(entry.key)) {
      return entry.value.isEmpty ? '\u{1F30D}' : flagEmoji(entry.value);
    }
  }
  return '\u{1F30D}';
}

String formatVolume(int? bytes) {
  if (bytes == null || bytes == 0) return '--';
  if (bytes >= 1073741824) {
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }
  if (bytes >= 1048576) {
    return '${(bytes / 1048576).toStringAsFixed(0)} MB';
  }
  return '${(bytes / 1024).toStringAsFixed(0)} KB';
}
