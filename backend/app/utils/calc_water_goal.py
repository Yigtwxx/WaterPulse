# backend/app/utils/calc_water_goal.py

def calculate_daily_goal_ml(weight_kg: float) -> int:
    """
    Basit örnek formül:
    1 kg için 30 ml su.
    İleride boy, yaş, aktivite seviyesini de ekleyebiliriz.
    """
    return int(weight_kg * 30)
