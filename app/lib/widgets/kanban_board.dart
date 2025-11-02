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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Your Work Items',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              _buildStatChip('Active', activeItems, const Color(0xFF3B82F6)),
              const SizedBox(width: 12),
              _buildStatChip('Resolved', resolvedItems, const Color(0xFF10B981)),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
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

  Widget _buildStatChip(String label, int count, Color color) {
    return Row(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStageSection(String title, Color color, List<WorkItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: 3),
            ),
          ),
          child: Row(
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: InkWell(
        onTap: () => onWorkItemTap(item),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.description!.length > 80
                      ? '${item.description!.substring(0, 80)}...'
                      : item.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              _buildInfoRow('POC:', item.dependencyPoc),
              if (item.impact != null && item.impact!.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildInfoRow('Impact:', item.impact!.length > 40
                  ? '${item.impact!.substring(0, 40)}...'
                  : item.impact!),
              ],
              const SizedBox(height: 4),
              _buildInfoRow('Updated:', _formatDate(item.stageUpdatedAt)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
