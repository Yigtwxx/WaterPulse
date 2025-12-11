from app.utils.calc_water_goal import calculate_daily_goal_ml

def calculate_recommendations(
    weight_kg: float | None,
    height_cm: float | None,
    age: int | None,
    gender: str | None,
    activity_level: str | None
) -> dict:
    """
    Kullanıcı verilerine göre sağlık ve spor önerileri oluşturur.
    """
    recommendations = []
    bmi = None
    bmi_status = "Bilinmiyor"

    # 1. BMI Hesabı
    if weight_kg and height_cm:
        height_m = height_cm / 100
        bmi = weight_kg / (height_m * height_m)
        bmi = round(bmi, 1)

        if bmi < 18.5:
            bmi_status = "Zayıf"
            recommendations.append("Vücut kitle indeksiniz düşük seviyede. Sağlıklı bir şekilde kilo almak için kas kütlenizi artıracak egzersizlere ve protein ağırlıklı beslenmeye odaklanabilirsiniz.")
        elif 18.5 <= bmi < 25:
            bmi_status = "Normal"
            recommendations.append("Tebrikler! İdeal kilonuzdasınız. Mevcut formunuzu korumak için düzenli yürüyüş ve hafif kardiyo egzersizleri yapabilirsiniz.")
        elif 25 <= bmi < 30:
            bmi_status = "Fazla Kilolu"
            recommendations.append("Vücut kitle indeksiniz biraz yüksek. Haftada en az 150 dakika orta tempolu yürüyüş veya yüzme gibi aktiviteler faydalı olabilir.")
        else:
            bmi_status = "Obez"
            recommendations.append("Sağlığınız için kilo vermeniz önerilir. Bir uzman eşliğinde düşük etkili egzersizlere (yürüyüş, su jimnastiği) başlamanız iyi bir adım olabilir.")

    # 2. Su Tüketimi (Aktiviteye göre ek tavsiye)
    if activity_level == "high":
        recommendations.append("Yüksek aktivite seviyesine sahipsiniz. Terle kaybettiğiniz sıvıyı yerine koymak için antrenman öncesi ve sonrası ekstra su tüketmeyi unutmayın.")
    elif activity_level == "medium":
        recommendations.append("Orta seviye aktivite için günlük su hedefinizi tutturmanız genellikle yeterlidir, ancak sıcak havalarda ekstra dikkat edin.")
    elif activity_level == "low":
        recommendations.append("Düşük aktivite seviyesindesiniz. Metabolizmanızı canlı tutmak için masa başında çalışıyorsanız bile saat başı bir bardak su içmeyi deneyin.")

    # 3. Genel Yaş/Cinsiyet Tavsiyeleri (Basit örnekler)
    if age and age > 50:
        recommendations.append("50 yaş üzeri bireylerde kas kütlesi kaybını önlemek için direnç egzersizleri ve yeterli protein alımı çok önemlidir.")
    
    if not recommendations:
        recommendations.append("Henüz yeterli veriniz yok. Profilinizden kilo, boy ve yaş bilgilerinizi güncelleyerek size özel öneriler alabilirsiniz.")

    # 4. Önerilen Günlük Hedef
    suggested_goal = calculate_daily_goal_ml(weight_kg, activity_level)

    return {
        "bmi": bmi,
        "bmi_status": bmi_status,
        "recommendations": recommendations,
        "suggested_goal_ml": suggested_goal
    }
