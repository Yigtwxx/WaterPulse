# backend/app/utils/calc_water_goal.py

def calculate_daily_goal_ml(weight_kg: float | None,
                            activity_level: str | None) -> int:
    """
    Çok basit ve kaba bir formül:
      - Temel: 30 ml * kg
      - Aktivite yüksekse %20 bonus

    Gerçek hayatta daha gelişmiş formüller kullanırsın.
    """
    if weight_kg is None:
        base = 2000  # default
    else:
        base = int(weight_kg * 30)

    if activity_level and activity_level.lower() == "high":
        base = int(base * 1.2)

    return base
