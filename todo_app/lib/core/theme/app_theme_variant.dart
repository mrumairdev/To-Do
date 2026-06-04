enum AppThemeVariant {
  light,
  dark,
  blueAccent;

  String get storageKey => name;

  String get label => switch (this) {
        light => 'Light',
        dark => 'Dark',
        blueAccent => 'Blue accent',
      };

  static AppThemeVariant fromStorage(String? value) {
    return AppThemeVariant.values.firstWhere(
      (variant) => variant.name == value,
      orElse: () => AppThemeVariant.light,
    );
  }
}
