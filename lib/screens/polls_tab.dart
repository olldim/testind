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
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...poll.options.map((option) {
              final hasUserVoted = option.userVoted;
              final percentage = option.percentage;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade100,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isActive && !hasUserVoted ? () => _vote(poll, option) : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  option.text,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: hasUserVoted ? FontWeight.w700 : FontWeight.w500,
                                    color: hasUserVoted ? Colors.blue.shade900 : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${percentage.toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              minHeight: 10,
                              value: percentage / 100,
                              backgroundColor: Colors.white,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${option.votes} голосів',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              if (hasUserVoted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, size: 14, color: Colors.green.shade700),
                                      const SizedBox(width: 4),
                                      Text('Ваш вибір', style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            if (!isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Завершено',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
