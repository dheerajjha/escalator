import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/work_items_provider.dart';

class CreateWorkItemScreen extends StatefulWidget {
  final int userId;

  const CreateWorkItemScreen({super.key, required this.userId});

  @override
  State<CreateWorkItemScreen> createState() => _CreateWorkItemScreenState();
}

class _CreateWorkItemScreenState extends State<CreateWorkItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pocController = TextEditingController();
  final _pocEmailController = TextEditingController();
  final _impactController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pocController.dispose();
    _pocEmailController.dispose();
    _impactController.dispose();
    _managerNameController.dispose();
    _managerEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);

      await workItemsProvider.createWorkItem({
        'userId': widget.userId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dependencyPoc': _pocController.text.trim(),
        'pocEmail': _pocEmailController.text.trim(),
        'impact': _impactController.text.trim(),
        'managerName': _managerNameController.text.trim(),
        'managerEmail': _managerEmailController.text.trim(),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create work item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Work Item'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Brief description of the work',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              enabled: !_isLoading,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Detailed description of what needs to be done',
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pocController,
              decoration: const InputDecoration(
                labelText: 'Dependency POC *',
                hintText: 'Person you\'re waiting on (e.g., Mudit)',
                helperText: 'The person whose response you\'re waiting for',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Dependency POC is required';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pocEmailController,
              decoration: const InputDecoration(
                labelText: 'POC Email',
                hintText: 'poc@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _impactController,
              decoration: const InputDecoration(
                labelText: 'Impact',
                hintText: 'What\'s the impact of this delay?',
              ),
              maxLines: 2,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managerNameController,
              decoration: const InputDecoration(
                labelText: 'Manager Name',
                hintText: 'For escalation if needed',
              ),
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _managerEmailController,
              decoration: const InputDecoration(
                labelText: 'Manager Email',
                hintText: 'manager@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Work Item'),
            ),
          ],
        ),
      ),
    );
  }
}
