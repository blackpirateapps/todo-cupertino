# AI Handoff: todo-cupertino

## Current Scope
- Cupertino Flutter todo app with local persistence.
- Functional lists + tasks + focus timer (Pomodoro).
- Home/dashboard and all major task pages are interactive.

## Major Features
- List management
  - Create lists with name, description, icon.
  - Create lists with predefined color selection.
  - List tiles on Home open list detail pages.
- Task management
  - Create/edit/delete tasks.
  - Fields: due date, repeat, list, priority, subtasks, notes, completed.
  - Task editor supports rapid subtask entry (`Add Subtask` focuses input; Enter creates next).
  - Priority is color-coded in task editing surfaces.
- Home behavior
  - Today card aggregates tasks due today across all lists.
  - If due-today count > 3, home prioritizes high-priority tasks for display.
  - Home search is functional (filters Today and Upcoming sections).
  - Upcoming tasks can be marked completed directly from Home.
- Focus/Pomodoro
  - Dedicated `Focus` tab with timer UI.
  - Current focus task can be selected in focus page.
  - Play icons on task rows launch Focus tab and start session on that task.
  - Focus and break default durations configurable in Settings.
- Quick add
  - Floating plus button across tabs opens quick-add popup.
  - Quick add supports title + due date + list.

## Navigation
- Tabs:
  - Today
  - Scheduled
  - All
  - Flagged
  - Focus
  - Settings

## Key Files
- `lib/app.dart`
  - App shell, tab controller, start-focus routing from task play buttons.
- `lib/state/app_state.dart`
  - Core state, persistence, list/task operations, focus config.
  - Stores pomodoro defaults and focus start signals.
- `lib/pages/focus_page.dart`
  - Pomodoro timer page.
- `lib/pages/all_tasks_page.dart`
  - Redesigned tasks screen with segmented filters + search + play icon.
- `lib/pages/home_page.dart`
  - Dashboard with functional Today/My Lists/Upcoming + search + play icons.
- `lib/pages/list_detail_page.dart`
  - Per-list task list with create/edit and play icon.
- `lib/pages/list_editor_page.dart`
  - List creation (name/description/icon/color).
- `lib/pages/task_editor_page.dart`
  - Full-page task create/edit with aligned setting values, checkbox completed state, and rapid subtask entry.
- `lib/widgets/task_card.dart`
  - Shared task card used in scheduled/flagged/list detail; includes play icon.
- `lib/pages/settings_page.dart`
  - Dark mode + focus/break duration controls.

## Data Model

### Task (`lib/models/task.dart`)
- `id`, `title`, `description`, `dueDate`, `repeat`, `listId`, `priority`, `subtasks`, `tags`, `isCompleted`, `createdAt`, `updatedAt`

### TodoList (`lib/models/todo_list.dart`)
- `id`, `name`, `description`, `iconKey`, `colorKey`, `createdAt`, `updatedAt`

## Persistence Keys
- Tasks: `tasks_v2` (legacy fallback/migration from `tasks_v1`)
- Lists: `lists_v1`
- Dark mode: `dark_mode_v1`
- Pomodoro focus length: `pomodoro_minutes_v1`
- Pomodoro break length: `pomodoro_break_minutes_v1`

## Known Gaps
- `Flagged` tab maps to high-priority tasks (no separate flagged boolean yet).
- No automated widget tests for focus timer/task-play flows yet.

## Validation Notes
- `dart format` ran successfully in sandbox.
- `flutter analyze` / `flutter test` could not be run in this sandbox because Flutter SDK is unavailable.
