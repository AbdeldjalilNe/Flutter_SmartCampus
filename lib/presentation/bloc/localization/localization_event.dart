part of 'localization_bloc.dart';

abstract class LocalizationEvent extends Equatable {
  const LocalizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocalization extends LocalizationEvent {}

class ChangeLanguage extends LocalizationEvent {
  const ChangeLanguage({required this.language});
  final AppLanguage language;

  @override
  List<Object?> get props => [language];
}
