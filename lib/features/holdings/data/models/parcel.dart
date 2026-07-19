/// One row of the merged holdings workbook (`البيانات المجمعة` sheet).
/// A holding ID can legitimately repeat across several parcels — this
/// class represents a single parcel row, not a deduplicated holding.
class Parcel {
  const Parcel({
    required this.holdingId,
    this.id = '',
    this.pageNumber,
    this.directorate,
    this.administration,
    this.basinName,
    this.basinCode,
    this.holderName,
    this.nationalId,
    this.borderEast,
    this.borderSouth,
    this.borderWest,
    this.borderNorth,
    this.landNumber,
    this.feddan,
    this.qirat,
    this.sahm,
    this.totalSqm,
  });

  /// Stable identity within a loaded dataset (the parse-order index).
  /// Used to key persistent edits so corrections re-apply on reload.
  final String id;

  final String holdingId; // رقم الحيازة
  final String? pageNumber; // رقم الصفحة بالسجل
  final String? directorate; // المديريه
  final String? administration; // الأداره
  final String? basinName; // اسم الحوض
  final String? basinCode; // كود الحوض
  final String? holderName; // اسم الحائز
  final String? nationalId; // الرقم القومي
  final String? borderEast; // الحد الشرقى
  final String? borderSouth; // الحد القبلى
  final String? borderWest; // الحد الغربى
  final String? borderNorth; // الحد البحرى
  final String? landNumber; // رقم الأرض
  final double? feddan; // فدان
  final double? qirat; // قيراط
  final double? sahm; // سهم
  final double? totalSqm; // إجمالي المساحة (م²)

  /// Only [id] can be overridden here — all other fields are copied. Edited
  /// parcels are built with the full constructor so nullable fields can be
  /// explicitly cleared, which `copyWith` can't express.
  Parcel copyWith({final String? id}) {
    return Parcel(
      id: id ?? this.id,
      holdingId: holdingId,
      pageNumber: pageNumber,
      directorate: directorate,
      administration: administration,
      basinName: basinName,
      basinCode: basinCode,
      holderName: holderName,
      nationalId: nationalId,
      borderEast: borderEast,
      borderSouth: borderSouth,
      borderWest: borderWest,
      borderNorth: borderNorth,
      landNumber: landNumber,
      feddan: feddan,
      qirat: qirat,
      sahm: sahm,
      totalSqm: totalSqm,
    );
  }
}
