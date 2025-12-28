# 💧 WaterPulse

![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=for-the-badge)
![License](https://img.shields.io/github/license/yiit-erdogan/WaterPulse?color=blue&style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3.9%2B-3776AB?logo=python&logoColor=white&style=for-the-badge)
![FastAPI](https://img.shields.io/badge/FastAPI-High%20Performance-009688?logo=fastapi&logoColor=white&style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white&style=for-the-badge)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Enterprise%20SQL-336791?logo=postgresql&logoColor=white&style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?logo=docker&logoColor=white&style=for-the-badge)

---

## 🌟 Vision & Philosophy

**WaterPulse** represents a paradigm shift in personal health tracking. We believe that hydration shouldn't be a solitary chore, but a shared, engaging experience. By fusing precise physiological tracking with the compelling mechanics of social gaming, WaterPulse turns the simple act of drinking water into a daily adventure.

Our philosophy is built on "**Social Hydration**": the idea that accountability and competition drive better health outcomes. Whether it's maintaining a 30-day streak with a best friend or climbing the global leaderboards, every sip in WaterPulse contributes to a larger, shared progress. We've designed an ecosystem where users don't just track data—they build habits, forge connections, and unlock a healthier version of themselves together.

---

## 🏛️ Technical Architecture Deep Dive

WaterPulse is engineered for performance, scalability, and a seamless user experience. We have chosen a modern, industry-leading tech stack to ensure robust backend operations and a fluid, responsive frontend.

### 🐍 Backend: Python & FastAPI
At the core of WaterPulse lies a high-performance RESTful API built with **FastAPI**. We chose FastAPI for its exceptional speed—on par with NodeJS and Go—enabled by its native support for asynchronous programming. This is critical for our social features, where real-time interactions like "pokes" and live leaderboard updates require non-blocking I/O operations.

*   **Asynchronous Database Management**: We utilize **SQLAlchemy** in its asynchronous mode (`AsyncSession`), allowing the server to handle thousands of concurrent database transactions without stalling. This ensures that when a user logs water, the response is instantaneous, even under heavy load.
*   **Data Integrity with Pydantic**: Every piece of data entering or leaving our API is rigorously validated using **Pydantic** models. This guarantees robust type safety and eliminates common runtime errors, ensuring that the frontend always receives structured, predictable JSON responses.
*   **Security & Authentication**: Security is paramount. We implement **OAuth2 with Password Flow**, issuing JSON Web Tokens (JWT) for stateless, secure authentication. Passwords are never stored in plain text; instead, we use `bcrypt` hashing to ensure maximum protection for user credentials.
*   **Modular API Design**: The application is structured into discrete routers (`users`, `water`, `friends`, `gamification`), promoting code maintainability and separation of concerns.

### 💙 Frontend: Flutter & Riverpod
The WaterPulse mobile application provides a native performance across both iOS and Android, powered by **Flutter**.

*   **Reactive State Management**: We leverage **Riverpod** for state management, chosen for its compile-time safety and testability. Riverpod allows us to manage complex application states—such as optimistic UI updates when a user logs water offline—ensuring the app feels incredibly fast and responsive.
*   **"Neural" Design System**: Our custom UI framework, dubbed "Neural", utilizes advanced glassmorphism, dynamic gradients, and physics-based animations to create an interface that feels alive. Every interaction, from a button press to a screen transition, is polished to provide tactile, satisfying feedback.

---

## 📂 Project Structure

A high-level overview of the codebase organization:

```
WaterPulse/
├── 📂 backend/
│   ├── 📂 app/
│   │   ├── 📂 api/v1/          # API Route Controllers
│   │   │   ├── 📄 routes_users.py      # Auth & Profile logic
│   │   │   ├── 📄 routes_water.py      # Hydration logging & stats
│   │   │   ├── 📄 routes_friends.py    # Social graph management
│   │   │   └── 📄 routes_gamification.py # XP, Levels, & Avatars
│   │   ├── 📂 core/            # Config & Security handlers
│   │   ├── 📂 db/              # Database models & sessions
│   │   └── 📄 main.py          # Application entry point
│   ├── 📄 requirements.txt     # Python dependencies
│   └── 📄 Dockerfile           # Containerization setup
│
├── 📂 frontend/
│   ├── 📂 lib/
│   │   ├── 📂 features/        # Feature-based architecture
│   │   │   ├── 📂 auth/        # Login/Register screens
│   │   │   ├── 📂 home/        # Dashboard & tracking
│   │   │   └── 📂 social/      # Friends & Leaderboards
│   │   ├── � core/            # Shared utilities & theme
│   │   └── 📄 main.dart        # App entry point
│   └── 📄 pubspec.yaml         # Dart dependencies
```

---

## 🚀 Key Features Walkthrough

### 1. Smart Hydration Engine
The heart of the app is its intelligent tracking system. Users can quickly log intake using preset buttons (e.g., 200ml, 500ml). The backend instantly calculates progress towards the daily goal, updating the circular progress ring with a fluid animation. Historical data is aggregated into beautiful weekly and monthly charts, helping users identify trends.

### 2. The Social Graph
WaterPulse isn't just a tracker; it's a social network. Users can search for friends by username and send requests. Once connected, friends can view each other's daily progress percentages (respecting privacy settings). The **Streak System** tracks consecutive days where both friends hit their goals, incentivizing mutual consistency.

### 3. Gamification Layer
To keep motivation high, we've built a complete RPG-lite system. Every milliliter of water earns **Experience Points (XP)**. As users level up, they unlock new **Titles** and **Avatar Skins**. The backend handles complex logic to award achievements like "Early Bird" (drinking before 8 AM) or "Hydration Hero" (hitting goals for 7 days straight).

---

## ⚡ Installation & Setup Guide

### Backend Service
1.  **Environment Setup**: Navigate to the `backend` folder. Create a virtual environment to keep dependencies isolated:
    ```bash
    python -m venv .venv
    source .venv/bin/activate  # Windows: .\.venv\Scripts\activate
    ```
2.  **Dependencies**: Install the required high-performance libraries:
    ```bash
    pip install -r requirements.txt
    ```
3.  **Launch**: Start the Uvicorn server with hot-reload enabled for development:
    ```bash
    uvicorn app.main:app --reload
    ```
    *The API is now live at `http://127.0.0.1:8000`.*

### Frontend Application
1.  **Initialization**: Move to the `frontend` directory and fetch the Dart packages:
    ```bash
    flutter pub get
    ```
2.  **Run**: Launch the application on your preferred emulator or device:
    ```bash
    flutter run
    ```
---

## 📞 Connect with the Developer

**Yiğit Erdoğan**
*Lead Full-Stack Engineer*

I am passionate about building scalable, user-centric applications that solve real-world problems. Feel free to connect with me to discuss technology, collaboration, or the WaterPulse project.

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect_on_LinkedIn-blue?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/yi%C4%9Fit-erdo%C4%9Fan-ba7a64294)

---
*Built with ❤️ and 💧 by Yiğit Erdoğan.*
