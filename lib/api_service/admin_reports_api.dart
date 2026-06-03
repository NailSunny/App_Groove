import 'dart:convert';
import 'dart:io';

import 'package:groove_app/api_DTOs/admin/report_dtos.dart';
import 'package:groove_app/api_service/admin_api.dart';
import 'package:groove_app/config/api_config.dart';
import 'package:groove_app/helper/admin_http.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

String _dateOnly(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, String> _rangeParams(DateTime start, DateTime end) => {
      'startDate': _dateOnly(start),
      'endDate': _dateOnly(end),
    };

Future<FinanceReportDto> fetchFinanceReport({
  required DateTime startDate,
  required DateTime endDate,
  int? hallId,
  String granularity = 'day',
}) async {
  final headers = await adminAuthHeaders();
  final params = _rangeParams(startDate, endDate)
    ..['granularity'] = granularity;
  if (hallId != null) params['hallId'] = hallId.toString();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/reports/finance')
      .replace(queryParameters: params);
  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 30));
  await checkAdminHttpResponse(response);
  return FinanceReportDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<TrainerReportDto> fetchTrainerReport({
  required DateTime startDate,
  required DateTime endDate,
  int? trainerId,
  int? hallId,
}) async {
  final headers = await adminAuthHeaders();
  final params = _rangeParams(startDate, endDate);
  if (trainerId != null) params['trainerId'] = trainerId.toString();
  if (hallId != null) params['hallId'] = hallId.toString();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/reports/trainers')
      .replace(queryParameters: params);
  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 30));
  await checkAdminHttpResponse(response);
  return TrainerReportDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<AttendanceReportDto> fetchAttendanceReport({
  required DateTime startDate,
  required DateTime endDate,
  int? trainerId,
  int? hallId,
  int? typeId,
  String? clientSearch,
  int churnDays = 30,
}) async {
  final headers = await adminAuthHeaders();
  final params = _rangeParams(startDate, endDate);
  if (trainerId != null) params['trainerId'] = trainerId.toString();
  if (hallId != null) params['hallId'] = hallId.toString();
  if (typeId != null) params['typeId'] = typeId.toString();
  if (clientSearch != null && clientSearch.isNotEmpty) {
    params['clientSearch'] = clientSearch;
  }
  params['churnDays'] = churnDays.toString();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/reports/attendance')
      .replace(queryParameters: params);
  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 30));
  await checkAdminHttpResponse(response);
  return AttendanceReportDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<String> downloadReportCsv(String pathSegment, Map<String, String> params) async {
  final headers = await adminAuthHeaders();
  final uri = Uri.parse('${ApiConfig.baseUrl}/api/reports/$pathSegment/export')
      .replace(queryParameters: params);
  final response = await http
      .get(uri, headers: headers)
      .timeout(const Duration(seconds: 30));
  await checkAdminHttpResponse(response);
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final fileName = pathSegment.split('/').last;
  final file = File('${dir.path}/report_$fileName${_dateOnly(DateTime.now())}.csv');
  await file.writeAsBytes(response.bodyBytes);
  return file.path;
}

Future<String> exportFinanceCsv(DateTime start, DateTime end, {int? hallId}) {
  final params = _rangeParams(start, end);
  if (hallId != null) params['hallId'] = hallId.toString();
  return downloadReportCsv('finance', params);
}

Future<String> exportTrainerCsv(DateTime start, DateTime end, {int? trainerId}) {
  final params = _rangeParams(start, end);
  if (trainerId != null) params['trainerId'] = trainerId.toString();
  return downloadReportCsv('trainers', params);
}

Future<String> exportAttendanceCsv(DateTime start, DateTime end,
    {int? trainerId, int? typeId}) {
  final params = _rangeParams(start, end);
  if (trainerId != null) params['trainerId'] = trainerId.toString();
  if (typeId != null) params['typeId'] = typeId.toString();
  return downloadReportCsv('attendance', params);
}
