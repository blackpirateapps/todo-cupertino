# todo-cupertino

Cupertino-themed todo list app for Android (Flutter UI using only Cupertino widgets, no Material theme).

## Features

- Home page (all tasks)
- Today page (tasks due today)
- Projects page (grouped by project)
- Settings page (dark mode toggle)
- Task fields: title, due date, description, subtasks, tags, project
- Local-only persistence via `shared_preferences` (JSON)

## Notes

- This repository intentionally avoids local build/test execution in this environment.
- The GitHub Actions workflow generates the Android platform wrapper with `flutter create --platforms=android .` before running analysis and building the APK.

