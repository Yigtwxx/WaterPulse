// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'WaterPulse';

  @override
  String get homeToday => 'Bugün';

  @override
  String get homeAddWater => 'Su Ekle';

  @override
  String get homeGoal => 'Hedef';

  @override
  String get suggestions => 'Biliyor muydunuz?';

  @override
  String get suggestionText => 'Aktivitene göre biraz daha su içmelisin 💧';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get friends => 'Arkadaşlar';

  @override
  String get friendsSubtitle => 'Arkadaşlarınla kıyasla';

  @override
  String get achievements => 'Başarılar';

  @override
  String get achievementsSubtitle => 'Serilerini ve rozetlerini takip et';

  @override
  String get streakAvatar => 'Seri & Avatar';

  @override
  String get settings => 'Ayarlar';

  @override
  String get profile => 'Profil';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get dailyGoal => 'Günlük Hedef';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get selectDate => 'Seçilen tarih';

  @override
  String get hydrationTime => 'Su İçme Zamanı! 💧';

  @override
  String get hydrationBody =>
      'Günlük hedefine çok yakınsın! Su içmeye devam et.';

  @override
  String get currentStreak => 'Mevcut seri';

  @override
  String get bestStreak => 'En iyi seri';

  @override
  String get days => 'gün';

  @override
  String get avatarSkins => 'Avatar görünümleri';

  @override
  String get noSkins => 'Henüz görünüm yok';

  @override
  String get defaultSkinName => 'Görünüm';

  @override
  String get navHome => 'Ana Sayfa';

  @override
  String get navDatas => 'Veriler';

  @override
  String get navSports => 'Spor';

  @override
  String get skinMintBreeze => 'Nane Esintisi';

  @override
  String get skinOceanBlue => 'Okyanus Mavisi';

  @override
  String get skinSunrise => 'Gündoğumu';

  @override
  String get guestUser => 'Misafir Kullanıcı';

  @override
  String keepHydrating(Object username) {
    return 'Su içmeye devam et, $username!';
  }

  @override
  String get loginToSync => 'Verilerini eşitlemek için giriş yap';

  @override
  String get login => 'Giriş Yap';

  @override
  String get signup => 'Kayıt Ol';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get dailyGoalSubtitle => 'Günlük içmek istediğin su miktarını ayarla.';

  @override
  String get reminders => 'Hatırlatıcılar';

  @override
  String get remindersSubtitle => 'Su içmek için nazik hatırlatmalar al.';

  @override
  String get remindersOn => 'Hatırlatıcılar: Açık';

  @override
  String get remindersOff => 'Hatırlatıcılar: Kapalı';

  @override
  String get themeSubtitle => 'Aydınlık ve Karanlık mod arasında geçiş yap.';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';

  @override
  String get languageSubtitle => 'Tercih ettiğin dili seç.';

  @override
  String get friendsLeaderboard => 'Arkadaşlar & Liderlik Tablosu';

  @override
  String get yourCode => 'Kodun:';

  @override
  String get codeCopied => 'Kod kopyalandı';

  @override
  String get pasteFriendCode => 'Arkadaş kodunu yapıştır';

  @override
  String friendRequestSent(Object code) {
    return 'Arkadaş isteği gönderildi: $code';
  }

  @override
  String get add => 'Ekle';

  @override
  String get noFriends => 'Henüz arkadaş eklenmedi.';

  @override
  String get allAchievements => 'Tüm Başarılar';

  @override
  String get noAchievements => 'Henüz başarı yok';

  @override
  String get streakMedallions => 'Seri Madalyaları';

  @override
  String dayStreak(Object count) {
    return '$count günlük seri';
  }

  @override
  String daysLeft(Object count) {
    return '$count gün kaldı';
  }

  @override
  String get won => 'Kazandın';

  @override
  String get achGoalReached => 'Su Zirvesi! ✋';

  @override
  String get achFirstLog => 'İlk Sıçrama 💦';

  @override
  String get ach500ml => 'Yarım Litre Kahramanı 🦸';

  @override
  String get achGoal1Day => 'Bir Günlük Harika 🌟';

  @override
  String get achGoal7Days => 'Haftalık Savaşçı ⚔️';

  @override
  String get achGoal30Days => 'Aylık Usta 🏆';

  @override
  String get achGoal90Days => 'Çeyrek Kral 👑';

  @override
  String get achEarlyBird => 'Erkenci Kuş 🐦';

  @override
  String get achNightOwl => 'Gece Kuşu 🦉';

  @override
  String get achWeekendWarrior => 'Hafta Sonu Savaşçısı 🏖️';

  @override
  String get achMarathon => 'Deve Modu 🐪';

  @override
  String get achFirstLogDesc => 'İlk su bardağını kaydet';

  @override
  String get ach500mlDesc => 'Bir günde 500ml su iç';

  @override
  String get achGoalReachedDesc => 'Günlük su hedefine ulaş';

  @override
  String get achGoal1DayDesc => 'Hedefini 1 gün tamamla';

  @override
  String get achGoal7DaysDesc => 'Hedefini 7 gün art arda tamamla';

  @override
  String get achGoal30DaysDesc => 'Hedefini 30 gün art arda tamamla';

  @override
  String get achGoal90DaysDesc => 'Hedefini 90 gün art arda tamamla';

  @override
  String get achEarlyBirdDesc => 'Sabah 8:00\'den önce su iç';

  @override
  String get achNightOwlDesc => 'Gece 22:00\'den sonra su iç';

  @override
  String get achWeekendWarriorDesc => 'Cumartesi ve Pazar hedefine ulaş';

  @override
  String get achMarathonDesc => 'Bir günde 3 Litre su iç';
}
