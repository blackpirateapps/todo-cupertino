import 'package:flutter/cupertino.dart';

import '../models/todo_list.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';

class ListEditorPage extends StatefulWidget {
  const ListEditorPage({super.key, required this.state});

  final AppState state;

  @override
  State<ListEditorPage> createState() => _ListEditorPageState();
}

class _ListEditorPageState extends State<ListEditorPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _iconKey = 'folder_fill';

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
        middle: const Text('New List'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: const Text('Create'),
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
                            : CupertinoColors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final now = DateTime.now();
    await widget.state.addList(
      TodoList(
        id: generateId(),
        name: name,
        description: _descriptionController.text.trim(),
        iconKey: _iconKey,
        createdAt: now,
        updatedAt: now,
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
