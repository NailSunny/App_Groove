import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/admin/hall_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/trainer_admin_dto.dart';
import 'package:groove_app/api_DTOs/admin/type_class_admin_dto.dart';
import 'package:groove_app/api_service/admin_schedule_week_api.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:intl/intl.dart';

/// Диалоги добавления / редактирования / просмотра ячейки расписания админа.
class AdminScheduleCellDialog {
  AdminScheduleCellDialog._();

  static Future<bool> showAdd({
    required BuildContext context,
    required DateTime date,
    required String startTime,
    required int typeFilterIndex,
    required List<TrainerAdminDto> trainers,
    required List<TypeClassAdminDto> types,
    required List<HallAdminDto> halls,
  }) async {
    final lessonType = await _pickLessonType(context, typeFilterIndex);
    if (lessonType == null) return false;

    final isGroup = lessonType == 'group';
    final form = await _showDraftForm(
      context: context,
      title: isGroup ? 'Добавить групповое' : 'Добавить персональное',
      date: date,
      startTime: startTime,
      trainers: trainers,
      types: types,
      halls: halls,
      requireDirection: isGroup,
    );
    if (form == null) return false;

    final body = <String, dynamic>{
      'trainerId': form.trainerId,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'startTime': startTime,
      'hallId': form.hallId,
    };
    if (form.directionId != null) body['directionId'] = form.directionId;

    if (isGroup) {
      await adminCreateGroupDraft(body);
    } else {
      await adminCreatePersonalDraft(body);
    }
    return true;
  }

  static Future<bool> showEdit({
    required BuildContext context,
    required Map<String, dynamic> lesson,
    required List<TrainerAdminDto> trainers,
    required List<TypeClassAdminDto> types,
    required List<HallAdminDto> halls,
  }) async {
    final lessonType = lesson['lessonType'] as String? ?? 'group';
    final id = lesson['id'] as int;
    final isGroup = lessonType == 'group';

    final form = await _showDraftForm(
      context: context,
      title: isGroup ? 'Редактировать групповое' : 'Редактировать персональное',
      date: null,
      startTime: null,
      trainers: trainers,
      types: types,
      halls: halls,
      requireDirection: isGroup,
      initialTrainerId: lesson['trainerId'] as int?,
      initialDirectionId: isGroup ? lesson['directionId'] as int? : null,
      initialHallId: lesson['hallId'] as int?,
    );
    if (form == null) return false;

    final body = <String, dynamic>{
      'trainerId': form.trainerId,
      'hallId': form.hallId,
    };
    if (form.directionId != null) body['directionId'] = form.directionId;

    if (isGroup) {
      await adminUpdateGroupDraft(id, body);
    } else {
      await adminUpdatePersonalDraft(id, body);
    }
    return true;
  }

  static Future<bool> showDelete({
    required BuildContext context,
    required Map<String, dynamic> lesson,
  }) async {
    final lessonType = lesson['lessonType'] as String? ?? 'group';
    final direction = lesson['direction'] as String? ?? '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Удалить занятие?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          '$direction\n${lesson['trainer'] ?? ''}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: UnactiveRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return false;

    final id = lesson['id'] as int;
    if (lessonType == 'group') {
      await adminDeleteGroupDraft(id);
    } else {
      await adminDeletePersonalDraft(id);
    }
    return true;
  }

