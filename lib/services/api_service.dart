import 'dart:convert';
import 'package:http/http.dart' as http;
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
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to load polls');
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
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Vote failed');
      }
    } catch (e) {
      throw Exception('Vote error: $e');
    }
  }

  Future<void> createUser(String token, String login, String password, String fullName, String group, bool isAdmin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'login': login,
          'password': password,
          'full_name': fullName,
          'group': group,
          'is_admin': isAdmin,
        }),
      );

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      throw Exception('Create user error: $e');
    }
  }

  Future<void> createNews(String token, String title, String description, String content, List<String> images, List<Map<String, String>> links) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/news'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'content': content,
          'images': images,
          'links': links,
        }),
      );

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create news');
      }
    } catch (e) {
      throw Exception('Create news error: $e');
    }
  }

  Future<void> createPoll(String token, String question, bool isActive, String? endDate, List<String> options) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/polls'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'is_active': isActive,
          'end_date': endDate,
          'options': options,
        }),
      );

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to create poll');
      }
    } catch (e) {
      throw Exception('Create poll error: $e');
    }
  }

  Future<List<dynamic>> getAdminUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to load users');
    } catch (e) {
      throw Exception('Get admin users error: $e');
    }
  }

  Future<List<dynamic>> getAdminNews(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/news'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to load news');
    } catch (e) {
      throw Exception('Get admin news error: $e');
    }
  }

  Future<List<dynamic>> getAdminPolls(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/polls'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to load polls');
    } catch (e) {
      throw Exception('Get admin polls error: $e');
    }
  }

  Future<void> deleteUser(String token, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete user');
      }
    } catch (e) {
      throw Exception('Delete user error: $e');
    }
  }

  Future<void> updateUser(String token, int userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Update user error: $e');
    }
  }

  Future<void> deleteNews(String token, int newsId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/news/$newsId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete news');
      }
    } catch (e) {
      throw Exception('Delete news error: $e');
    }
  }

  Future<void> updateNews(String token, int newsId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/news/$newsId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update news');
      }
    } catch (e) {
      throw Exception('Update news error: $e');
    }
  }

  Future<void> deletePoll(String token, int pollId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/polls/$pollId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete poll');
      }
    } catch (e) {
      throw Exception('Delete poll error: $e');
    }
  }

  Future<void> updatePoll(String token, int pollId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/polls/$pollId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update poll');
      }
    } catch (e) {
      throw Exception('Update poll error: $e');
    }
  }
}
