import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/news.dart';
import '../models/poll.dart';

class ApiService {
  // Замініть на ваш IP адресу або домен сервера
  static const String baseUrl = 'http://188.190.37.238:3000/api';

  // Авторизація
  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login': login,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Новини
  Future<List<News>> getNews(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> newsList = jsonDecode(response.body);
        return newsList.map((news) => News.fromJson(news)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Get news error: $e');
    }
  }

  Future<News> getNewsDetail(String token, int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news/$newsId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return News.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load news detail');
      }
    } catch (e) {
      throw Exception('Get news detail error: $e');
    }
  }

  // Голосування
  Future<List<Poll>> getPolls(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/polls'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> pollsList = jsonDecode(response.body);
        return pollsList.map((poll) => Poll.fromJson(poll)).toList();
      } else {
        throw Exception('Failed to load polls');
      }
    } catch (e) {
      throw Exception('Get polls error: $e');
    }
  }

  Future<void> vote(String token, int pollId, int optionId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/polls/$pollId/vote'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'option_id': optionId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Vote failed');
      }
    } catch (e) {
      throw Exception('Vote error: $e');
    }
  }
}
