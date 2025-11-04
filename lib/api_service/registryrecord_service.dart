// import 'dart:convert';

// import 'package:groove_app/api_DTOs/registryrecord_dto.dart';
// import 'package:http/http.dart' as http;

// Future<List<RegistryRecord>> fetchRegistryRecords(int userId, DateTime from, DateTime to) async {
//   final uri = Uri.parse('http://localhost:5255/api/registry/$userId/date-range')
//       .replace(queryParameters: {
//         'from': from.toIso8601String(),
//         'to': to.toIso8601String(),
//       });

//   final response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     return data.map((json) => RegistryRecord.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load records');
//   }
// }

// Future<bool> cancelRegistry(int registryId, int userId) async {
//   final url = Uri.parse(
//     'http://localhost:5255/api/registry/$registryId/cancel?userId=$userId',
//   );
//   final response = await http.delete(url);

//   return response.statusCode == 200;
// }
