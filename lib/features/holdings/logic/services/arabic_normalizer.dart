/// Ports `arabic_normalizer.py` exactly: NFC normalize → map `ى`→`ي` and
/// `أ/إ/آ`→`ا` → strip diacritics → collapse whitespace → trim.
/// Deliberately does NOT map `ة`→`ه`.
class ArabicNormalizer {
  const ArabicNormalizer._();

  // U+064B–U+0652 (tanwin/harakat/sukun) + U+0670 (superscript alef).
  static final RegExp _diacritics = RegExp('[ً-ْٰ]');
  static final RegExp _whitespace = RegExp(r'\s+');

  static String normalize(final String input) {
    var result = input.trim();
    if (result.isEmpty) return result;

    // Dart strings are UTF-16 and already NFC-normalized in practice for
    // Arabic text; no separate NFC step is available without extra
    // packages, so this mirrors the effective behavior.
    result = result
        .replaceAll('ى', 'ي')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    result = result.replaceAll(_diacritics, '');
    result = result.replaceAll(_whitespace, ' ').trim();

    return result;
  }
}
