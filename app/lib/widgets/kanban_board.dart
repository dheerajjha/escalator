import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/work_item.dart';

class KanbanBoard extends StatelessWidget {
  final List<WorkItem> workItems;
  final Function(WorkItem) onWorkItemTap;

  const KanbanBoard({
    super.key,
    required this.workItems,
    required this.onWorkItemTap,
  });

  static const stages = [
    {'id': 'active', 'name': 'Active', 'color': Colors.blue},
    {'id': 'day2_nudge', 'name': 'Day 2 - Nudge', 'color': Colors.orange},
    {'id': 'day4_second_nudge', 'name': 'Day 4 - 2nd Nudge', 'color': Colors.deepOrange},
    {'id': 'week1_call', 'name': 'Week 1 - Call', 'color': Colors.red},
    {'id': 'manager_escalation', 'name': 'Manager Escalation', 'color': Colors.redAccent},
    {'id': 'resolved', 'name': 'Resolved', 'color': Colors.green},
  ];

  List<WorkItem> _getItemsByStage(String stageId) {
    return workItems.where((item) => item.currentStage == stageId).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeItems = workItems.where((item) => item.currentStage != 'resolved').length;
    final resolvedItems = workItems.where((item) => item.currentStage == 'resolved').length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Active', activeItems, Colors.orange),
              _buildStat('Resolved', resolvedItems, Colors.green),
              _buildStat('Total', workItems.length, Colors.blue),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: stages.length,
            itemBuilder: (context, index) {
              final stage = stages[index];
              final items = _getItemsByStage(stage['id'] as String);

              return _buildStageSection(
                stage['name'] as String,
                stage['color'] as Color,
                items,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStageSection(String title, Color color, List<WorkItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  items.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No items in this stage',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          )
        else
          ...items.map((item) => _buildWorkItemCard(item, color)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWorkItemCard(WorkItem item, Color accentColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => onWorkItemTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description!.length > 100
                      ? '${item.description!.substring(0, 100)}...'
                      : item.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.dependencyPoc,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(item.stageUpdatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
