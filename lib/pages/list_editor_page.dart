import 'package:flutter/cupertino.dart';

import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';

class ListEditorPage extends StatefulWidget {
  const ListEditorPage({super.key, required this.state, this.initialList});

  final AppState state;
  final TodoList? initialList;

  @override
  State<ListEditorPage> createState() => _ListEditorPageState();
}

class _ListEditorPageState extends State<ListEditorPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _iconKey = 'folder_fill';
  String _colorKey = 'blue';

  bool get _isEditing => widget.initialList != null;

  @override
  void initState() {
    super.initState();
    final list = widget.initialList;
    if (list != null) {
      _nameController.text = list.name;
      _descriptionController.text = list.description;
      _iconKey = list.iconKey;
      _colorKey = list.colorKey;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit List' : 'New List'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: Text(_isEditing ? 'Save' : 'Create'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoTextField(
              controller: _nameController,
              placeholder: 'List name',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: 'Description',
              minLines: 3,
              maxLines: 5,
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 14),
            const Text(
              'Choose Icon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final entry in kListIconMap.entries)
                  GestureDetector(
                    onTap: () => setState(() => _iconKey = entry.key),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _iconKey == entry.key
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        entry.value,
                        color: _iconKey == entry.key
                            ? CupertinoColors.white
                            : CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'List Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final entry in kListColorMap.entries)
                  GestureDetector(
                    onTap: () => setState(() => _colorKey = entry.key),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorKey == entry.key
                              ? CupertinoColors.label.resolveFrom(context)
                              : const Color(0x00000000),
                          width: 2,
                        ),
                      ),
                      child: _colorKey == entry.key
                          ? const Icon(
                              CupertinoIcons.check_mark,
                              color: CupertinoColors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: _delete,
                child: const Text(
                  'Delete List',
                  style: TextStyle(color: CupertinoColors.systemRed),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    final existing = widget.initialList;
    if (existing == null) {
      await widget.state.addList(
        TodoList(
          id: generateId(),
          name: name,
          description: _descriptionController.text.trim(),
          iconKey: _iconKey,
          colorKey: _colorKey,
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await widget.state.updateList(
        existing.copyWith(
          name: name,
          description: _descriptionController.text.trim(),
          iconKey: _iconKey,
          colorKey: _colorKey,
          updatedAt: now,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.initialList;
    if (existing == null) return;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete list?'),
        content: const Text(
          'Tasks in this list will be moved to another list.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.state.deleteList(existing.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
