import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/work_item.dart';
import '../providers/work_items_provider.dart';
import '../providers/user_provider.dart';

class WorkItemDetailScreen extends StatefulWidget {
  final int workItemId;

  const WorkItemDetailScreen({super.key, required this.workItemId});

  @override
  State<WorkItemDetailScreen> createState() => _WorkItemDetailScreenState();
}

class _WorkItemDetailScreenState extends State<WorkItemDetailScreen> {
  WorkItem? _workItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkItem();
  }

  Future<void> _loadWorkItem() async {
    setState(() => _isLoading = true);

    try {
      final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);
      final workItem = await workItemsProvider.getWorkItem(widget.workItemId);

      setState(() {
        _workItem = workItem;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load work item: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleEscalate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escalate Work Item'),
        content: const Text('Are you sure you want to escalate this work item to the next stage?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Escalate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);

      await workItemsProvider.escalateWorkItem(
        widget.workItemId,
        userProvider.currentUser!.id,
        '',
      );

      await _loadWorkItem();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work item escalated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to escalate: $e')),
        );
      }
    }
  }

  Future<void> _handleResolve() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Resolve Work Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Resolution notes (optional)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Resolve'),
            ),
          ],
        );
      },
    );

    if (notes == null) return;

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);

      await workItemsProvider.resolveWorkItem(
        widget.workItemId,
        userProvider.currentUser!.id,
        notes,
      );

      await _loadWorkItem();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work item resolved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resolve: $e')),
        );
      }
    }
  }

  Future<void> _handleAddStandup() async {
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Standup Update'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'What\'s the update for standup?',
            ),
            maxLines: 4,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (text == null || text.trim().isEmpty) return;

    try {
      final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);
      await workItemsProvider.addStandupUpdate(widget.workItemId, text, null);
      await _loadWorkItem();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Standup update added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add standup: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_workItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Work Item')),
        body: const Center(child: Text('Work item not found')),
      );
    }

    final canEscalate = _workItem!.currentStage != 'resolved' &&
        _workItem!.currentStage != 'manager_escalation';
    final canResolve = _workItem!.currentStage != 'resolved';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Item Details'),
        actions: [
          if (_workItem!.currentStage != 'resolved')
            IconButton(
              icon: const Icon(Icons.add_comment),
              onPressed: _handleAddStandup,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _workItem!.currentStage == 'resolved'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _workItem!.currentStage.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _workItem!.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_workItem!.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _workItem!.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildInfoRow('POC', _workItem!.dependencyPoc),
                  if (_workItem!.pocEmail != null)
                    _buildInfoRow('Email', _workItem!.pocEmail!),
                  if (_workItem!.impact != null)
                    _buildInfoRow('Impact', _workItem!.impact!),
                  if (_workItem!.managerName != null)
                    _buildInfoRow('Manager', _workItem!.managerName!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (canEscalate || canResolve)
            Row(
              children: [
                if (canResolve)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleResolve,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (canEscalate && canResolve) const SizedBox(width: 8),
                if (canEscalate)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleEscalate,
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text('Escalate'),
                    ),
                  ),
              ],
            ),
          if (_workItem!.standups != null && _workItem!.standups!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standup Updates (${_workItem!.standups!.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._workItem!.standups!.map((standup) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, yyyy').format(DateTime.parse(standup.date)),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(standup.updateText),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
          if (_workItem!.history != null && _workItem!.history!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Escalation History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._workItem!.history!.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.actionTaken,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (entry.notes != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        entry.notes!,
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('MMM d, yyyy h:mm a').format(entry.timestamp),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
