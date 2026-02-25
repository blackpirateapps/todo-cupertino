# AI Handoff: todo-cupertino

## Project Summary
- Flutter app using Cupertino UI.
- Local-first todo list app (no backend).
- Data persistence uses `shared_preferences` (JSON serialized tasks + dark mode flag).
- User request in this phase: match screenshot look for the homepage and update bottom navbar.

## Current Status (as of this handoff)
- Homepage redesigned to closely match the provided iPhone screenshot style.
- Bottom navbar updated to 5 tabs to match screenshot labels:
  - `Today`
  - `Scheduled`
  - `All`
  - `Flagged`
  - `Settings`
- Codebase refactored from a single `lib/main.dart` into multiple files for maintainability.
- Existing task CRUD/local storage features preserved.
- `Flagged` tab is a placeholder UI only (flagging feature not implemented).

## Implemented Features (App-wide)
- Local task storage (`SharedPreferences`)
- Create task
- Edit task
- Delete task
- Mark task complete/incomplete
- Add/edit/remove subtasks
- Toggle subtask completion
- Due date picker (date + time)
- Project/category field per task (string)
- Tags (comma-separated)
- Dark mode toggle (stored locally)
- Task lists:
  - All tasks
  - Scheduled (tasks with due dates)
  - Dashboard-style Today home screen

## Homepage Redesign (Screenshot-inspired)
Implemented in `lib/pages/home_page.dart`.

### Sections
- Top header with:
  - "To-Do" title
  - current date subtitle
  - avatar button (opens task editor currently)
  - search icon (visual only)
- Search bar row (visual only)
- `Today` card:
  - circular progress ring
  - completed/total summary
  - 3 compact tasks with optional time badges
  - uses real today tasks if available; otherwise shows screenshot-like fallback sample rows
- `My Lists` row:
  - Personal / Work / Groceries tiles + add tile
  - counts use project-based real data when matching those names; otherwise fallback sample counts
- `Upcoming` section:
  - grouped rows by date label / Tomorrow
  - uses real dated tasks (excluding today) if available
  - fallback sample rows when no upcoming tasks exist

### Important UX Notes
- Homepage is primarily a dashboard view, not the previous full task list.
- To add tasks from the homepage, avatar/add tile opens the task editor.
- The screenshot search/mic UI is visual only right now.

## File Structure (Refactored)
- `lib/main.dart` - app entrypoint and initial state load
- `lib/app.dart` - `CupertinoApp` + tab shell/navbar
- `lib/models/task.dart` - `Task` and `Subtask` models + JSON serialization
- `lib/state/app_state.dart` - local app state, sorting, persistence, mutations
- `lib/utils/app_utils.dart` - ID generation + date/time formatting helpers
- `lib/widgets/common_widgets.dart` - shared UI primitives (`SectionCard`, `EmptyState`, `FieldLabel`, `Pill`)
- `lib/widgets/task_card.dart` - reusable task card used by list pages
- `lib/pages/home_page.dart` - screenshot-style homepage dashboard
- `lib/pages/all_tasks_page.dart` - full task list + add button
- `lib/pages/scheduled_page.dart` - tasks with due dates
- `lib/pages/flagged_page.dart` - placeholder
- `lib/pages/settings_page.dart` - dark mode + storage info
- `lib/pages/task_editor_page.dart` - create/edit/delete task form

## Data Model
### `Task`
Fields in `lib/models/task.dart`:
- `id: String`
- `title: String`
- `description: String`
- `dueDate: DateTime?`
- `subtasks: List<Subtask>`
- `tags: List<String>`
- `project: String?`
- `isCompleted: bool`
- `createdAt: DateTime`
- `updatedAt: DateTime`

### `Subtask`
- `id: String`
- `title: String`
- `isCompleted: bool`

## Persistence Details
In `lib/state/app_state.dart`:
- `tasks_v1` -> JSON array of tasks
- `dark_mode_v1` -> bool

## Sorting / Filtering Rules
- `sortedTasks()`
  - incomplete before completed
  - tasks with due date before no due date
  - earlier due date first
  - then newest `updatedAt` first
- `tasksDueToday()` -> due date matches current day
- `tasksWithDueDate()` -> any non-null due date
- `tasksByProject()` -> grouped by project, falls back to `No Project`

## What Was Changed From Original App
- Original tabs were `Home`, `Today`, `Projects`, `Settings`
- New tabs now mirror screenshot nav labels and order
- Original homepage was full task list
- New homepage is a dashboard-style landing page matching screenshot layout
- Code moved from one file into modular structure for easier future development

## Known Gaps / Next Steps
- Exact screenshot parity is approximate (no photo/avatar asset, no custom typography/assets)
- `Flagged` feature is not implemented (UI placeholder only)
- Search bar/mic and top-right search icon are non-functional
- `My Lists` tiles are dashboard summaries only; tapping them does not navigate yet
- Home dashboard fallback sample content is mixed with real-data rendering intentionally for screenshot fidelity when task data is sparse
- No widget/golden tests yet for the redesigned homepage

## Recommended Next Work for Future AI Agents
1. Implement `flagged` field on `Task` + UI controls + actual Flagged tab behavior.
2. Make homepage tiles and rows navigable (e.g., filtered list routes).
3. Replace placeholder avatar with real asset/user profile state.
4. Add search functionality across tasks.
5. Add tests for `AppState` sorting/filtering and JSON serialization.
6. Add widget tests/golden tests for the home dashboard.
7. Consider moving home dashboard view models (`_HomeDashboardSnapshot` etc.) into separate files if the page grows further.

## Validation Notes
- `dart format lib` was run successfully with `HOME=/tmp` in sandbox.
- `flutter analyze` could not be run in this environment because `flutter` is not installed in the sandbox.
