import 'package:flutter/material.dart';
import '../models/task.dart';

// Card widget to display an individual task with actions
class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  // Helper method to format date into readable format: "28 Sep 2026"
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDone
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      color: isDone
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
          : theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit, // Tapping the card opens the edit screen
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Checkbox and Task Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox to complete/uncomplete task
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: onToggleComplete,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Description (only shown if provided)
              if (task.description.trim().isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 12, bottom: 8),
                  child: Text(
                    task.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDone
                          ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                          : theme.colorScheme.onSurfaceVariant,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 4),

              // Bottom Row: Date and Action Buttons (Edit & Delete)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(
                  children: [
                    // Task Date
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(task.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),

                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Task',
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),

                    // Delete Button
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      tooltip: 'Delete Task',
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
