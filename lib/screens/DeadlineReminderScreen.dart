import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/taskProvider.dart';

class DeadlineReminderScreen extends StatefulWidget {
  const DeadlineReminderScreen({Key? key}) : super(key: key);

  @override
  _DeadlineReminderScreenState createState() => _DeadlineReminderScreenState();
}

class _DeadlineReminderScreenState extends State<DeadlineReminderScreen> {
  final Color primaryBlue = const Color(0xFF2864A6);
  int? _selectedTaskIndex;

 
  DateTime? _parseDueDate(String dueDate) {
    try {
      // Try ISO format: 2025-04-25
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dueDate)) {
        return DateTime.parse(dueDate);
      }
      // Try dd/MM/yyyy
      final parts = dueDate.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  
  Map<String, dynamic> _getRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDay = DateTime(deadline.year, deadline.month, deadline.day);
    final diff = deadlineDay.difference(today);

    if (diff.isNegative) {
      return {
        'days': diff.inDays.abs(),
        'hours': diff.inHours.abs() % 24,
        'status': 'overdue',
      };
    } else if (diff.inDays == 0) {
      final hourDiff = deadline.difference(now);
      return {
        'days': 0,
        'hours': hourDiff.inHours.clamp(0, 24),
        'status': 'today',
      };
    } else {
      return {
        'days': diff.inDays,
        'hours': diff.inHours % 24,
        'status': 'upcoming',
      };
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'overdue':
        return Colors.redAccent;
      case 'today':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'overdue':
        return Icons.warning_amber_rounded;
      case 'today':
        return Icons.access_time_filled;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'overdue':
        return 'OVERDUE';
      case 'today':
        return 'DUE TODAY';
      default:
        return 'UPCOMING';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Deadline Reminder',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryBlue));
          }

          final tasks = taskProvider.tasks;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Create one to get started!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section header ──────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Select a task to view its deadline',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),

                // ── Task selector list ───────────────────────────────────
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isSelected = _selectedTaskIndex == index;
                    final deadline = _parseDueDate(task.dueDate);

                    // Inline urgency badge on the list tile
                    String? badgeLabel;
                    Color? badgeColor;
                    if (deadline != null) {
                      final info = _getRemainingTime(deadline);
                      badgeColor = _statusColor(info['status']);
                      if (info['status'] == 'overdue') {
                        badgeLabel = 'Overdue';
                      } else if (info['status'] == 'today') {
                        badgeLabel = 'Today';
                      } else if (info['days'] <= 3) {
                        badgeLabel = '${info['days']}d left';
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTaskIndex =
                              isSelected ? null : index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryBlue.withOpacity(0.08)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? primaryBlue
                                : Colors.grey.shade400,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4.0),
                          leading: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                isSelected ? primaryBlue : Colors.grey,
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: task.isCompleted == 1
                                  ? Colors.grey
                                  : Colors.black,
                              decoration: task.isCompleted == 1
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Due: ${task.dueDate}  •  ${task.priority}',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: badgeLabel != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor!.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: badgeColor, width: 1),
                                  ),
                                  child: Text(
                                    badgeLabel,
                                    style: TextStyle(
                                      color: badgeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),

             
                if (_selectedTaskIndex != null) ...[
                  const SizedBox(height: 8),
                  _buildDeadlineCard(tasks[_selectedTaskIndex!]),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeadlineCard(dynamic task) {
    final deadline = _parseDueDate(task.dueDate);
    final today = DateTime.now();
    final todayStr = _formatDate(today);

    if (deadline == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Could not parse the due date format.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final info = _getRemainingTime(deadline);
    final String status = info['status'];
    final int days = info['days'];
    final int hours = info['hours'];
    final Color color = _statusColor(status);
    final IconData icon = _statusIcon(status);
    final String label = _statusLabel(status);

    String remainingText;
    if (status == 'overdue') {
      remainingText = days > 0
          ? '$days day${days != 1 ? 's' : ''} ago'
          : '$hours hour${hours != 1 ? 's' : ''} ago';
    } else if (status == 'today') {
      remainingText = hours > 0
          ? '$hours hour${hours != 1 ? 's' : ''} remaining'
          : 'Due now!';
    } else {
      remainingText = days > 0
          ? '$days day${days != 1 ? 's' : ''} remaining'
          : '$hours hour${hours != 1 ? 's' : ''} remaining';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Coloured header band ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                // Completed chip
                if (task.isCompleted == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Task title
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Three info rows
                _infoRow(
                  icon: Icons.event,
                  iconColor: primaryBlue,
                  label: 'Task Deadline',
                  value: _formatDate(deadline),
                ),
                const Divider(height: 20),
                _infoRow(
                  icon: Icons.today,
                  iconColor: Colors.grey,
                  label: 'Today',
                  value: todayStr,
                ),
                const Divider(height: 20),
                _infoRow(
                  icon: Icons.hourglass_bottom_rounded,
                  iconColor: color,
                  label: status == 'overdue' ? 'Overdue By' : 'Time Remaining',
                  value: remainingText,
                  valueColor: color,
                  valueBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    valueBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}