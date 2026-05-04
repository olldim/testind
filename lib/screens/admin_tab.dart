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
    if (images == null) return '';
    final list = images as List<dynamic>? ?? [];
    return list.map((item) => item?.toString() ?? '').where((value) => value.isNotEmpty).join(', ');
  }

  String _joinLinks(dynamic links) {
    if (links == null) return '';
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
    if (options == null) return '';
    final list = options as List<dynamic>? ?? [];
    return list
        .map((item) {
          if (item is Map) return item['text']?.toString() ?? item.toString();
          return item?.toString() ?? '';
        })
        .where((value) => value.isNotEmpty)
        .join(', ');
  }

  Future<void> _showUserDialog({Map<String, dynamic>? user}) async {
    final loginController = TextEditingController(text: user?['login'] ?? '');
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController(text: user?['full_name'] ?? '');
    final groupController = TextEditingController(text: user?['group'] ?? '');
    bool isAdmin = user?['is_admin'] == 1;
    bool isActive = user?['is_active'] == 1;

    final isEdit = user != null;
    final token = context.read<AuthProvider>().token!;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Редагувати користувача' : 'Створити користувача',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: loginController,
                        decoration: InputDecoration(
                          labelText: 'Логін',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isEdit)
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          obscureText: true,
                        ),
                      if (!isEdit) const SizedBox(height: 16),
                      TextField(
                        controller: fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Повне ім\'я',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: groupController,
                        decoration: InputDecoration(
                          labelText: 'Група',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Адміністратор'),
                        value: isAdmin,
                        onChanged: (value) {
                          setState(() {
                            isAdmin = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('Активний'),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Скасувати'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              if (isEdit) {
                                await _runAdminAction(
                                  () => ApiService().updateUser(
                                    token,
                                    user['id'],
                                    {
                                      'login': loginController.text,
                                      'full_name': fullNameController.text,
                                      'group': groupController.text,
                                      'is_admin': isAdmin,
                                      'is_active': isActive,
                                    },
                                  ),
                                  'Користувача оновлено',
                                );
                              } else {
                                await _runAdminAction(
                                  () => ApiService().createUser(
                                    token,
                                    loginController.text,
                                    passwordController.text,
                                    fullNameController.text,
                                    groupController.text,
                                    isAdmin,
                                  ),
                                  'Користувача створено',
                                );
                              }
                            },
                            child: Text(isEdit ? 'Зберегти' : 'Створити'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNewsDialog({Map<String, dynamic>? news}) async {
    final titleController = TextEditingController(text: news?['title'] ?? '');
    final descriptionController = TextEditingController(text: news?['description'] ?? '');
    final contentController = TextEditingController(text: news?['content'] ?? '');
    final imagesController = TextEditingController(text: _joinImageUrls(news?['images']));
    final linksController = TextEditingController(text: _joinLinks(news?['links']));

    final isEdit = news != null;
    final token = context.read<AuthProvider>().token!;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Редагувати новину' : 'Створити новину',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Опис',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'Зміст',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imagesController,
                    decoration: InputDecoration(
                      labelText: 'URL картинок (через кому)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: linksController,
                    decoration: InputDecoration(
                      labelText: 'Посилання (назва|URL, через кому)',
                      helperText: 'Приклад: Далі|https://example.com, Додати|https://add.com',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Скасувати'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final images = imagesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                          final links = linksController.text
                              .split(',')
                              .map((raw) {
                                final parts = raw.split('|').map((e) => e.trim()).toList();
                                if (parts.length == 2) {
                                  return {'title': parts[0], 'url': parts[1]};
                                }
                                return null;
                              })
                              .whereType<Map<String, String>>()
                              .toList();
                          
                          if (isEdit) {
                            await _runAdminAction(
                              () => ApiService().updateNews(
                                token,
                                news['id'],
                                {
                                  'title': titleController.text,
                                  'description': descriptionController.text,
                                  'content': contentController.text,
                                  'images': images,
                                  'links': links,
                                },
                              ),
                              'Новину оновлено',
                            );
                          } else {
                            await _runAdminAction(
                              () => ApiService().createNews(
                                token,
                                titleController.text,
                                descriptionController.text,
                                contentController.text,
                                images,
                                links,
                              ),
                              'Новину створено',
                            );
                          }
                        },
                        child: Text(isEdit ? 'Зберегти' : 'Створити'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPollDialog({Map<String, dynamic>? poll}) async {
    final questionController = TextEditingController(text: poll?['question'] ?? '');
    final optionsController = TextEditingController(text: _joinOptions(poll?['options']));
    bool isActive = poll?['is_active'] == 1;
    DateTime? endDate = poll != null && poll['end_date'] != null ? DateTime.parse(poll['end_date']) : null;

    final isEdit = poll != null;
    final token = context.read<AuthProvider>().token!;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEdit ? 'Редагувати голосування' : 'Створити голосування',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: questionController,
                        decoration: InputDecoration(
                          labelText: 'Питання',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: optionsController,
                        decoration: InputDecoration(
                          labelText: 'Опції (через кому)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Активне'),
                        value: isActive,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Дата закінчення'),
                        subtitle: Text(endDate != null ? endDate.toString().split('.')[0] : 'Не встановлено'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                            });
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Скасувати'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final options = optionsController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              if (isEdit) {
                                await _runAdminAction(
                                  () => ApiService().updatePoll(
                                    token,
                                    poll['id'],
                                    {
                                      'question': questionController.text,
                                      'is_active': isActive,
                                      'end_date': endDate?.toIso8601String(),
                                      'options': options,
                                    },
                                  ),
                                  'Голосування оновлено',
                                );
                              } else {
                                await _runAdminAction(
                                  () => ApiService().createPoll(
                                    token,
                                    questionController.text,
                                    isActive,
                                    endDate?.toIso8601String(),
                                    options,
                                  ),
                                  'Голосування створено',
                                );
                              }
                            },
                            child: Text(isEdit ? 'Зберегти' : 'Створити'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
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
              icon: const Icon(Icons.edit),
              onPressed: _isLoading ? null : () => _showUserDialog(user: user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final token = context.read<AuthProvider>().token!;
                      await _runAdminAction(
                        () => ApiService().deleteUser(token, user['id']),
                        'Користувача видалено',
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(news['title']),
        subtitle: Text(news['description'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isLoading ? null : () => _showNewsDialog(news: news),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final token = context.read<AuthProvider>().token!;
                      await _runAdminAction(
                        () => ApiService().deleteNews(token, news['id']),
                        'Новину видалено',
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollCard(Map<String, dynamic> poll) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(poll['question']),
        subtitle: Text('${poll['options']?.length ?? 0} опцій • ${poll['is_active'] == 1 ? 'Активне' : 'Неактивне'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isLoading ? null : () => _showPollDialog(poll: poll),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading
                  ? null
                  : () async {
                      final token = context.read<AuthProvider>().token!;
                      await _runAdminAction(
                        () => ApiService().deletePoll(token, poll['id']),
                        'Голосування видалено',
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Адміністрація'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Користувачі'),
              Tab(text: 'Новини'),
              Tab(text: 'Голосування'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Користувачі
            FutureBuilder(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                    'Помилка завантаження користувачів',
                    () => _refreshAll(),
                  );
                }
                final users = snapshot.data as List<dynamic>? ?? [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader('Користувачі', () => _showUserDialog()),
                    ...users.map((user) => _buildUserCard(user as Map<String, dynamic>)),
                  ],
                );
              },
            ),
            // Новини
            FutureBuilder(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                    'Помилка завантаження новин',
                    () => _refreshAll(),
                  );
                }
                final news = snapshot.data as List<dynamic>? ?? [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader('Новини', () => _showNewsDialog()),
                    ...news.map((n) => _buildNewsCard(n as Map<String, dynamic>)),
                  ],
                );
              },
            ),
            // Голосування
            FutureBuilder(
              future: _pollsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                    'Помилка завантаження голосувань',
                    () => _refreshAll(),
                  );
                }
                final polls = snapshot.data as List<dynamic>? ?? [];
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionHeader('Голосування', () => _showPollDialog()),
                    ...polls.map((p) => _buildPollCard(p as Map<String, dynamic>)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
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
    );
  }
}
