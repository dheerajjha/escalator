import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/work_items_provider.dart';
import '../widgets/kanban_board.dart';
import 'create_work_item_screen.dart';
import 'work_item_detail_screen.dart';
import 'onboarding_screen.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
    _setupNotifications();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final workItemsProvider = Provider.of<WorkItemsProvider>(context, listen: false);

    if (userProvider.currentUser != null) {
      await workItemsProvider.loadWorkItems(userProvider.currentUser!.id);
    }
  }

  Future<void> _setupNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = await NotificationService.getToken();

    if (token != null && userProvider.currentUser != null) {
      await userProvider.updateFcmToken(token);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, WorkItemsProvider>(
      builder: (context, userProvider, workItemsProvider, _) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const OnboardingScreen();
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escalator', style: TextStyle(fontSize: 20)),
                Text(
                  'Welcome back, ${user.displayName}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
          ),
          body: workItemsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : workItemsProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(workItemsProvider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : KanbanBoard(
                      workItems: workItemsProvider.workItems,
                      onWorkItemTap: (workItem) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WorkItemDetailScreen(
                              workItemId: workItem.id,
                            ),
                          ),
                        ).then((_) => _loadData());
                      },
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateWorkItemScreen(userId: user.id),
                ),
              ).then((_) => _loadData());
            },
            icon: const Icon(Icons.add),
            label: const Text('New Work Item'),
          ),
        );
      },
    );
  }
}
