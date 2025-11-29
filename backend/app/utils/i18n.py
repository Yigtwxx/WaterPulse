MESSAGES = {
    "en": {
        "welcome": "WaterPulse API is running",
        "not_found": "Resource not found",
    },
    "tr": {
        "welcome": "WaterPulse API çalışıyor",
        "not_found": "Kaynak bulunamadı",
    },
}


def translate(key: str, lang: str = "en") -> str:
    table = MESSAGES.get(lang, MESSAGES["en"])
    return table.get(key, key)
