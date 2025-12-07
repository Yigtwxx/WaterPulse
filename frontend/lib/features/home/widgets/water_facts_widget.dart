import 'dart:math';
import 'package:flutter/material.dart';

class WaterFactsWidget extends StatefulWidget {
  const WaterFactsWidget({super.key});

  @override
  State<WaterFactsWidget> createState() => _WaterFactsWidgetState();
}

class _WaterFactsWidgetState extends State<WaterFactsWidget> {
  // English facts
  // English facts (Advanced & Professional)
  final List<String> _factsEn = [
    "Water is the primary solvent for biochemical reactions, including hydrolysis, which breaks down nutrients for absorption.",
    "Optimal hydration maintains blood plasma volume, ensuring efficient cardiovascular function and stroke volume.",
    "Dehydration of just 2% can significantly impair cognitive functions such as psychomotor vigilance and short-term memory.",
    "Electrolytes like sodium and potassium rely on water to maintain membrane potential for nerve impulse transmission.",
    "Synovial fluid, primarily composed of water, acts as a non-Newtonian lubricant reducing friction in articular cartilage.",
    "Water regulates body temperature via high heat capacity and evaporative cooling during perspiration.",
    "Chronic dehydration may increase the risk of urolithiasis (kidney stones) by increasing urine saturation.",
    "The brain's glymphatic system relies on cerebrospinal fluid (mostly water) to clear metabolic waste, including beta-amyloid.",
    "Water is critical for protein folding and structure stability; even slight dehydration can affect enzyme activity.",
    "Hypohydration increases cortisol levels, potentially exacerbating physiological stress responses.",
    "Water participates in proton transport across cellular membranes, crucial for mitochondrial ATP production.",
    "Saliva, which is 99% water, contains enzymes like amylase that initiate the chemical digestion of carbohydrates.",
    "During intense exercise, maintaining hydration preserves blood flow to the skin for heat dissipation.",
    "Water acts as a shock absorber for the brain and spinal cord, protecting them from mechanical trauma.",
    "Adequate hydration supports the mucosal lining of the gastrointestinal tract, aiding in barrier function and immunity."
  ];

  // Turkish facts (Advanced & Professional)
  final List<String> _factsTr = [
    "Su, besinlerin emilimi için hidroliz dahil olmak üzere birçok biyokimyasal reaksiyonun birincil çözücüsüdür.",
    "Optimal hidrasyon, kan plazma hacmini koruyarak kardiyovasküler fonksiyonu ve kalp atım hacmini destekler.",
    "Sadece %2'lik dehidrasyon, psikomotor uyanıklık ve kısa süreli hafıza gibi bilişsel işlevleri önemli ölçüde bozabilir.",
    "Sodyum ve potasyum gibi elektrolitler, sinir impulsu iletimi için zar potansiyelini korumak adına suya ihtiyaç duyar.",
    "Büyük oranda sudan oluşan sinoviyal sıvı, eklem kıkırdağında sürtünmeyi azaltan Newtonyen olmayan bir yağlayıcı görevi görür.",
    "Su, yüksek ısı kapasitesi ve terleme sırasındaki buharlaşma yoluyla vücut ısısını termoregüle eder.",
    "Kronik dehidrasyon, idrar satürasyonunu artırarak ürolitiyazis (böbrek taşı) riskini yükseltebilir.",
    "Beynin glifatik sistemi, beta-amiloid dahil metabolik atıkları temizlemek için (çoğunlukla su olan) beyin omurilik sıvısına güvenir.",
    "Su, protein katlanması ve yapısal stabilite için kritiktir; hafif dehidrasyon bile enzim aktivitesini etkileyebilir.",
    "Hipohidrasyon kortizol seviyelerini artırarak fizyolojik stres tepkilerini şiddetlendirebilir.",
    "Su, mitokondriyal ATP üretimi için hayati olan hücresel membranlar arası proton taşınımına katılır.",
    "%99'u su olan tükürük, karbonhidratların kimyasal sindirimini başlatan amilaz gibi enzimler içerir.",
    "Yoğun egzersiz sırasında hidrasyonun korunması, ısı dağılımı için cilde giden kan akışını muhafaza eder.",
    "Su, beyin ve omurilik için mekanik travmalara karşı koruyucu bir şok emici görevi görür.",
    "Yeterli hidrasyon, gastrointestinal sistemin mukozal astarını destekleyerek bariyer fonksiyonunu ve bağışıklığı güçlendirir."
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
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
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
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.blueAccent,
              onPressed: _refreshFact,
            ),
          ],
        ),
      ),
    );
  }
}
