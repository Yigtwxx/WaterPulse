from datetime import date, timedelta, datetime
from app.models import user, water_log, achievement
from app.services import streak_service
from app.schemas.water_schemas import WaterLogCreate
from app.api.v1.routes_water import add_water_log

def test_streak_achievement_unlock(db_session):
    # 1. Create a test user
    test_user = user.User(
        email="streak_test@example.com",
        hashed_password="test",
        name="Streak",
        surname="Test",
        daily_goal_ml=2000
    )
    db_session.add(test_user)
    db_session.commit()
    db_session.refresh(test_user)

    # 2. Simulate 6 days of water logs (yesterday backwards)
    today = date.today()
    for i in range(1, 7):
        day = today - timedelta(days=i)
        log = water_log.WaterLog(
            user_id=test_user.id,
            amount_ml=2500,
            timestamp=datetime.combine(day, datetime.min.time())
        )
        db_session.add(log)
    db_session.commit()

    # Verify best streak is 6 before today's log (current is 0 because today is not done)
    _, best, _, _, _ = streak_service.calculate_streaks(db_session, test_user.id)
    assert best == 6

    # 3. Add log for today to reach 7 days
    log_in = WaterLogCreate(
        user_id=test_user.id,
        amount_ml=2500
    )
    # We need to call the API function directly or simulate the request
    # Calling the function directly is easier for unit testing logic
    add_water_log(log_in, db_session)

    # 4. Verify "Streak 7 days" achievement exists
    achievements = db_session.query(achievement.Achievement).filter(
        achievement.Achievement.user_id == test_user.id,
        achievement.Achievement.title == "Streak 7 days"
    ).all()
    
    assert len(achievements) == 1
    assert achievements[0].points == 50
