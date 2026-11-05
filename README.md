# OtakuPlanner

A Flutter productivity planner for anime fans: schedule tasks on a calendar, set up recurring tasks by typing them in plain English, and stay on track with reminders and achievements.

<p>
  <img src="docs/screenshots/login.webp" width="200" alt="Login screen with the OtakuPlanner logo and email/password form" />
  <img src="docs/screenshots/dashboard.webp" width="200" alt="Dashboard with a daily quote, streak card and today's tasks filtered by time of day" />
  <img src="docs/screenshots/tasks.webp" width="200" alt="My Tasks list with search and category filters" />
  <img src="docs/screenshots/task-automation.webp" width="200" alt="Task Automation parsing a plain-English recurring task into day, time and category" />
  <img src="docs/screenshots/achievements.webp" width="200" alt="Achievements screen with level, filters and progress bars" />
</p>

<sub>Login · Dashboard · Tasks · Natural-language task automation · Achievements</sub>

## Features

- **Account and session handling.** Sign up and log in against the OtakuPlanner REST API. The JWT is stored locally with Hive, so returning users skip straight to the dashboard from the splash screen, and an expired session (HTTP 401) sends the user back to login.
- **Dashboard.** A personalized greeting, a daily motivational quote (fetched from Quotable or ZenQuotes, with a built-in fallback list, cached once per day), summary cards, and today's tasks filtered by Morning, Afternoon or Night.
- **Calendar.** A month calendar built on `table_calendar` where tasks can be added, edited, completed and deleted per day, including editing or deleting every occurrence of a recurring task. Past times are rejected when scheduling.
- **Natural-language task automation.** Type something like "Watch Solo Leveling every Friday at 7:00 PM" and a rule-based parser pulls out the title, weekday or "today/tomorrow", time and whether it repeats. The user picks a category, and the app places the occurrences on the calendar and saves the recurring task to the backend.
- **Tasks and categories.** A searchable task list with category filter chips. Custom categories can be created from the task dialogs and are saved per user on the server, and each category gets its own icon.
- **In-app reminders.** A background timer checks the schedule every minute and raises a notification five minutes before a task starts and again when it is due. Notifications collect in a dropdown with an unread badge.
- **Assistant chat.** An "OtakuPlanner Assistant" chat screen with suggested prompts (plan a study session, prioritize tasks, suggest a break, organize a watchlist, motivation). Replies currently come from keyword-matched templates on the device, not a language model.
- **Achievements.** 30 achievements across categories such as tasks, habits and customization, with a level header, Completed / In Progress / Locked filters and progress bars.
- **Profile and settings.** Profile with completed-task count from the API, edit profile with a photo picked from the gallery, and a light/dark theme toggle.

## Tech stack

