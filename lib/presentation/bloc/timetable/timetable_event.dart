part of 'timetable_bloc.dart';

abstract class TimetableEvent extends Equatable {
  const TimetableEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimetable extends TimetableEvent {}

class AddTimetableItem extends TimetableEvent {
  const AddTimetableItem({required this.item});
  final TimetableItem item;

  @override
  List<Object?> get props => [item];
}

class UpdateTimetableItem extends TimetableEvent {
  const UpdateTimetableItem({required this.item});
  final TimetableItem item;

  @override
  List<Object?> get props => [item];
}

class DeleteTimetableItem extends TimetableEvent {
  const DeleteTimetableItem({required this.id});
  final String id;

  @override
  List<Object?> get props => [id];
}

class ExportTimetable extends TimetableEvent {}

class ImportTimetable extends TimetableEvent {
  const ImportTimetable({required this.json});
  final String json;

  @override
  List<Object?> get props => [json];
}

class ToggleNotification extends TimetableEvent {
  const ToggleNotification({
    required this.itemId,
    required this.enabled,
  });
  final String itemId;
  final bool enabled;

  @override
  List<Object?> get props => [itemId, enabled];
}
