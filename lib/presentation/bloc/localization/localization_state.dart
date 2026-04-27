part of 'localization_bloc.dart';

class LocalizationState extends Equatable {
  const LocalizationState({
    this.locale = const Locale('en', 'US'),
    this.currentLanguage,
    this.isLoading = false,
  });
  final Locale locale;
  final AppLanguage? currentLanguage;
  final bool isLoading;

  LocalizationState copyWith({
    Locale? locale,
    AppLanguage? currentLanguage,
    bool? isLoading,
  }) =>
      LocalizationState(
        locale: locale ?? this.locale,
        currentLanguage: currentLanguage ?? this.currentLanguage,
        isLoading: isLoading ?? this.isLoading,
      );

  bool get isLTR => locale.languageCode != 'ar';
  bool get isRTL => locale.languageCode == 'ar';

  @override
  List<Object?> get props => [locale, currentLanguage, isLoading];
}
