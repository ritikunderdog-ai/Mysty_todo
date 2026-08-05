# 🌆 Cyberpunk To-Do List App

A gamified, cyberpunk-themed To-Do List application with XP system, streaks, contribution graphs, and neon aesthetics.

## ⚡ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) — Android |
| Backend | Python FastAPI |
| Database | SQLite (async SQLAlchemy) |
| State Management | Provider |
| HTTP Client | Dio |

## 🎮 Gamification Features

- **XP System**: Earn XP by completing tasks (10/25/50 XP based on priority)
- **Streak System**: Maintain daily streaks for bonus XP (+5/day, capped at +50)
- **Level System**: 8 cyberpunk-themed levels from "Street Kid" to "Singularity"
- **Contribution Graph**: GitHub-style heatmap showing your daily activity
- **Penalties**: Lose 20% XP when your streak breaks

## 🏗️ Project Structure

```
├── backend/         # FastAPI Python backend
│   ├── app/
│   │   ├── models/      # SQLAlchemy ORM models
│   │   ├── schemas/     # Pydantic validation schemas
│   │   ├── routers/     # API endpoint routers
│   │   └── services/    # Business logic & gamification
│   ├── requirements.txt
│   └── run.py           # Dev server launcher
│
└── frontend/        # Flutter Android app
    └── lib/
        ├── theme/       # Cyberpunk dark theme
        ├── models/      # Dart data models
        ├── services/    # API client (Dio)
        ├── providers/   # State management
        ├── screens/     # App screens
        └── widgets/     # Reusable UI components
```

## 🚀 Getting Started

### Prerequisites

- Python 3.11+ 
- Flutter SDK 3.8+
- Android Studio (for emulator) or a physical Android device

### Backend Setup

```bash
cd backend
python -m venv venv

# Windows
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start the server
python run.py
```

The API will be available at `http://localhost:8000`.  
Swagger docs at `http://localhost:8000/docs`.

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

> **Note**: If running on an Android emulator, the app uses `10.0.2.2:8000` to connect to localhost.  
> For a physical device, update the base URL in `lib/services/api_service.dart` to your machine's local IP.

## 🎨 Color Palette

| Color | Hex | Usage |
|---|---|---|
| Void Black | `#0a0a0f` | Background |
| Dark Navy | `#1a1a2e` | Surfaces/Cards |
| Neon Cyan | `#00fff5` | Primary |
| Neon Magenta | `#ff00ff` | Secondary/Level |
| Electric Yellow | `#f5ff00` | Accent/Medium Priority |
| Glitch Red | `#ff3131` | Error/High Priority |
| Streak Orange | `#ff6b35` | Streak Fire |

## 📡 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/tasks/` | Create a task |
| `GET` | `/api/v1/tasks/` | List tasks (filterable) |
| `GET` | `/api/v1/tasks/{id}` | Get task details |
| `PUT` | `/api/v1/tasks/{id}` | Update a task |
| `PATCH` | `/api/v1/tasks/{id}/complete` | Complete task + earn XP |
| `DELETE` | `/api/v1/tasks/{id}` | Delete a task |
| `POST` | `/api/v1/categories/` | Create a category |
| `GET` | `/api/v1/categories/` | List categories |
| `DELETE` | `/api/v1/categories/{id}` | Delete a category |
| `GET` | `/api/v1/stats/` | Get XP/streak/level |
| `GET` | `/api/v1/stats/contributions` | Contribution graph data |

## 📜 License

This project is for personal use.
