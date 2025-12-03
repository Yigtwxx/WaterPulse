import 'dart:math';
import 'package:flutter/material.dart';

class WaterFactsWidget extends StatefulWidget {
  const WaterFactsWidget({super.key});

  @override
  State<WaterFactsWidget> createState() => _WaterFactsWidgetState();
}

class _WaterFactsWidgetState extends State<WaterFactsWidget> {
  // English facts
  final List<String> _factsEn = [
    "Water makes up about 60% of the human body.",
    "Drinking water before meals can help you feel fuller and aid in weight loss.",
    "Your brain is about 73% water; dehydration can affect focus and memory.",
    "Water helps regulate your body temperature through sweating and respiration.",
    "Cartilage, found in joints and the disks of the spine, contains around 80% water.",
    "Water is essential for the kidneys to filter waste from the blood.",
    "A person can live for about a month without food, but only about a week without water.",
    "Hot water freezes faster than cold water, a phenomenon known as the Mpemba effect.",
    "Less than 1% of the water supply on earth can be used as drinking water.",
    "Drinking enough water can improve your skin complexion and health.",
    "Dehydration can trigger headaches and migraines in some individuals.",
    "Water cushions the brain, spinal cord, and other sensitive tissues.",
    "The airways need to be kept moist, so staying hydrated is good for your lungs.",
    "Water makes minerals and nutrients accessible to different parts of your body.",
    "Even mild dehydration can drain your energy and make you tired."
  ];

  // Turkish facts
  final List<String> _factsTr = [
    "İnsan vücudunun yaklaşık %60'ı sudan oluşur.",
    "Yemeklerden önce su içmek daha tok hissetmenize ve kilo vermenize yardımcı olabilir.",
    "Beyninizin yaklaşık %73'ü sudur; susuzluk odaklanmayı ve hafızayı etkileyebilir.",
    "Su, terleme ve solunum yoluyla vücut ısınızı düzenlemeye yardımcı olur.",
    "Eklemlerde ve omurga disklerinde bulunan kıkırdak yaklaşık %80 su içerir.",
    "Böbreklerin kandaki atıkları filtrelemesi için su gereklidir.",
    "Bir insan yemek yemeden yaklaşık bir ay yaşayabilir, ancak susuz sadece bir hafta yaşayabilir.",
    "Sıcak su soğuk sudan daha hızlı donar, bu fenomene Mpemba etkisi denir.",
    "Dünyadaki su kaynaklarının %1'inden azı içme suyu olarak kullanılabilir.",
    "Yeterli su içmek cilt renginizi ve sağlığınızı iyileştirebilir.",
    "Susuzluk bazı bireylerde baş ağrısı ve migreni tetikleyebilir.",
    "Su, beyni, omuriliği ve diğer hassas dokuları yastıklar.",
    "Hava yollarının nemli tutulması gerekir, bu yüzden hidrate kalmak ciğerleriniz için iyidir.",
    "Su, mineralleri ve besinleri vücudunuzun farklı bölgelerine erişilebilir kılar.",
    "Hafif susuzluk bile enerjinizi tüketebilir ve sizi yorgun hissettirebilir."
  ];

  late String _currentFact;
  final Random _random = Random();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshFact();
  }

  void _refreshFact() {
    final locale = Localizations.localeOf(context);
    final facts = locale.languageCode == 'tr' ? _factsTr : _factsEn;
    
    setState(() {
      _currentFact = facts[_random.nextInt(facts.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _refreshFact,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  _currentFact,
                  key: ValueKey<String>(_currentFact),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[800],
                          height: 1.3),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.refresh, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
