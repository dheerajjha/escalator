class WorkItem {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String dependencyPoc;
  final String? pocEmail;
  final String currentStage;
  final String? impact;
  final String? managerName;
  final String? managerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime stageUpdatedAt;
  final DateTime? resolvedAt;
  final List<EscalationHistory>? history;
  final List<StandupUpdate>? standups;

  WorkItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dependencyPoc,
    this.pocEmail,
    required this.currentStage,
    this.impact,
    this.managerName,
    this.managerEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.stageUpdatedAt,
    this.resolvedAt,
    this.history,
    this.standups,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      dependencyPoc: json['dependency_poc'],
      pocEmail: json['poc_email'],
      currentStage: json['current_stage'],
      impact: json['impact'],
      managerName: json['manager_name'],
      managerEmail: json['manager_email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      stageUpdatedAt: DateTime.parse(json['stage_updated_at']),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      history: json['history'] != null
          ? (json['history'] as List)
              .map((h) => EscalationHistory.fromJson(h))
              .toList()
          : null,
      standups: json['standups'] != null
          ? (json['standups'] as List)
              .map((s) => StandupUpdate.fromJson(s))
              .toList()
          : null,
    );
  }
}

class EscalationHistory {
  final int id;
  final int workItemId;
  final String? fromStage;
  final String toStage;
  final String actionTaken;
  final String? notes;
  final DateTime timestamp;

  EscalationHistory({
    required this.id,
    required this.workItemId,
    this.fromStage,
    required this.toStage,
    required this.actionTaken,
    this.notes,
    required this.timestamp,
  });

  factory EscalationHistory.fromJson(Map<String, dynamic> json) {
    return EscalationHistory(
      id: json['id'],
      workItemId: json['work_item_id'],
      fromStage: json['from_stage'],
      toStage: json['to_stage'],
      actionTaken: json['action_taken'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class StandupUpdate {
  final int id;
  final int workItemId;
  final String updateText;
  final String date;
  final DateTime createdAt;

  StandupUpdate({
    required this.id,
    required this.workItemId,
    required this.updateText,
    required this.date,
    required this.createdAt,
  });

  factory StandupUpdate.fromJson(Map<String, dynamic> json) {
    return StandupUpdate(
      id: json['id'],
      workItemId: json['work_item_id'],
      updateText: json['update_text'],
      date: json['date'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
