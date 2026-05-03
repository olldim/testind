import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/poll.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class PollsTab extends StatefulWidget {
  const PollsTab({super.key});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab> {
  late Future<List<Poll>> _pollsFuture;

  @override
  void initState() {
    super.initState();
    _loadPolls();
  }

  void _loadPolls() {
    final token = context.read<AuthProvider>().token!;
    _pollsFuture = ApiService().getPolls(token);
  }

  Future<void> _vote(Poll poll, PollOption option) async {
    final token = context.read<AuthProvider>().token!;
    try {
      await ApiService().vote(token, poll.id, option.id);
      setState(() {
        _loadPolls();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ви проголосували')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loadPolls();
        });
      },
      child: FutureBuilder<List<Poll>>(
        future: _pollsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  const Text('Помилка при завантаженні голосувань'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadPolls();
                      });
                    },
                    child: const Text('Спробувати ще раз'),
                  ),
                ],
              ),
            );
          }

          final polls = snapshot.data ?? [];

          if (polls.isEmpty) {
            return const Center(
              child: Text('Голосувань немає'),
            );
          }

          // Розділити активні та неактивні голосування
          final activePolls = polls.where((p) => p.isActive).toList();
          final inactivePolls = polls.where((p) => !p.isActive).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Активні голосування
              if (activePolls.isNotEmpty) ...[
                const Text(
                  'Активні голосування',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...activePolls.map((poll) => _buildPollCard(poll, true)),
                const SizedBox(height: 24),
              ],

              // Завершені голосування
              if (inactivePolls.isNotEmpty) ...[
                const Text(
                  'Завершені голосування',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...inactivePolls.map((poll) => _buildPollCard(poll, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPollCard(Poll poll, bool isActive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Питання
            Text(
              poll.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Варіанти відповідей
            ...poll.options.map((option) {
              final hasUserVoted = option.userVoted;
              final percentage = option.percentage;

              return Column(
                children: [
                  // Назва та відсоток
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option.text,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Прогрес бар
                  GestureDetector(
                    onTap: isActive && !hasUserVoted
                        ? () => _vote(poll, option)
                        : null,
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200],
                      ),
                      child: Stack(
                        children: [
                          // Фон прогресу
                          Container(
                            height: 36,
                            width: (percentage / 100) *
                                (MediaQuery.of(context).size.width - 64),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blue[300],
                            ),
                          ),
                          // Текст всередині
                          Center(
                            child: Text(
                              '${option.votes} голосів',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Галочка якщо користувач голосував
                          if (hasUserVoted)
                            Positioned(
                              right: 12,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Icon(
                                  Icons.check,
                                  color: Colors.green[700],
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),

            // Статус
            if (!isActive)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Завершено',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
