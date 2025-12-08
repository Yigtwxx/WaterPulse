from sqlalchemy.orm import Session
from sqlalchemy import func, cast, Date, extract

from app.models import achievement, water_log, user, friend
from app.schemas.achievement_schemas import AchievementCreate
from app.services import streak_service


def list_achievements(db: Session, user_id: int):
    return (
        db.query(achievement.Achievement)
        .filter(achievement.Achievement.user_id == user_id)
        .order_by(achievement.Achievement.unlocked_at.desc())
        .all()
    )


def create_achievement(db: Session, payload: AchievementCreate):
    record = achievement.Achievement(
        user_id=payload.user_id,
        title=payload.title,
        description=payload.description,
        points=payload.points,
    )
    db.add(record)
    db.commit()
    db.refresh(record)
    return record


def ensure_unique_title(db: Session, user_id: int, title: str) -> bool:
    """Check if the user already has an achievement with the same title."""
    existing = (
        db.query(achievement.Achievement)
        .filter(achievement.Achievement.user_id == user_id)
        .filter(achievement.Achievement.title == title)
        .first()
    )
    return existing is None


def sync_achievements(db: Session, user_id: int):
    """
    Checks user history and awards any missing achievements retroactively.
    """
    
    # 1. First Log
    # If user has logs but no "First Water Log" achievement
    has_logs = db.query(water_log.WaterLog).filter(water_log.WaterLog.user_id == user_id).first()
    if has_logs:
        if ensure_unique_title(db, user_id, "First Water Log"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="First Water Log",
                description="First water log recorded!",
                points=10
            ))

    # 2. 500ml Verification
    # Check max daily intake
    max_daily = (
         db.query(func.sum(water_log.WaterLog.amount_ml).label('total'))
         .filter(water_log.WaterLog.user_id == user_id)
         .group_by(cast(water_log.WaterLog.timestamp, Date))
         .order_by(func.desc('total'))
         .first()
    )
    if max_daily and max_daily.total >= 500:
        if ensure_unique_title(db, user_id, "500ml Badge"):
             create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="500ml Badge",
                description="You drank 500 ml in a day!",
                points=15
            ))

    # 3. Daily Goal Reached
    # Check if any day >= goal
    user_obj = db.query(user.User).filter(user.User.id == user_id).first()
    if user_obj:
        # Check if there is ANY day where sum >= daily_goal
        # Use a subquery or loop. Since we just need ONE existence for the badge.
        daily_sums = (
             db.query(func.sum(water_log.WaterLog.amount_ml).label('total'))
             .filter(water_log.WaterLog.user_id == user_id)
             .group_by(cast(water_log.WaterLog.timestamp, Date))
             .all()
        )
        has_reached_goal = any(d.total >= user_obj.daily_goal_ml for d in daily_sums)
        
        if has_reached_goal:
            # We want to ensure at least ONE "Daily Goal Reached" achievement exists
            # The backend normally creates titled "Daily Goal Reached: YYYY-MM-DD".
            # The frontend looks for description containing "daily water intake goal".
            # So we can create a generic one if none exist.
            
            # Efficient check: search for any achievement with matching description
            existing_goal_ach = (
                db.query(achievement.Achievement)
                .filter(achievement.Achievement.user_id == user_id)
                .filter(achievement.Achievement.description.like("%daily water intake goal%"))
                .first()
            )
            
            if not existing_goal_ach:
                # Create a generic catch-up achievement
                create_achievement(db, AchievementCreate(
                    user_id=user_id,
                    title="Daily Goal Reached (Synced)",
                    description="You reached your daily water intake goal!",
                    points=10
                ))

    # 4. Volume Badges (High Intake)
    # Check max daily intake again
    if max_daily:
        vol = max_daily.total
        # Camel Mode (3L = 3000ml) - Frontend key: marathon / Camel Mode
        if vol >= 3000:
            if ensure_unique_title(db, user_id, "Camel Mode 🐪"):
                create_achievement(db, AchievementCreate(
                    user_id=user_id,
                    title="Camel Mode 🐪",
                    description="Drink 3 Liters in a single day",
                    points=20
                ))
        
        # Hydration Hippo (4L = 4000ml)
        if vol >= 4000:
            if ensure_unique_title(db, user_id, "Hydration Hippo 🦛"):
                create_achievement(db, AchievementCreate(
                    user_id=user_id,
                    title="Hydration Hippo 🦛",
                    description="Drink 4 Liters in a single day",
                    points=25
                ))

        # Tsunami Tamer (5L = 5000ml)
        if vol >= 5000:
            if ensure_unique_title(db, user_id, "Tsunami Tamer 🌊"):
                create_achievement(db, AchievementCreate(
                    user_id=user_id,
                    title="Tsunami Tamer 🌊",
                    description="Drink 5 Liters in a single day",
                    points=30
                ))

    # 5. Time-based Badges
    # We need to query timestamps. 
    # Extract hour from timestamp is db-specific. Postgres: extract(hour from timestamp)
    
    # Early Bird: 5 AM - 8 AM
    from sqlalchemy import extract
    early_bird_exists = (
        db.query(water_log.WaterLog)
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(extract('hour', water_log.WaterLog.timestamp) >= 5)
        .filter(extract('hour', water_log.WaterLog.timestamp) < 8)
        .first()
    )
    if early_bird_exists:
        if ensure_unique_title(db, user_id, "Early Bird 🌅"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="Early Bird 🌅",
                description="Drink water early in the morning (5-8 AM)",
                points=10
            ))

    # Night Owl: 23 PM - 3 AM
    # 23, 0, 1, 2
    night_owl_exists = (
        db.query(water_log.WaterLog)
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(
            (extract('hour', water_log.WaterLog.timestamp) >= 23) |
            (extract('hour', water_log.WaterLog.timestamp) < 3)
        )
        .first()
    )
    if night_owl_exists:
        if ensure_unique_title(db, user_id, "Night Owl 🦉"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="Night Owl 🦉",
                description="Drink water late at night (11 PM - 3 AM)",
                points=10
            ))

    # Weekend Warrior: Saturday (6) or Sunday (0) in Postgres, wait
    # dow: 0=Sunday, 6=Saturday in Postgres usually.
    # Let's check if any log has dow in [0, 6]
    weekend_exists = (
        db.query(water_log.WaterLog)
        .filter(water_log.WaterLog.user_id == user_id)
        .filter(extract('dow', water_log.WaterLog.timestamp).in_([0, 6]))
        .first()
    )
    if weekend_exists:
        if ensure_unique_title(db, user_id, "Weekend Warrior ⚔️"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="Weekend Warrior ⚔️",
                description="Drink water on a weekend",
                points=10
            ))

    # 6. Social Badges
    from app.models import friend
    friend_count = (
        db.query(func.count(friend.Friend.id))
        .filter(friend.Friend.user_id == user_id)
        # .filter(friend.Friend.status == 'accepted') # Assuming we count accepted only?
        # For now count all to be generous or if status is not reliably set
        .scalar()
    )
    if friend_count and friend_count >= 1:
        if ensure_unique_title(db, user_id, "Social Butterfly 🦋"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="Social Butterfly 🦋",
                description="Add your first friend",
                points=10
            ))
            
    if friend_count and friend_count >= 5:
        if ensure_unique_title(db, user_id, "Community Pillar 🏛️"):
            create_achievement(db, AchievementCreate(
                user_id=user_id,
                title="Community Pillar 🏛️",
                description="Have 5 friends",
                points=20
            ))

    # 7. Streaks (Existing Logic)
    try:
        current, best, _, _, _ = streak_service.calculate_streaks(db, user_id)
        
        streak_milestones = {
            1: ("Streak 1 day", "Complete goal 1 day in a row", 30),
            7: ("Streak 7 days", "Complete goal 7 days in a row", 50),
            30: ("Streak 30 days", "Complete goal 30 days in a row", 80),
            90: ("Streak 90 days", "Complete goal 90 days in a row", 120),
        }
        
        # Award based on BEST streak history
        target_streak = max(current, best)
        
        for days_req, (title, desc, points) in streak_milestones.items():
            if target_streak >= days_req:
                if ensure_unique_title(db, user_id, title):
                    create_achievement(db, AchievementCreate(
                        user_id=user_id,
                        title=title,
                        description=desc,
                        points=points
                    ))
    except Exception as e:
        print(f"Error syncing streaks: {e}")
