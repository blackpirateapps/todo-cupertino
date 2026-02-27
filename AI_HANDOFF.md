# AI Handoff: todo-cupertino

## Current Product State
- Flutter Cupertino todo app.
- Local-only persistence (`SharedPreferences`).
- Home dashboard visually matches iOS-inspired screenshot and is now functional.
- Tasks are organized by user-defined lists.

## Core Features Implemented
- List management:
  - Create list with name, description, icon.
  - List tiles shown in Home > My Lists.
  - Tap list tile opens list detail page.
- Task management:
  - Create/edit/delete tasks.
  - Tasks include due date, repeat, list, priority, subtasks, notes, completed status.
  - Completed tasks are shown with distinct styling (line-through/reduced emphasis).
- Home behavior:
  - Today section shows due-today tasks across all lists.
  - If due-today count > 3, Home prioritizes high-priority tasks for display.
  - My Lists `+` now creates a new list (not a task).
- Quick add:
  - Floating large `+` at bottom-right across all tabs.
  - Opens quick add popup with title + due date + list only.
- Navigation tabs:
  - Today, Scheduled, All, Flagged, Settings.
- Flagged tab:
  - Shows high-priority tasks as flagged proxy.

## Data Model

### Task (`lib/models/task.dart`)
- `id: String`
- `title: String`
- `description: String` (notes)
- `dueDate: DateTime?`
- `repeat: TaskRepeat` (`none`, `daily`, `weekly`, `monthly`)
- `listId: String`
- `priority: TaskPriority` (`low`, `medium`, `high`)
- `subtasks: List<Subtask>`
- `tags: List<String>` (kept for backward compatibility, not primary UI)
- `isCompleted: bool`
- `createdAt: DateTime`
- `updatedAt: DateTime`

### TodoList (`lib/models/todo_list.dart`)
- `id: String`
- `name: String`
- `description: String`
- `iconKey: String` (mapped to Cupertino icon)
- `createdAt: DateTime`
- `updatedAt: DateTime`

## Persistence Keys
- `tasks_v2`
- `lists_v1`
- `dark_mode_v1`
- Legacy read/migrate: `tasks_v1`

## Migration Behavior
Implemented in `lib/state/app_state.dart`:
- Loads legacy tasks (`tasks_v1`) when `tasks_v2` missing.
- Legacy `project` field in tasks is mapped into list IDs via marker `__legacy_project__...`.
- Missing lists are auto-created from legacy project names.
- Default lists auto-created if no lists exist.
- Migrated data saved to new keys.

## Important Business Rules
- Task sorting:
  - Incomplete before complete.
  - Higher priority first.
  - Due-dated tasks before undated.
  - Earlier due date first.
  - Newer update time tie-breaker.
- Home Today display:
  - Base set = all tasks due today.
  - If base set size > 3, prefer high-priority subset.
  - UI shows max 3 tasks in Today card.

## File Structure
- `lib/main.dart` - bootstrap
- `lib/app.dart` - app + tab shell + global quick-add overlay wrapping tab pages
- `lib/state/app_state.dart` - state, storage, sorting, migration
- `lib/models/task.dart` - task/subtask + enums
- `lib/models/todo_list.dart` - list model
- `lib/utils/app_utils.dart` - IDs, date formatting, icon map
- `lib/pages/home_page.dart` - functional dashboard
- `lib/pages/list_detail_page.dart` - per-list task view
- `lib/pages/list_editor_page.dart` - list creation
- `lib/pages/task_editor_page.dart` - screenshot-style task create/edit
- `lib/pages/all_tasks_page.dart`
- `lib/pages/scheduled_page.dart`
- `lib/pages/flagged_page.dart`
- `lib/pages/settings_page.dart`
- `lib/widgets/task_card.dart` - task rendering (includes list + priority pills)
- `lib/widgets/quick_add_overlay.dart` - global floating quick-add button + popup
- `lib/widgets/common_widgets.dart` - shared UI primitives

## Known Gaps
- Home search bar is visual only (no filtering behavior).
- Flagged behavior uses high-priority proxy instead of explicit flagged boolean.
- No automated Flutter/widget tests for new list/quick-add flows.

## Environment Validation Notes
- `dart format lib test` ran successfully in sandbox.
- Full `flutter analyze` / `flutter test` could not be run here because Flutter SDK is unavailable in this sandbox.
