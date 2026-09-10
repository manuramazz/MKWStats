enum BuildType {
  optimal,
  meta;

  String get value => switch (this) {
    BuildType.optimal => 'optimal',
    BuildType.meta => 'meta',
  };

  static BuildType fromValue(String? value) => switch (value) {
    'meta' => BuildType.meta,
    _ => BuildType.optimal,
  };
}
