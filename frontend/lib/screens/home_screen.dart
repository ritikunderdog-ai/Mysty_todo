import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mysty/theme/cyberpunk_theme.dart';
import 'package:mysty/providers/task_provider.dart';
import 'package:mysty/providers/stats_provider.dart';
import 'package:mysty/providers/category_provider.dart';
import 'package:mysty/models/task.dart';
import 'package:mysty/widgets/task_card.dart';
import 'package:mysty/widgets/xp_bar.dart';
import 'package:mysty/screens/task_detail_screen.dart';
import 'package:mysty/screens/stats_screen.dart';
import 'package:mysty/screens/categories_screen.dart';

/// Main home screen with task list and bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final taskProvider = context.read<TaskProvider>();
    final statsProvider = context.read<StatsProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    await Future.wait([
      taskProvider.fetchTasks(),
      statsProvider.refreshAll(),
      categoryProvider.fetchCategories(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildTaskList(),
      const StatsScreen(),
      const CategoriesScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: CyberpunkColors.cardBorder.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt),
              label: 'TASKS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'STATS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.label_outline),
              label: 'LABELS',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: CyberpunkColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _openTaskDetail(context),
                child: const Icon(Icons.add, size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildTaskList() {
    return SafeArea(
      child: Column(
        children: [
          // Header with XP bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Consumer<StatsProvider>(
              builder: (context, stats, _) {
                if (stats.stats == null) {
                  return const SizedBox.shrink();
                }
                return XpBar(
                  currentXp: stats.stats!.xpForCurrentLevel,
                  xpForNext: stats.stats!.xpForNextLevel,
                  level: stats.stats!.level,
                  levelTitle: stats.stats!.levelTitle,
                  compact: true,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: CyberpunkColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search, color: CyberpunkColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: CyberpunkColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context.read<TaskProvider>().setSearchQuery(null);
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onChanged: (value) {
                context.read<TaskProvider>().setSearchQuery(
                      value.isEmpty ? null : value,
                    );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Active', false),
                _buildFilterChip('Done', true),
                const SizedBox(width: 8),
                _buildPriorityChip('HIGH', CyberpunkColors.priorityHigh),
                _buildPriorityChip('MEDIUM', CyberpunkColors.priorityMedium),
                _buildPriorityChip('LOW', CyberpunkColors.priorityLow),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Task list
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: CyberpunkColors.primary,
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: CyberpunkColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'DATABASE ERROR',
                          style: TextStyle(
                            color: CyberpunkColors.error,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Failed to load local database tasks',
                          style: TextStyle(
                            color: CyberpunkColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _loadData,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          color: CyberpunkColors.textSecondary.withValues(alpha: 0.3),
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'NO TASKS',
                          style: TextStyle(
                            color: CyberpunkColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap + to create your first task',
                          style: TextStyle(
                            color: CyberpunkColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: CyberpunkColors.primary,
                  backgroundColor: CyberpunkColors.surface,
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: provider.tasks.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final task = provider.tasks[index];
                      return TaskCard(
                        task: task,
                        onComplete: () => _completeTask(task.id),
                        onDelete: () => provider.deleteTask(task.id),
                        onTap: () => _openTaskDetail(context, task: task),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool? completed) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        // Determine if this is the active filter
        final bool isActive;
        if (label == 'All') {
          isActive = provider.searchQuery == null;
        } else {
          isActive = false; // Simplified
        }

        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () {
              if (label == 'All') {
                provider.setCompletedFilter(null);
              } else {
                provider.setCompletedFilter(completed);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? CyberpunkColors.primary.withValues(alpha: 0.15)
                    : CyberpunkColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? CyberpunkColors.primary.withValues(alpha: 0.5)
                      : CyberpunkColors.cardBorder,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? CyberpunkColors.primary
                      : CyberpunkColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityChip(String priority, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          context.read<TaskProvider>().setPriorityFilter(priority);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            priority,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _completeTask(int taskId) async {
    final result =
        await context.read<TaskProvider>().completeTask(taskId);
    if (!mounted) return;
    if (result != null) {
      context.read<StatsProvider>().refreshAll();
      _showXpPopup(result);
    }
  }

  void _showXpPopup(TaskCompleteResult result) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CyberpunkColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CyberpunkColors.primary, width: 1),
            boxShadow: [
              BoxShadow(
                color: CyberpunkColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: CyberpunkColors.accent,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'TASK COMPLETE!',
                style: TextStyle(
                  color: CyberpunkColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '+${result.xpEarned} XP',
                style: const TextStyle(
                  color: CyberpunkColors.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (result.streakBonus > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '(includes +${result.streakBonus} streak bonus)',
                  style: const TextStyle(
                    color: CyberpunkColors.streakFire,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: CyberpunkColors.streakFire, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${result.currentStreak} day streak',
                    style: const TextStyle(
                      color: CyberpunkColors.streakFire,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'LV.${result.level} ${result.levelTitle.toUpperCase()}',
                style: const TextStyle(
                  color: CyberpunkColors.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: CyberpunkColors.primary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTaskDetail(BuildContext context, {Task? task}) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (context) => TaskDetailScreen(task: task),
        ))
        .then((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