| Area | Choice |
| --- | --- |
| Framework | Flutter (Dart SDK `^3.7.2`) |
| State management | `provider` (`ChangeNotifier` + `MultiProvider`) |
| Networking | `dio` for the backend API, `http` for public APIs |
| Local storage | `hive` / `hive_flutter` (auth token, user profile), `shared_preferences` (daily quote cache) |
| UI | `table_calendar`, `font_awesome_flutter`, `step_progress_indicator`, custom Poppins and Abhaya Libre fonts |
| Models | `json_annotation` / `json_serializable` (generated `*.g.dart` files) |
| Device | `image_picker` for profile photos |
| Backend | [OtakuPlannerBackend](https://github.com/mofixiu/OtakuPlannerBackend) (Node.js / Express) |
| External APIs | Quotable and ZenQuotes (daily quotes), Jikan and AniList (anime character search, not yet wired into the UI) |

## Architecture

### State management

`main.dart` initializes Hive and the request service, then wraps the app in a `MultiProvider` with five `ChangeNotifier`s:

| Provider | Responsibility |
| --- | --- |
| `UserProvider` | Username, email, user ID, join date and profile photo, persisted to a Hive box |
| `TaskProvider` | Tasks keyed by date, plus add/edit/delete/complete and recurring-task helpers |
| `CategoryProvider` | Task categories, loaded from and saved to the API |
| `ThemeProvider` | Light/dark `ThemeMode` |
| `NotificationService` | In-app notification list, unread count and toasts |

Screens read and update these with `Provider.of` / `Consumer`. Theme colors are centralized in `lib/themes/theme.dart` (`OtakuPlannerTheme`).

### Talking to the backend

All API calls go through a singleton `RequestService` in `lib/screens/request.dart`:

- **Base URL.** Set by two constants at the top of the file: `host` (currently a development tunnel URL) and `baseUrl = "$host/api"`. Point `host` at your own running backend.
- **Auth.** `POST /auth/login` and `POST /auth/register` return a token that is saved to a Hive `token` box. A Dio interceptor adds `Authorization: Bearer <token>` to every request outside `/auth/`.
- **Session expiry.** A 401 on a protected route clears the token, shows a "session expired" message and navigates to `/login`.
- **Endpoints used.** `/tasks`, `/users/:id/tasks`, `/users/:id/completed-tasks`, `/users/:id/profile`, `/recurring-tasks`, `/users/:id/recurring-tasks`, `/categories` and `/users/:id/categories`.
- **Helpers.** Top-level `get`, `post`, `put` and `delete` functions, plus typed wrappers such as `saveTaskToDatabase`, `updateTaskInDatabase` and `saveRecurringTaskToDatabase`.

## Getting started

### Prerequisites

- Flutter SDK with Dart `^3.7.2` (Flutter 3.29 or later)
- Xcode (iOS) or Android Studio / Android SDK (Android)
- A running instance of the [OtakuPlannerBackend](https://github.com/mofixiu/OtakuPlannerBackend) API

### Run

```bash
git clone https://github.com/mofixiu/OtakuPlanner.git
cd OtakuPlanner
flutter pub get
flutter run
```

### Configuration

- **Backend URL.** Edit `host` in `lib/screens/request.dart` so it points at your backend (for example `http://10.0.2.2:3000` from the Android emulator). The app appends `/api`.
- **Environment files.** None are required. `flutter_dotenv` is listed as a dependency, but no `.env` file is loaded.
- **Generated code.** The `*.g.dart` model files are committed. If you change a model, regenerate them with `dart run build_runner build` after adding `build_runner` as a dev dependency.

## Project structure

```
lib/
├── main.dart                  # App entry: Hive init, providers, theme, routes
├── models/                    # Task, recurring task, category, user, notification (+ generated .g.dart)
├── providers/                 # User, task, category and theme ChangeNotifiers
├── screens/
│   ├── animeMode/             # Anime-mode dashboard (placeholder)
│   ├── entryScreens/          # Login, sign-up, setup, forgot/change password
│   ├── normalMode/            # Dashboard, calendar, tasks, automation, AI chat, achievements, profile, settings
│   └── request.dart           # Dio API client, auth token handling, endpoint helpers
├── services/                  # Assistant reply service
├── shared/                    # Quotes, notifications, in-app reminders, categories, Jikan/AniList clients
├── themes/                    # Light and dark themes, color helpers
└── widgets/                   # Bottom nav, app bar, buttons, task cards, splash screen
```

## Status

OtakuPlanner was built as a team project. Some screens are still UI-only: Anime Mode opens a "Coming Soon" page, the social sign-in buttons and password-reset flow are not connected, the streak card and achievement progress show sample data, and settings other than the theme toggle are not wired up yet.

## Credits

Built March to May 2025 by a two-person team.

**Mofiyinfoluwa Ebo** ([@mofixiu](https://github.com/mofixiu)), lead mobile developer. Portfolio: [mofiyinebo.com](https://mofiyinebo.com)

Backend: [mofixiu/OtakuPlannerBackend](https://github.com/mofixiu/OtakuPlannerBackend)
