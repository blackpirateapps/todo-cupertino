import 'package:flutter/cupertino.dart';

import '../models/task.dart';
import '../state/app_state.dart';
import '../utils/app_utils.dart';
import '../widgets/common_widgets.dart';
import 'list_detail_page.dart';
import 'list_editor_page.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key, required this.state, required this.onStartFocus});

  final AppState state;
  final void Function(Task task) onStartFocus;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Lists'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _openListEditor(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: state,
          builder: (context, _) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
              itemCount: state.lists.length,
              itemBuilder: (context, index) {
                final list = state.lists[index];
                final count = state.tasksForList(list.id).length;
                return SectionCard(
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colorForListKey(list.colorKey),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          list.icon,
                          color: CupertinoColors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          onPressed: () => Navigator.of(context).push(
                            CupertinoPageRoute<void>(
                              builder: (context) => ListDetailPage(
                                state: state,
                                list: list,
                                onStartFocus: onStartFocus,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count tasks',
                                style: const TextStyle(
                                  color: CupertinoColors.secondaryLabel,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size.square(28),
                        onPressed: () =>
                            _openListEditor(context, listId: list.id),
                        child: const Icon(CupertinoIcons.pencil, size: 18),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openListEditor(BuildContext context, {String? listId}) async {
    final initial = listId == null ? null : state.listById(listId);
    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) =>
            ListEditorPage(state: state, initialList: initial),
      ),
    );
  }
}
