
  import 'dart:convert';

import 'package:groove_app/api_DTOs/schedulegroup_dto.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:http/http.dart' as http;

Future<List<TypeClassDto>> getTypeClasses() async {
    final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/api/schedule/types"));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => TypeClassDto.fromJson(json)).toList();
    } else {
      throw Exception("Не удалось загрузить типы занятий");
    }
  }

  Future<List<GroupClassScheduleDto>> getGroupSchedule(DateTime date, {int? typeId}) async {
    final formattedDate = date.toIso8601String();
    final url = Uri.parse("${ApiConfig.baseUrl}/api/schedule/group-classes?date=$formattedDate${typeId != null ? '&typeId=$typeId' : ''}");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => GroupClassScheduleDto.fromJson(json)).toList();
    } else {
      throw Exception("Не удалось загрузить расписание");
    }
  }