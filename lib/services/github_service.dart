import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/host_model.dart';

class GitHubService {
  static const String _baseUrl =
      'https://raw.githubusercontent.com/Adventistcollection98/vpn-host-provider/main/hosts.json';

  /// Fetch hosts from GitHub repository
  static Future<List<Host>> fetchHosts() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Host.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load hosts: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      throw Exception('Error fetching hosts: $e');
    }
  }
}
