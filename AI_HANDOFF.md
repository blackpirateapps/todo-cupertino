# AI Handoff: todo-cupertino

## Current Scope
- Cupertino Flutter todo app with local persistence.
- Functional lists + tasks + focus timer (Pomodoro).
- Home/dashboard and all major task pages are interactive.

## Major Features
- List management
  - Create lists with name, description, icon.
  - Create lists with predefined color selection.
  - Dedicated `Lists` tab supports opening, editing, and deleting lists.
  - Deleting a list reassigns its tasks to another existing list.
  - List tiles on Home open list detail pages.
- Task management
  - Create/edit/delete tasks.
  - Fields: due date, repeat, list, priority, subtasks, notes, completed.
  - Task editor supports rapid subtask entry (`Add Subtask` focuses input; Enter creates next).
  - Priority is color-coded in task editing surfaces.
  - Tasks store per-task focus session minutes and accumulated focus runtime minutes.
  - Focus runtime is shown as a pill in All, Today, and list detail task surfaces.
- Home behavior
  - Today card aggregates tasks due today across all lists.
  - If due-today count > 3, home prioritizes high-priority tasks for display.
  - Home search opens a dedicated Today-search page with real task results.
  - Upcoming tasks can be marked completed directly from Home.
- Focus/Pomodoro
  - Dedicated `Focus` tab with timer UI.
  - Current focus task is selected from a full-page searchable picker.
  - Per-task focus length is adjustable from 0 to 500 minutes via picker.
  - Play icons on task rows launch Focus tab and start session on that task.
  - Focus and break default durations configurable in Settings.
  - Running focus minutes are accumulated into the focused task.
  - Live ongoing Android notification is posted while timer is running (via `flutter_local_notifications`).
  - App-wide floating quick-add button shows a running indicator while focus timer is active.
- All Tasks behavior
  - Tapping a task row expands/collapses inline details (description, subtasks, metadata).
  - Expanded subtasks can be toggled directly.
- Analytics
  - Dedicated `Stats` tab with interactive charts for:
    - tasks completed per day
    - list-wise focus-minute totals
- Quick add
  - Floating plus button across tabs opens quick-add popup.
  - Quick add supports title + due date + list.

## Navigation
- Tabs:
  - Today
  - All
  - Lists
  - Focus
  - Stats
  - Settings

## Key Files
- `lib/app.dart`
  - App shell, tab controller, start-focus routing from task play buttons.
- `lib/state/app_state.dart`
  - Core state, persistence, list/task operations, focus config.
  - Stores pomodoro defaults and focus start signals.
- `lib/pages/focus_page.dart`
  - Pomodoro timer page with per-task duration picker and live notification updates.
- `lib/pages/focus_task_picker_page.dart`
  - Searchable full-page focus task chooser.
- `lib/pages/all_tasks_page.dart`
  - Redesigned tasks screen with segmented filters + search + expandable task rows + play icon.
- `lib/pages/home_page.dart`
  - Dashboard with functional Today/My Lists/Upcoming + launch-to-search + play icons.
- `lib/pages/today_search_page.dart`
  - Dedicated search UI for tasks due today.
- `lib/pages/lists_page.dart`
  - Full list manager tab with open/edit/delete flows.
- `lib/pages/stats_page.dart`
  - Interactive charts for daily completed tasks and focus minutes by list.
- `lib/pages/list_detail_page.dart`
  - Per-list task list with create/edit and play icon.
- `lib/pages/list_editor_page.dart`
  - List creation (name/description/icon/color).
- `lib/pages/task_editor_page.dart`
  - Full-page task create/edit with aligned setting values, checkbox completed state, and rapid subtask entry.
- `lib/widgets/task_card.dart`
  - Shared task card used in list detail; includes play icon and focus-minutes pill.
- `lib/pages/settings_page.dart`
  - Dark mode + focus/break duration controls.
- `lib/services/focus_notification_service.dart`
  - Android ongoing notification abstraction for live focus timer status.

## Data Model

### Task (`lib/models/task.dart`)
- `id`, `title`, `description`, `dueDate`, `repeat`, `listId`, `priority`, `subtasks`, `tags`, `isCompleted`, `focusDurationMinutes`, `focusAccumulatedMinutes`, `createdAt`, `updatedAt`

### TodoList (`lib/models/todo_list.dart`)
- `id`, `name`, `description`, `iconKey`, `colorKey`, `createdAt`, `updatedAt`

## Persistence Keys
- Tasks: `tasks_v2` (legacy fallback/migration from `tasks_v1`)
- Lists: `lists_v1`
- Dark mode: `dark_mode_v1`
- Pomodoro focus length: `pomodoro_minutes_v1`
- Pomodoro break length: `pomodoro_break_minutes_v1`

## Known Gaps
- No automated widget tests for focus timer/task-play flows yet.

## Validation Notes
- `dart format` ran successfully in sandbox.
- `flutter analyze` / `flutter test` could not be run in this sandbox because Flutter SDK is unavailable.
