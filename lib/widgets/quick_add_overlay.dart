import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';

class QuickAddOverlay extends StatelessWidget {
  const QuickAddOverlay({super.key, required this.state, required this.child});

  final AppState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(
              right: 18,
              bottom: 86,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _openQuickAdd(context),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 16,
                            color: Color(0x40000000),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  if (state.focusRunning)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoColors.systemBackground.resolveFrom(
                              context,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openQuickAdd(BuildContext context) async {
    final created = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => _QuickAddSheet(state: state),
    );

    if (created == true && context.mounted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Task Added'),
          content: const Text('Your task was created from quick add.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet({required this.state});

  final AppState state;

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  late String _listId;

  @override
  void initState() {
    super.initState();
    _listId = widget.state.lists.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.state.listById(_listId);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Add Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Task title',
                      padding: const EdgeInsets.all(12),
                    ),
                    const SizedBox(height: 8),
                    _row(
                      context,
                      label: 'Due date',
                      value: _dueDate == null
                          ? 'None'
                          : formatDateTime(_dueDate!),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 6),
                    _row(
                      context,
                      label: 'List',
                      value: list?.name ?? 'Unknown',
                      onTap: _pickList,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            color: CupertinoColors.systemGrey5,
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: _save,
                            child: const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
        context,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: CupertinoColors.label)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CupertinoColors.secondaryLabel),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(CupertinoIcons.chevron_forward, size: 14),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? DateTime(now.year, now.month, now.day, 10);
    var selected = initial;
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(selected),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: initial,
                onDateTimeChanged: (value) => selected = value,
              ),
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickList() async {
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose List'),
        actions: [
          for (final list in widget.state.lists)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(list.id),
              child: Text(list.name),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _listId = selected);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    await widget.state.addTask(
      Task(
        id: generateId(),
        title: title,
        description: '',
        dueDate: _dueDate,
        repeat: TaskRepeat.none,
        listId: _listId,
        priority: TaskPriority.medium,
        subtasks: const [],
        tags: const [],
        isCompleted: false,
        focusDurationMinutes: widget.state.pomodoroMinutes,
        focusAccumulatedMinutes: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}
