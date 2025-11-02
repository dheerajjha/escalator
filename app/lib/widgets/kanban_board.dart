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
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat('Active', activeItems, const Color(0xFFF59E0B), const Color(0xFFFBBF24)),
              _buildStat('Resolved', resolvedItems, const Color(0xFF10B981), const Color(0xFF34D399)),
              _buildStat('Total', workItems.length, const Color(0xFF6366F1), const Color(0xFF8B5CF6)),
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

  Widget _buildStat(String label, int count, Color startColor, Color endColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSection(String title, Color color, List<WorkItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: color,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  items.length.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onWorkItemTap(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!.length > 100
                        ? '${item.description!.substring(0, 100)}...'
                        : item.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, size: 14, color: accentColor),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.dependencyPoc,
                          style: TextStyle(
                            fontSize: 12,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, size: 14, color: Colors.grey[500]),
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
      ),
    );
  }
}
