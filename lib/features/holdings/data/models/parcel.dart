/// One row of the merged holdings workbook (`البيانات المجمعة` sheet).
/// A holding ID can legitimately repeat across several parcels — this
/// class represents a single parcel row, not a deduplicated holding.
class Parcel {
  const Parcel({
    required this.holdingId,
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
}
