import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AdminTab extends StatefulWidget {
  const AdminTab({super.key});

  @override
  State<AdminTab> createState() => _AdminTabState();
}

class _AdminTabState extends State<AdminTab> {
  late Future<List<dynamic>> _usersFuture;
  late Future<List<dynamic>> _newsFuture;
  late Future<List<dynamic>> _pollsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    final token = context.read<AuthProvider>().token!;
    _usersFuture = ApiService().getAdminUsers(token);
    _newsFuture = ApiService().getAdminNews(token);
    _pollsFuture = ApiService().getAdminPolls(token);
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loadAll();
    });
  }

  Future<void> _runAdminAction(Future<void> Function() action, String successMessage) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
      _refreshAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Помилка: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _joinImageUrls(dynamic images) {
    final list = images as List<dynamic>? ?? [];
    return list.map((item) => item?.toString() ?? '').where((value) => value.isNotEmpty).join(', ');
  }

  String _joinLinks(dynamic links) {
    final list = links as List<dynamic>? ?? [];
    return list
        .map((item) {
          if (item is Map) {
            return '${item['title'] ?? ''}|${item['url'] ?? ''}';
          }
          return item?.toString() ?? '';
        })
        .where((value) => value.isNotEmpty)
        .join(', ');
  }

  String _joinOptions(dynamic options) {
    final list = options as List<dynamic>? ?? [];
    return list
        .map((item) {
          if (item is Map) return item['text']?.toString() ?? item.toString();
          return item?.toString() ?? '';
        })
        .where((value) => value.isNotEmpty)
        .join(', ');
  }

  List<String> _normalizeOptions(dynamic options) {
    final list = options as List<dynamic>? ?? [];
    return list.map((item) {
      if (item is Map) return item['text']?.toString() ?? item.toString();
      return item?.toString() ?? '';
    }).where((value) => value.isNotEmpty).toList();
  }

  List<Map<String, String>> _normalizeLinks(String rawLinks) {
    return rawLinks
        .split(',')
        .map((raw) => raw.split('|').map((e) => e.trim()).toList())
        .where((parts) => parts.length == 2)
        .map((parts) => {'title': parts[0], 'url': parts[1]})
        .toList();
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final loginController = TextEditingController(text: user?['login'] ?? '');
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: user?['full_name'] ?? '');
    final groupController = TextEditingController(text: user?['group'] ?? '');
    bool isAdmin = user?['is_admin'] == 1 || user?['is_admin'] == true;
    final isEdit = user != null;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Редагувати користувача' : 'Створити користувача'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) TextField(controller: loginController, decoration: const InputDecoration(labelText: 'Login')),
                TextField(controller: passwordController, decoration: InputDecoration(labelText: isEdit ? 'Новий пароль (за бажанням)' : 'Password'), obscureText: true),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name')),
                TextField(controller: groupController, decoration: const InputDecoration(labelText: 'Group')),
                SwitchListTile(
                  title: const Text('Адмін'),
                  value: isAdmin,
                  onChanged: (value) => setState(() => isAdmin = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
            ElevatedButton(
              onPressed: () async {
                final login = loginController.text.trim();
                final password = passwordController.text.trim();
                final fullName = nameController.text.trim();
                final group = groupController.text.trim();

                if (!isEdit && login.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login обов’язковий')));
                  return;
                }
                if (fullName.isEmpty || group.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заповніть всі поля')));
                  return;
                }

                Navigator.of(context).pop();
                await _runAdminAction(() async {
                  final token = context.read<AuthProvider>().token!;
                  if (isEdit) {
                    final data = <String, dynamic>{
                      'full_name': fullName,
                      'group': group,
                      'is_admin': isAdmin,
                    };
                    if (password.isNotEmpty) data['password'] = password;
                    await ApiService().updateUser(token, user!['id'] as int, data);
                  } else {
                    await ApiService().createUser(token, login, password, fullName, group, isAdmin);
                  }
                }, isEdit ? 'Користувача оновлено' : 'Користувача створено');
              },
              child: Text(isEdit ? 'Зберегти' : 'Створити'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNewsDialog({Map<String, dynamic>? news}) async {
    final titleController = TextEditingController(text: news?['title'] ?? '');
    final descriptionController = TextEditingController(text: news?['description'] ?? '');
    final contentController = TextEditingController(text: news?['content'] ?? '');
    final imagesController = TextEditingController(text: _joinImageUrls(news?['images']));
    final linksController = TextEditingController(text: _joinLinks(news?['links']));

    final isEdit = news != null;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Редагувати новину' : 'Створити новину'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Content'), maxLines: 4),
                TextField(controller: imagesController, decoration: const InputDecoration(labelText: 'Images (comma separated URLs)')),
                TextField(controller: linksController, decoration: const InputDecoration(labelText: 'Links (title|url, ...)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final description = descriptionController.text.trim();
                final content = contentController.text.trim();
                final images = imagesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final links = linksController.text
                    .split(',')
                    .map((raw) => raw.split('|').map((e) => e.trim()).toList())
                    .where((parts) => parts.length == 2)
                    .map((parts) => {'title': parts[0], 'url': parts[1]})
                    .toList();

                if (title.isEmpty || description.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заповніть заголовок, опис та текст')));
                  return;
                }

                Navigator.of(context).pop();
                await _runAdminAction(() async {
                  final token = context.read<AuthProvider>().token!;
                  if (isEdit) {
                    await ApiService().updateNews(token, news!['id'] as int, {
                      'title': title,
                      'description': description,
                      'content': content,
                      'images': images,
                      'links': links,
                    });
                  } else {
                    await ApiService().createNews(token, title, description, content, images, links);
                  }
                }, isEdit ? 'Новину оновлено' : 'Новину створено');
              },
              child: Text(isEdit ? 'Зберегти' : 'Створити'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPollDialog({Map<String, dynamic>? poll}) async {
    final questionController = TextEditingController(text: poll?['question'] ?? '');
    final optionsController = TextEditingController(text: _joinOptions(poll?['options']));
    final endDateController = TextEditingController(text: poll?['end_date'] ?? '');
    bool isActive = poll == null ? true : (poll['is_active'] == 1 || poll['is_active'] == true);

    final isEdit = poll != null;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Редагувати голосування' : 'Створити голосування'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: questionController, decoration: const InputDecoration(labelText: 'Question')),
                TextField(controller: optionsController, decoration: const InputDecoration(labelText: 'Options (comma separated)')),
                TextField(controller: endDateController, decoration: const InputDecoration(labelText: 'End date (YYYY-MM-DD HH:MM:SS)')),
                SwitchListTile(
                  title: const Text('Активне голосування'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Скасувати')),
            ElevatedButton(
              onPressed: () async {
                final question = questionController.text.trim();
                final options = optionsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
                final endDate = endDateController.text.trim().isEmpty ? null : endDateController.text.trim();

                if (question.isEmpty || options.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заповніть питання та мінімум 2 варіанти')));
                  return;
                }

                Navigator.of(context).pop();
                await _runAdminAction(() async {
                  final token = context.read<AuthProvider>().token!;
                  if (isEdit) {
                    await ApiService().updatePoll(token, poll!['id'] as int, {
                      'question': question,
                      'is_active': isActive,
                      'end_date': endDate,
                      'options': options,
                    });
                  } else {
                    await ApiService().createPoll(token, question, isActive, endDate, options);
                  }
                }, isEdit ? 'Голосування оновлено' : 'Голосування створено');
              },
              child: Text(isEdit ? 'Зберегти' : 'Створити'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onCreate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Створити'),
            onPressed: _isLoading ? null : onCreate,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(user['full_name'] ?? user['login']),
        subtitle: Text('${user['login']} • ${user['group']} • ${user['is_admin'] == 1 ? 'Адмін' : 'Користувач'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showUserDialog(user: user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(
                title: 'Видалити користувача?',
                onConfirm: () async {
                  final token = context.read<AuthProvider>().token!;
                  await _runAdminAction(() async => ApiService().deleteUser(token, user['id'] as int), 'Користувача видалено');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(news['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showNewsDialog(news: news),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(
                    title: 'Видалити новину?',
                    onConfirm: () async {
                      final token = context.read<AuthProvider>().token!;
                      await _runAdminAction(() async => ApiService().deleteNews(token, news['id'] as int), 'Новину видалено');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(news['description'] ?? '', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 8),
            Text(news['created_at'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPollCard(Map<String, dynamic> poll) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(poll['question'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showPollDialog(poll: poll),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(
                    title: 'Видалити голосування?',
                    onConfirm: () async {
                      final token = context.read<AuthProvider>().token!;
                      await _runAdminAction(() async => ApiService().deletePoll(token, poll['id'] as int), 'Голосування видалено');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Активне: ${poll['is_active'] == 1 ? 'так' : 'ні'}', style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Завершення: ${poll['end_date'] ?? '—'}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete({required String title, required Future<void> Function() onConfirm}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Скасувати')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Видалити')),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade800, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.blue[100],
              tabs: const [
                Tab(text: 'Користувачі'),
                Tab(text: 'Новини'),
                Tab(text: 'Голосування'),
              ],
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 4)
          else
            const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: FutureBuilder<List<dynamic>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString(), _refreshAll);
                      }
                      final users = snapshot.data ?? [];
                      return _buildListSection(
                        title: 'Користувачі',
                        buttonLabel: 'Створити користувача',
                        onCreate: () => _showUserDialog(),
                        items: users,
                        itemBuilder: (item) => _buildUserCard(item as Map<String, dynamic>),
                      );
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: FutureBuilder<List<dynamic>>(
                    future: _newsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString(), _refreshAll);
                      }
                      final news = snapshot.data ?? [];
                      return _buildListSection(
                        title: 'Новини',
                        buttonLabel: 'Створити новину',
                        onCreate: () => _showNewsDialog(),
                        items: news,
                        itemBuilder: (item) => _buildNewsCard(item as Map<String, dynamic>),
                      );
                    },
                  ),
                ),
                RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: FutureBuilder<List<dynamic>>(
                    future: _pollsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString(), _refreshAll);
                      }
                      final polls = snapshot.data ?? [];
                      return _buildListSection(
                        title: 'Голосування',
                        buttonLabel: 'Створити голосування',
                        onCreate: () => _showPollDialog(),
                        items: polls,
                        itemBuilder: (item) => _buildPollCard(item as Map<String, dynamic>),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required String buttonLabel,
    required VoidCallback onCreate,
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : onCreate,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Center(child: Text('Поки нічого немає', style: TextStyle(color: Colors.black54))),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : onCreate,
                icon: const Icon(Icons.add),
                label: Text(buttonLabel),
              ),
            ],
          );
        }
        return itemBuilder(items[index - 1]);
      },
    );
  }

  Widget _buildError(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Повторити')),
          ],
        ),
      ),
    );
  }
}
