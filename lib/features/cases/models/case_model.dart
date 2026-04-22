class CaseModel {
  final String id;
  final String type;
  final String source;
  final String description;
  final String status;
  final String priority;
  final String? location;
  final String? assignedTo;
  final String? assignedPhone;
  final String? date;
  final String? createdAt;
  final int updates;
  final List<CaseTimelineEntry> timeline;
  final Map<String, String> details;

  const CaseModel({
    required this.id,
    required this.type,
    required this.source,
    required this.description,
    required this.status,
    required this.priority,
    this.location,
    this.assignedTo,
    this.assignedPhone,
    this.date,
    this.createdAt,
    this.updates = 0,
    this.timeline = const [],
    this.details = const {},
  });

  String get displayId {
    final prefix = source == 'sos'
        ? 'SOS'
        : source == 'aid_request'
            ? 'REQ'
            : 'RPT';
    return '$prefix-${id.substring(0, 4).toUpperCase()}';
  }

  String get timeAgo {
    final dateStr = createdAt ?? date;
    if (dateStr == null) return '';
    final created = DateTime.tryParse(dateStr);
    if (created == null) return date ?? '';
    final diff = DateTime.now().difference(created);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  String get displayStatus {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) {
          if (w.isEmpty) return w;
          return w[0].toUpperCase() + w.substring(1);
        })
        .join(' ');
  }
}

class CaseTimelineEntry {
  final String time;
  final String title;
  final String description;
  final String status;

  const CaseTimelineEntry({
    required this.time,
    required this.title,
    required this.description,
    required this.status,
  });
}
