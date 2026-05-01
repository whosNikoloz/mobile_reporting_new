enum BusinessType {
  retail(0),
  cafe(1);

  final int value;
  const BusinessType(this.value);

  static BusinessType? fromString(String? type) {
    if (type == null) return null;
    if (type.toLowerCase() == 'retail') return BusinessType.retail;
    if (type.toLowerCase() == 'cafe') return BusinessType.cafe;
    return null;
  }
}
