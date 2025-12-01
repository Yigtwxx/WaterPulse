# 💧 WaterPulse

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**WaterPulse** is a modern, cross-platform hydration tracking application designed to help you stay healthy and hydrated. Combining a sleek, responsive **Flutter** frontend with a robust **FastAPI** backend, WaterPulse delivers a seamless user experience with smart reminders, detailed analytics, and an intuitive interface.

---

## 🚀 Features

*   **Smart Hydration Tracking**: Easily log your water intake with a single tap.
*   **Intelligent Reminders**: Get timely notifications to drink water based on your schedule.
*   **Visual Analytics**: View your hydration history with beautiful, interactive charts (Daily, Weekly, Monthly).
*   **Cross-Platform**: Runs smoothly on Windows, Android, and iOS (built with Flutter).
*   **Data Persistence**: Secure local data storage using SQLite, managed by a high-performance Python backend.
*   **Clean UI/UX**: A polished, user-friendly interface designed for ease of use.

---

## 🛠️ Tech Stack

### Frontend (Mobile & Desktop)
*   **Framework**: [Flutter](https://flutter.dev/) (Dart)
*   **State Management**: [Riverpod](https://riverpod.dev/)
*   **Routing**: [GoRouter](https://pub.dev/packages/go_router)
*   **Charting**: [FlChart](https://pub.dev/packages/fl_chart)
*   **HTTP Client**: [http](https://pub.dev/packages/http)

### Backend (API & Logic)
*   **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
*   **Server**: [Uvicorn](https://www.uvicorn.org/)
*   **Database ORM**: [SQLAlchemy](https://www.sqlalchemy.org/)
*   **Data Processing**: [Pandas](https://pandas.pydata.org/)
*   **Visualization Generation**: [Matplotlib](https://matplotlib.org/) & [Seaborn](https://seaborn.pydata.org/)

### Database
*   **SQLite**: Lightweight, serverless, and self-contained.

---

## 📦 Installation

Follow these steps to set up the project locally.

### Prerequisites
*   **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install)
*   **Python 3.8+**: [Install Python](https://www.python.org/downloads/)
*   **Git**: [Install Git](https://git-scm.com/downloads)

### 1. Clone the Repository
```bash
git clone https://github.com/Yigtwxx/WaterPulse.git
cd WaterPulse
```

### 2. Backend Setup
Navigate to the `backend` directory and set up the Python environment.

```bash
cd backend
# Create a virtual environment
python -m venv .venv

# Activate the virtual environment
# Windows:
.venv\Scripts\activate
# macOS/Linux:
# source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt
cd ..
```

### 3. Frontend Setup
Navigate to the `frontend` directory and install Flutter dependencies.

```bash
cd frontend
flutter pub get
cd ..
```

---

## ▶️ Usage

You can run the entire application (Backend + Frontend) using the provided Dart script.

```bash
# From the root directory
dart run run_all.dart
```

This script will:
1.  Start the FastAPI backend server on `http://127.0.0.1:8000`.
2.  Wait for the backend to be ready.
3.  Launch the Flutter application (Windows by default).

*Alternatively, you can run them separately:*

*   **Backend**: `uvicorn app.main:app --reload` (inside `backend/`)
*   **Frontend**: `flutter run` (inside `frontend/`)

---

## 🗺️ Roadmap

- [ ] Cloud Synchronization (Firebase/PostgreSQL)
- [ ] User Authentication & Profiles
- [ ] Gamification (Badges & Achievements)
- [ ] Wearable Integration

---

## 📞 Contact

**Yiğit Erdoğan**

*   **LinkedIn**: [Connect on LinkedIn](https://www.linkedin.com/in/yiğit-erdoğan-ba7a64294)
*   **GitHub**: [Yigtwxx](https://github.com/Yigtwxx)

---

Made with ❤️ by Yiğit Erdoğan
