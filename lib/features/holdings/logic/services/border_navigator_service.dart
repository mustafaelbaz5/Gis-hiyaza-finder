import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;

import '../../data/models/parcel.dart';
import 'arabic_normalizer.dart';

/// Mirrors `_serialize_border`: resolves a border's free-text holder name to
/// the best-matching parcel's holding ID via the same fuzzy match used for
/// search, or `null` if nothing scores high enough to be confident.
class BorderNavigatorService {
  const BorderNavigatorService();

  static const int _fuzzyThreshold = 70;

  String? resolve(final String borderText, final List<Parcel> parcels) {
    final String trimmed = borderText.trim();
    if (trimmed.isEmpty) return null;

    final String normalizedQuery = ArabicNormalizer.normalize(trimmed);

    String? bestHoldingId;
    int bestScore = -1;
    for (final Parcel parcel in parcels) {
      final String? holderName = parcel.holderName;
      if (holderName == null || holderName.isEmpty) continue;
      final String normalizedName = ArabicNormalizer.normalize(holderName);
      final int score = fuzzy.weightedRatio(normalizedQuery, normalizedName);
      if (score > bestScore) {
        bestScore = score;
        bestHoldingId = parcel.holdingId;
      }
    }

    if (bestHoldingId == null || bestScore < _fuzzyThreshold) return null;
    return bestHoldingId;
  }
}
