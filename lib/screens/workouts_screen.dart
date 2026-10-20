import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../providers/workout_provider.dart';
import '../theme/app_theme.dart';
import 'workout_form_screen.dart';
import 'workout_details_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().loadData();
    });
  }

  Future<void> _addWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutFormScreen()),
    );

    if (mounted) {
      await context.read<WorkoutProvider>().loadData();
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Workout?'),
          content: Text('Are you sure you want to delete "${workout.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    await context.read<WorkoutProvider>().deleteWorkout(workout.id);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout deleted')));
  }

  List<Workout> _filteredWorkouts(List<Workout> workouts) {
    if (_search.trim().isEmpty) {
      return workouts;
    }

    final query = _search.toLowerCase();

    return workouts.where((workout) {
      return workout.name.toLowerCase().contains(query) ||
          workout.notes.toLowerCase().contains(query);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWorkout,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Workout'),
      ),
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            final workouts = _filteredWorkouts(provider.workouts);

            return RefreshIndicator(
              onRefresh: provider.loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ==========================================
                  // HEADER
                  // ==========================================
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workouts',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Your complete workout history.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(.65),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // SEARCH
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _search = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search workouts...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _search.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _search = '';
                                        });
                                      },
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // SUMMARY
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.fitness_center,
                                  title: 'Total',
                                  value: '${provider.workouts.length}',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  icon: Icons.calendar_today_rounded,
                                  title: 'This Month',
                                  value:
                                      '${_thisMonthCount(provider.workouts)}',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          Text(
                            _search.isEmpty ? 'All Workouts' : 'Search Results',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // LOADING
                  // ==========================================
                  if (provider.isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // ==========================================
                  // EMPTY
                  // ==========================================
                  else if (workouts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyWorkouts(
                        searchActive: _search.isNotEmpty,
                        onAddWorkout: _addWorkout,
                      ),
                    )
                  // ==========================================
                  // WORKOUT LIST
                  // ==========================================
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final workout = workouts[index];

                          return _WorkoutCard(
                            workout: workout,
                            dateText: _formatDate(workout.date),
                            onDelete: () => _deleteWorkout(workout),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutDetailsScreen(workout: workout),
                                ),
                              );
                            },
                          );
                        }, childCount: workouts.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  int _thisMonthCount(List<Workout> workouts) {
    final now = DateTime.now();

    return workouts.where((workout) {
      return workout.date.year == now.year && workout.date.month == now.month;
    }).length;
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WORKOUT CARD
// ============================================================

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  final String dateText;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.dateText,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(.05) : theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withOpacity(.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                // ICON
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 15),

                // INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(.6),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(.6),
                            ),
                          ),

                          if (workout.duration > 0) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${workout.duration} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(.6),
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (workout.notes.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          workout.notes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),

                // MENU
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.more_vert_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY WORKOUTS
// ============================================================

class _EmptyWorkouts extends StatelessWidget {
  final bool searchActive;
  final VoidCallback onAddWorkout;

  const _EmptyWorkouts({
    required this.searchActive,
    required this.onAddWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                size: 42,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              searchActive ? 'No workouts found' : 'No workouts yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchActive
                  ? 'Try a different search.'
                  : 'Start tracking your workouts today.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(.65),
              ),
            ),
            if (!searchActive) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onAddWorkout,
                icon: const Icon(Icons.add),
                label: const Text('Add Workout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
