bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) {
    final normalized = value.toLowerCase();
    return normalized == '1' || normalized == 'true';
  }
  return false;
}

class Poll {
  final int id;
  final String question;
  final List<PollOption> options;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endDate;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.isActive,
    required this.createdAt,
    this.endDate,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as int,
      question: json['question'] as String,
      options: (json['options'] as List)
          .map((opt) => PollOption.fromJson(opt as Map<String, dynamic>))
          .toList(),
      isActive: _parseBool(json['is_active']),
      createdAt: DateTime.parse(json['created_at'] as String),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
    );
  }
}

class PollOption {
  final int id;
  final String text;
  final int votes;
  final int totalVotes;
  final bool userVoted;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.totalVotes,
    required this.userVoted,
  });

  double get percentage => totalVotes == 0 ? 0 : (votes / totalVotes * 100);

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as int,
      text: json['text'] as String,
      votes: json['votes'] as int,
      totalVotes: json['total_votes'] as int,
      userVoted: _parseBool(json['user_voted']),
    );
  }
}
