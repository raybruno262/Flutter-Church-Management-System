enum LevelType { HEADQUARTER, REGION, PARISH, CHAPEL, CELL }

extension LevelTypeExtension on LevelType {
  String get name => toString().split('.').last;

  static LevelType fromString(String value) {
    return LevelType.values.firstWhere(
      (type) => type.name.toUpperCase() == value.toUpperCase(),
      orElse: () => LevelType.HEADQUARTER,
    );
  }
}