  static Future<void> showView({
    required BuildContext context,
    required Map<String, dynamic> lesson,
  }) async {
    final isGroup = lesson['lessonType'] == 'group';
    final lines = <String>[
      'Тип: ${isGroup ? 'Групповое' : 'Персональное'}',
      'Направление: ${lesson['direction'] ?? ''}',
      'Тренер: ${lesson['trainer'] ?? ''}',
      'Зал: ${lesson['hall'] ?? ''}',
      'Статус: ${lesson['status'] ?? ''}',
    ];
    if (isGroup) {
      lines.add('Места: ${lesson['places'] ?? ''}');
    } else if (lesson['client'] != null) {
      lines.add('Клиент: ${lesson['client']}');
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Занятие', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(lines.join('\n'), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Закрыть')),
        ],
      ),
    );
  }

  static Future<String?> _pickLessonType(BuildContext context, int typeFilterIndex) async {
    if (typeFilterIndex == 1) return 'group';
    if (typeFilterIndex == 2) return 'personal';
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Тип занятия', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Групповое', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () => Navigator.pop(ctx, 'group'),
            ),
            ListTile(
              title: Text('Персональное', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              onTap: () => Navigator.pop(ctx, 'personal'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<_DraftFormResult?> _showDraftForm({
    required BuildContext context,
    required String title,
    required DateTime? date,
    required String? startTime,
    required List<TrainerAdminDto> trainers,
    required List<TypeClassAdminDto> types,
    required List<HallAdminDto> halls,
    int? initialTrainerId,
    int? initialDirectionId,
    int? initialHallId,
    bool requireDirection = true,
  }) async {
    if (trainers.isEmpty || halls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужны тренеры и залы в справочниках')),
      );
      return null;
    }
    if (requireDirection && types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нужны направления в справочнике')),
      );
      return null;
    }

    int trainerId = initialTrainerId ?? trainers.first.idTrainer;
    int? directionId = initialDirectionId;
    int hallId = initialHallId ?? halls.first.idHall;

    List<TypeClassAdminDto> directionsForTrainer(int tid) {
      final t = trainers.firstWhere((x) => x.idTrainer == tid, orElse: () => trainers.first);
      if (t.typeClassIds.isEmpty) return types;
      return types.where((tc) => t.typeClassIds.contains(tc.idType)).toList();
    }

    if (requireDirection) {
      var allowed = directionsForTrainer(trainerId);
      directionId ??= allowed.isNotEmpty ? allowed.first.idType : types.first.idType;
      if (!allowed.any((d) => d.idType == directionId)) {
        directionId = allowed.isNotEmpty ? allowed.first.idType : types.first.idType;
      }
    }

    return showDialog<_DraftFormResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          List<TypeClassAdminDto> allowed = [];
          if (requireDirection) {
            allowed = directionsForTrainer(trainerId);
            if (directionId != null && !allowed.any((d) => d.idType == directionId)) {
              directionId = allowed.isNotEmpty ? allowed.first.idType : types.first.idType;
            }
          }

          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (date != null && startTime != null)
                      Text(
                        '${DateFormat('d MMMM yyyy', 'ru').format(date)} · $startTime',
                        style: TextStyle(color: ProcessYellow),
                      ),
                    if (date != null) SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: trainerId,
                      dropdownColor: BackBlack,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: adminInputDecoration(context, 'Тренер *'),
                      items: trainers
                          .map((t) => DropdownMenuItem(
                                value: t.idTrainer,
                                child: Text(t.fullName),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setDialogState(() => trainerId = v);
                      },
                    ),
                    if (requireDirection) ...[
                      SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: directionId,
                        dropdownColor: BackBlack,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        decoration: adminInputDecoration(context, 'Направление *'),
                        items: (allowed.isEmpty ? types : allowed)
                            .map((d) => DropdownMenuItem(
                                  value: d.idType,
                                  child: Text(d.nameType ?? ''),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => directionId = v),
                      ),
                    ],
                    SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: hallId,
                      dropdownColor: BackBlack,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      decoration: adminInputDecoration(context, 'Зал *'),
                      items: halls
                          .map((h) => DropdownMenuItem(
                                value: h.idHall,
                                child: Text(h.numberHall ?? 'Зал ${h.idHall}'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => hallId = v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
              ElevatedButton(
                onPressed: (requireDirection && directionId == null)
                    ? null
                    : () => Navigator.pop(
                          ctx,
                          _DraftFormResult(
                            trainerId: trainerId,
                            directionId: directionId,
                            hallId: hallId,
                          ),
                        ),
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DraftFormResult {
  final int trainerId;
  final int? directionId;
  final int hallId;

  _DraftFormResult({
    required this.trainerId,
    this.directionId,
    required this.hallId,
  });
}
