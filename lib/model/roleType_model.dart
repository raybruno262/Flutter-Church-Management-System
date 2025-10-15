enum RoleType { SuperAdmin, RegionAdmin, ParishAdmin, ChapelAdmin, CellAdmin }

extension RoleTypeExtension on RoleType {
  String get name => toString().split('.').last;

  static RoleType fromString(String value) {
    return RoleType.values.firstWhere(
      (type) => type.name.toUpperCase() == value.toUpperCase(),
      orElse: () => RoleType.CellAdmin,
    );
  }
}
