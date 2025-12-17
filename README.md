
# 💧 WaterPulse

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![License](https://img.shields.io/github/license/yiit-erdogan/WaterPulse?color=blue)
![Python](https://img.shields.io/badge/Python-3.9%2B-3776AB?logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-0.68%2B-009688?logo=fastapi&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-13%2B-336791?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white)

**WaterPulse** is a next-generation hydration tracking application that combines precise water intake monitoring with social interaction and gamification. Designed to turn a daily chore into an engaging habit, WaterPulse helps users stay healthy, hydrated, and connected.

---

## 🚀 Features

### core Functionality
-   **Smart Hydration Tracking**: Log water intake seamlessly with quick-add buttons.
-   **Daily Goals**: Personalized daily water intake goals based on user metrics.
-   **Analytics & Statistics**: Detailed charts and insights into hydration habits over time.

### 🤝 Social & Competitive
-   **Friends System**: Add friends to see their progress and motivate each other.
-   **Streaks**: Maintain hydration streaks with friends for shared accountability.
-   **Pokes**: Send friendly "pokes" to remind friends to drink water.
-   **Leaderboards**: Compete for the top spot on weekly and monthly hydration leaderboards.

### 🎮 Gamification
-   **Achievements**: Unlock unique badges and titles for milestones (e.g., "Early Bird", "Hydration Hero").
-   **Avatar Customization**: Earn and equip detailed avatar skins to personalize your profile.
-   **Experience & Levels**: Gain XP for every milliliter drunk and level up your account.

---

## 🛠️ Backend Architecture

The backend of WaterPulse is built with **Python** and **FastAPI**, designed for high performance, asynchronous request handling, and scalability.

### Technology Stack
-   **Framework**: [FastAPI](https://fastapi.tiangolo.com/) - Modern, fast (high-performance) web framework for building APIs with Python 3.9+.
-   **Database ORM**: [SQLAlchemy](https://www.sqlalchemy.org/) (Async) - For robust and asynchronous database interactions.
-   **Database**: PostgreSQL (Production) / SQLite (Development).
-   **Server**: Uvicorn - A lightning-fast ASGI server implementation.
-   **Authentication**: JWT (JSON Web Tokens) with OAuth2 password flow for secure user sessions.
-   **Validation**: Pydantic models for strict data validation and serialization.

### 📂 API Structure
The API is organized into modular routes under `app/api/v1`, ensuring separation of concerns:

| Module | Description | Key Features |
| :--- | :--- | :--- |
| **Users** (`routes_users.py`) | User management | Registration, Profile updates, Settings |
| **Water** (`routes_water.py`) | Hydration logic | Log intake, Daily summaries, Optimistic updates |
| **Friends** (`routes_friends.py`) | Social graph | Add/Remove friends, Friend requests, List friends |
| **Streaks** (`routes_streaks.py`) | Social engagement | Track consecutive hydration days with friends |
| **Poke** (`routes_poke.py`) | Notifications | Send reminders/pokes to friends |
| **Achievements** | Gamification | Unlock logic, List user achievements |
| **Avatar** (`routes_avatar.py`) | Customization | Shop/Equip logic for avatar skins |

### 🔐 Security & Auth
-   **Password Hashing**: Uses `bcrypt` for secure password storage.
-   **Token-Based Auth**: Stateless authentication using secure access tokens.
-   **Dependency Injection**: FastAPI's DI system is used for database sessions and current user retrieval `get_current_user`.

---

## 📱 Frontend Architecture

The mobile application is developed using **Flutter**, offering a smooth, native-like experience on both iOS and Android.

-   **Framework**: Flutter (Dart).
-   **State Management**: [Riverpod](https://riverpod.dev/) for caching, data binding, and reactive state updates.
-   **UI/UX**: Custom "Neural" design system with glassmorphism, dynamic animations, and theme-aware gradients.
-   **Networking**: `Dio` client with interceptors for auth token management.

---

## ⚡ Installation & Setup

### Prerequisites
-   Python 3.9+
-   Flutter SDK
-   PostgreSQL (Optional, SQLite default for dev)

### Backend Setup
1.  Navigate to the backend directory:
    ```bash
    cd backend
    ```
2.  Create and activate a virtual environment:
    ```bash
    python -m venv .venv
    # Windows
    .\.venv\Scripts\activate
    # macOS/Linux
    source .venv/bin/activate
    ```
3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4.  Run the server:
    ```bash
    uvicorn app.main:app --reload
    ```
    The API will be available at `http://127.0.0.1:8000`. Documentation at `/docs`.

### Frontend Setup
1.  Navigate to the frontend directory:
    ```bash
    cd frontend
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the app:
    ```bash
    flutter run
    ```

---

## 📞 Contact

**Yiğit Erdoğan** - Lead Developer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/yi%C4%9Fit-erdo%C4%9Fan-ba7a64294)

Check out my other projects on [GitHub](https://github.com/yiit-erdogan).
