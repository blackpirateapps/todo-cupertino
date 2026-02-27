# todo-cupertino

Cupertino-themed todo list app for Android (Flutter UI using only Cupertino widgets, no Material theme).

## Features

- Today dashboard (search, upcoming, and home list strip)
- All tasks page (expandable rows with subtasks/details)
- Lists page (create/edit/delete lists, open list detail)
- Focus page (choose task, per-task focus duration, timer)
- Stats page (interactive charts)
- Settings page (dark mode + pomodoro defaults)
- Task fields: title, due date, description, subtasks, tags, list, priority
- Local-only persistence via `shared_preferences` (JSON)

## Notes

- This repository intentionally avoids local build/test execution in this environment.
- The GitHub Actions workflow generates the Android platform wrapper with `flutter create --platforms=android .` before running analysis and building the APK.
