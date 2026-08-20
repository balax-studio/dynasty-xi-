# 🛠️ DYNASTY XI — GELİŞTİRME & DÜZELTME SPEC'İ
## "Nasıl olmalı" hedef-durum dokümanı

**Tarih:** 20 Ağustos 2026 · **Branch:** `main` @ `975e134`
**Kaynak referans:** `DYNASTY_XI_URETIM_DOKUMANI.md` (5138 satır)
**Kardeş doküman:** `DYNASTY_XI_DENETIM_RAPORU.md` (hata listesi)

---

## Bu doküman ne?

Denetim raporu **"ne bozuk"** sorusunu cevaplıyordu. Bu doküman **"ne olmalı"** sorusunu cevaplıyor.

Bu tur sıfırdan, farklı bir açıyla yapıldı: her mekanik, üretim dokümanındaki **orijinal tasarım spec'i ile satır satır karşılaştırıldı**. Bulguların çoğu "bug" değil — **spec'ten sapma** veya **hiç yazılmamış sistem**. İkisi de kodda sessizce duruyor, çünkü derleniyor ve testler geçiyor.

### Her madde şu formatta

| Alan | Anlamı |
|---|---|
| **Şu an** | Kodun bugünkü davranışı + tam konum |
| **Olması gereken** | Üretim dokümanı spec'i (§ referanslı) veya türetilmiş hedef |
| **Sapmanın oyuncuya etkisi** | Neden önemli |
| **Fonksiyon / şema** | Somut imza ve veri modeli değişikliği |
| **Kabul kriteri** | Yazılacak test |

### Öncelik etiketleri

- 🔥 **P0** — Bu olmadan çekirdek döngü çalışmıyor
- ⚡ **P1** — Sistem var ama etkisiz; oyunun derinliği burada
- 🎯 **P2** — Spec'te var, hiç yazılmamış
- 🔧 **P3** — Kalibrasyon / hijyen

---

# BÖLÜM A — MAÇ SONRASI BORU HATTI

> **Bu bölüm dokümanın kalbi.** Aşağıdaki 9 sistemin tamamı `playMatch()` içinde bir "hafta ilerlet" adımına bağlı olmadığı için ölü. Tek bir mimari düzeltme 9 sistemi birden açıyor.

## A-1 🔥 P0 · `playMatch()` bir hafta ilerletmiyor, sadece skor üretiyor

**Şu an**
`lib/application/providers/game_state_provider.dart:112-292`. Yaptıkları: skor simülasyonu, 4 gösterge deltası, fikstür/puan tablosu, menajer XP, sponsor süre tick'i, kriz değerlendirmesi. **Hepsi bu.**

**Olması gereken**
`playMatch()` bir *maç* fonksiyonu değil, bir **hafta ilerletme (tick) fonksiyonu** olmalı. Maç simülasyonu bu tick'in yalnızca ilk adımı.

```dart
Future<MatchResult?> playMatch({bool isLiveMode = false}) async {
  final current = currentState;
  if (current == null || current.isGameOver) return null;

  // ── FAZ 1: ÖN KONTROL ─────────────────────────────────
  await checkFacilityUpgrades();                    // A-6
  final fixture = _resolveNextFixture(current);     // A-9
  if (fixture == null) return _enterSeasonFinale(); // F-3

  // ── FAZ 2: SİMÜLASYON ─────────────────────────────────
  final result = MatchEngine(seed).simulate(setup);

  // ── FAZ 3: OYUNCU DURUMU (şu an tamamen eksik) ────────
  var squad = _applyMatchStats(current.userClub.squad, result);   // A-2
  squad     = _applyFitnessAndForm(squad, result);                // A-3
  squad     = _rollInjuries(squad, current);                      // A-4
  squad     = _applyMoraleTriggers(squad, result);                // A-5

  // ── FAZ 4: EKONOMİ ────────────────────────────────────
  final ledger = _advanceWeeklyEconomy(current, result);          // C-1..C-4

  // ── FAZ 5: İLERLEME & META ────────────────────────────
  final quests   = _advanceQuests(current, QuestTrigger.leagueMatch); // E-4
  final meters   = _applyMeterDeltas(...).onMatchCompleted();         // E-1
  final records  = _updateMuseumRecords(current, result);             // E-5
  final achieved = _evaluateAchievements(current);                    // E-6

  // ── FAZ 6: KART & KRİZ ────────────────────────────────
  final cards  = CardSelector.pickSessionCards(...);              // D-1
  final crisis = _evaluateCrisisWithCooldown(current);            // D-4

  // ── FAZ 7: COMMIT ─────────────────────────────────────
  final next = current.copyWith(...);
  if (meters.isSacked) return _triggerSacking(next);              // E-2
  state = AsyncValue.data(next);
  await _saveRepository.save(next);
  return result;
}
```

**Neden bu yapı**
Her faz saf (pure) bir yardımcı fonksiyon. Tek tek unit-test edilebilir, `playMatch` sadece orkestrasyon yapar. Şu anki 180 satırlık monolit test edilemiyor.

**Kabul kriteri**
`playMatch` gövdesi ≤ 40 satır; her `_faz` fonksiyonu için ayrı unit test.

---

## A-2 ⚡ P1 · Maç istatistikleri oyuncuya yazılmıyor

**Şu an**
`Player.goals`, `assists`, `appearances`, `cleanSheets`, `recentRatings`, `seasonRatings` alanları **modelde var** (`lib/domain/entities/player.dart:167-171`) ama **hiçbir yerde artmıyor**. Tek dokunan `season_transition.dart:98-101` ve o da sıfırlıyor.

**Olması gereken** (§11.5)

Maç sonrası her ilk-11 ve oyuna giren yedek için:

```
appearances += 1
goals       += o maçtaki gol
assists     += o maçtaki asist
cleanSheets += (kaleci/defans && yenilen gol == 0) ? 1 : 0
recentRatings = [...son 5, yeniPuan]        // kayan pencere, maks 5
seasonRatings = [...tümü, yeniPuan]
```

**Oyuncu maç puanı formülü (§11.5):**
```
puan = 6.0
     + gol × 1.2
     + asist × 0.8
     + pozisyonelKatkı            // pas isabeti, ikili mücadele, kurtarış
     − yenilenGolPayı             // sadece defans/kaleci
     − sarı × 0.3 − kırmızı × 1.5
     ± uniform(−1,1) × (100 − consistency) / 45
puan = clamp(puan, 1.0, 10.0)
```

**Sapmanın etkisi**
`Player.form` bu puanlardan türemesi gerekiyor (§9.5: "Son 5 maç puanı ortalaması"). Form ölü → oyuncu değeri formülündeki `formFactor` ölü → transfer pazarı statik. Zincirleme 4 sistem düşüyor.

**Fonksiyon**
```dart
// lib/domain/sim/match_stats_applier.dart  (YENİ DOSYA)
class MatchStatsApplier {
  static List<Player> apply({
    required List<Player> squad,
    required MatchResult result,
    required bool isUserHome,
  });

  static double calculateRating({
    required Player player,
    required MatchResult result,
    required int goals,
    required int assists,
  });
}
```

**Kabul kriteri**
2 gol atan santrfor: `goals == 2`, `appearances == 1`, `recentRatings.last >= 8.0`.

---

## A-3 ⚡ P1 · Fitness / Form / Keskinlik maç oynamaktan etkilenmiyor

**Şu an**
`fitness`, `form`, `sharpness` alanları mevcut ve varsayılanları `100 / 6.5 / 85`. Bunları değiştiren **tek** kod yolu RPG diyalog ekranı (`game_state_provider.dart:1329-1331` ve `player_dialogue_screen.dart:67-68`). **Maç oynamak hiçbirini değiştirmiyor.**

Sonuç: fitness sonsuza kadar 100 → yorgunluk yok → **rotasyon anlamsız** → 18 kişilik kadro tutmanın hiçbir sebebi yok.

**Olması gereken** (§9.5)

| Durum | Aralık | Maç etkisi | İyileşme |
|---|---|---|---|
| **Fitness** | 0–100 | Oynayan −18, yedek −4, oynamayan 0 | Dinlenme +12/gün · Kondisyon Merkezi çarpanı |
| **Form** | 1.0–10.0 | `recentRatings` ortalaması | — (türetilmiş) |
| **Keskinlik** | 0–100 | Oynayan +15, oynamayan −5 | Maç oynayarak |
| **Moral** | 0–100 | Tetikleyici tablosu (A-5) | Kartlar, zam, kaptanlık |

**Fitness performansa bağlanmalı:** `TeamStrength` hesabında oyuncu katkısı `× (0.70 + fitness/333)` → 0.70–1.00 aralığı. Şu an fitness hiç okunmuyor.

**Fonksiyon**
```dart
// lib/domain/sim/player_condition.dart  (YENİ DOSYA)
class PlayerCondition {
  static Player afterMatch(Player p, {required PlayerMatchRole role});
  static Player afterRest(Player p, {required int days, required int medicalLevel});
  static double get formFromRatings;   // recentRatings ortalaması
}

enum PlayerMatchRole { started, substitute, unused, injured }
```

**Kabul kriteri**
3 maç üst üste oynayan oyuncu: `fitness <= 50`; 1 maç dinlenen: `fitness` artmış.

---

## A-4 🔥 P0 · Sakatlık sistemi hiç tetiklenmiyor

**Şu an**
`injuryMatchesLeft` / `injuryType` / `injurySeverity` alanları var, `isInjured` getter'ı var, `squad_screen.dart:690`'da 🚑 rozeti var — ama **kod tabanında hiçbir yer `injuryMatchesLeft`'i pozitif bir değere set etmiyor**. `MatchEventType.injury` (`match_events.dart:12`) sadece log satırı üretiyor. Tek azaltma `player_growth.dart:17`, o da yalnızca sezon geçişinde.

**Olması gereken** (§9.6)

```
SakatlıkOlasılığı(maç) = 0.030
  × (1 + injuryProneness / 100)
  × (2.0 − fitness / 100)
  × tıbbiMerkezÇarpanı(0.48–1.00)
  × taktikYoğunluğuÇarpanı(0.85–1.35)
  × yaşÇarpanı(age >= 31 ? 1.25 : 1.00)
```

| Şiddet | Olasılık | Süre (spec: gün) | **Maç karşılığı** | Ek etki |
|---|---|---|---|---|
| Hafif (darbe) | %55 | 1–3 gün | **0 maç** | Fitness −20 |
| Orta (kas) | %30 | 4–10 gün | **1–2 maç** | Kadro dışı |
| Ciddi (bağ) | %12 | 2–5 hafta | **3–7 maç** | Kadro dışı + dönüşte OVR −2 |
| Ağır (kırık) | %3 | 6–14 hafta | **8–20 maç** | OVR −4, Pace kalıcı −2 riski |

> ⚠️ **Spec–model uyumsuzluğu:** Doküman süreleri **gün/hafta** cinsinden veriyor, model `injuryMatchesLeft` (maç bazlı) tutuyor. Yukarıdaki "maç karşılığı" sütunu §14.3'teki "haftada 21 maç" temposundan türetildi. **Karar gerekiyor:** ya modele `injuryDaysLeft` eklenip gerçek zamana bağlanacak, ya da doküman maç bazına revize edilecek. Öneri: **maç bazlı kalsın** — oyunun geri kalan tüm timer'ları (sponsor `weeksRemaining`, kredi `remainingWeeks`) maç bazlı tick'leniyor, tutarlılık kazanılır.

**§9.6'nın en önemli cümlesi:**
> *"Sakatlık daima bir karar kartı üretir: 'Riskli ama oynatabilirim / Dinlendireyim / Sağlık kuruluna sor'."*

Yani sakatlık **ceza değil, karar** olmalı. `CardDatabase`'e `injury_decision` kategorisinde kart ailesi eklenmeli ve `_rollInjuries` sonucu `pendingCards`'a enjekte edilmeli.

**Fonksiyon**
```dart
// lib/domain/sim/injury_engine.dart  (YENİ DOSYA)
class InjuryEngine {
  static InjuryRoll roll({
    required Player player,
    required int medicalCenterLevel,
    required String tacticalStyle,
    required DeterministicRng rng,
  });

  static Player recoverOneMatch(Player p, {required int medicalCenterLevel});
  static DecisionCard buildInjuryCard(Player p, InjurySeverity severity);
}

class InjuryRoll {
  final bool occurred;
  final InjurySeverity severity;
  final String injuryType;     // "Hamstring", "Ayak bileği burkulması", ...
  final int matchesOut;
}
```

**Şema değişikliği**
`FacilityType`'a `medicalCenter` zaten var (`facility.dart:10`) — çarpanı `0.48 + (5 - level) × 0.13` olarak bağla.

**Kabul kriteri**
10.000 maçlık simülasyonda sakatlık oranı %2.5–4.0 arasında; `injuryProneness: 90` olan oyuncu `injuryProneness: 10` olandan ≥2× sık sakatlanıyor; sakat oyuncu `starting11Ids`'e otomatik girmiyor.

---

## A-5 ⚡ P1 · Moral tetikleyici tablosu yazılmamış

**Şu an**
`morale` sadece manuel eylemlerde değişiyor (prim verme, forma numarası, ceza, sözleşme). **Maç sonucu morali etkilemiyor.**

**Olması gereken** (§9.5)

```
+6  Galibiyet (kadroda)          −5  Mağlubiyet
+3  Gol/asist                    −4  Üst üste 3 maç kadro dışı
+8  Sözleşme yenileme (iyi)      −10 Zam talebi reddedildi
+5  Takım arkadaşı transferi     −7  Kaptan satıldı
+4  Kaptanlık verildi            −12 Transfer talebi reddedildi
+10 Kupa                         −6  Küme düşme
```

Kişilik çarpanı uygulanmalı — `PersonalityType.moraleSensitivity` getter'ı **zaten var** (`player.dart:47`: temperamental ×1.5, humble ×0.7) ama hiçbir yerde kullanılmıyor.

```dart
final delta = (baseTrigger * player.personality.moraleSensitivity).round();
```

**Kabul kriteri**
`temperamental` oyuncu mağlubiyette `humble` oyuncudan ≥2× moral kaybediyor.

---

## A-6 🔥 P0 · Tesis inşaat timer'ı maç tick'ine bağlı değil

**Şu an**
`checkFacilityUpgrades()` (`game_state_provider.dart:1777`) yalnızca `_init()` ve `claimSponsorReward()` içinden çağrılıyor. Ekranlarda `Timer.periodic` yok — geri sayım `build()` anında donuyor.

**Olması gereken**
1. `playMatch()` başında **ve** `resumed` lifecycle olayında `checkFacilityUpgrades()`
2. `facilities_screen` + `facility_detail_screen` → `Timer.periodic(Duration(seconds: 1))` ile canlı geri sayım
3. Tamamlanınca **kutlama modalı** — `facility_visual_widget.dart:274` içinde `isCelebration` parametresi **zaten var ama hiç `true` gönderilmiyor**

```dart
// main.dart — MainLayoutScreen
@override
void didChangeAppLifecycleState(AppLifecycleState s) {
  if (s == AppLifecycleState.resumed) {
    ref.read(gameStateProvider.notifier).checkFacilityUpgrades();
  }
}
```

**Kabul kriteri**
Fake clock ile inşaat başlat → süre ilerlet → `playMatch()` → tesis seviyesi artmış olmalı.

---

## A-7 🎯 P2 · Maç sonu özet ekranı hiç açılmıyor

**Şu an**
`lib/presentation/widgets/match_reward_dialog.dart` **hiçbir dosya tarafından import edilmemiş**. Hızlı sim sonrası `office_screen.dart:612` yalnızca `SnackBar` gösteriyor.

**Olması gereken** (§11.5 — birebir mockup dokümanda var)

```
┌─── MAÇ SONU ────────────────────────────┐
│  ANKARA GÜCÜ  2 - 1  DEMİRSPOR          │
│  ⭐ Maçın Adamı: Arslan Demir (8.4)      │
│     2 gol · 4 şut · 89% pas             │
│  Kasa      +₣18.400  ▲                  │
│  Taraftar  +3        ▲                  │
│  Soyunma   +5        ▲                  │
│  Yönetim   +2        ▲                  │
│  📈 Lig: 8. → 6.                        │
│  [ Devam ]                              │
└─────────────────────────────────────────┘
```

§11.5: *"Sonrasında **her zaman** 1–2 karar kartı gelir"* — maç sonucundan tetiklenmiş (yenilgide basın, galibiyette sponsor, sakatlıkta sağlık). Bu bağlam tetikleyicisi de yok (bkz. D-2).

**Kabul kriteri**
`playMatch` → dialog açılıyor; MOTM `recentRatings` en yükseği; lig sırası değişimi doğru.

---

## A-8 🔧 P3 · AI maçlarında tek kalan kulüp atlanıyor

**Şu an** `game_state_provider.dart:189` → `for (var i = 0; i + 1 < otherClubs.length; i += 2)`. Tek sayıda kulüp varsa sonuncusu o hafta hiç maç oynamıyor.

**Olması gereken** Bay (bye) rotasyonu veya çift sayı garantisi. En temizi: fikstür üretiminde round-robin kullanıp AI maçlarını da fikstürden okumak (rastgele eşleştirme yerine).

---

## A-9 🔥 P0 · Fikstür bulunamayınca 1. hafta tekrar oynanıyor

**Şu an**
`game_state_provider.dart:117-120` ve `match_screen.dart:61-64`:
```dart
orElse: () => current.currentLeague.fixtures.first
```
O matchday'de oynanmamış maç yoksa **1. haftanın maçı tekrar oynanıyor** ve puan tablosuna ikinci kez yazılıyor.

**Olması gereken**
```dart
final fixture = current.currentLeague.fixtures
    .where((f) => f.matchday == current.clock.matchday && !f.isPlayed)
    .firstOrNull;
if (fixture == null) return _enterSeasonFinale(current);  // F-3
```

**Kabul kriteri**
21. maç sonrası `playMatch()` → sezon finali akışı; puan tablosunda hiçbir takımın `played` sayısı 21'i geçmiyor.

---

# BÖLÜM B — OYUNCU MODELİ VE FORMÜLLER

> Bu bölümdeki maddeler "bozuk" değil — **spec'ten sapmış**. Kod çalışıyor ama tasarımcının hesapladığı denge tutmuyor.

## B-1 ⚡ P1 · OVR ağırlıkları spec ile uyuşmuyor

**Şu an** `lib/domain/entities/player.dart:339-390`

**Karşılaştırma:**

| Poz | Özellik | Spec (§9.2) | Kod | Fark |
|---|---|---|---|---|
| **GK** | technique | .15 | **.00** | Kalecinin ayak tekniği hiç sayılmıyor |
| GK | physical | .20 | .30 | +50% |
| GK | pace | .05 | .10 | 2× |
| **CB** | technique | .08 | **.00** | Top çıkarabilen stoper yok |
| CB | physical | .22 | .25 | — |
| **CM** | pace | .10 | **.00** | Box-to-box orta saha ödüllenmiyor |
| CM | defending | .16 | **.00** | Ball-winner arketipi yok |
| CM | shooting | .10 | .15 | — |
| **AM** | defending | .04 | **.00** | — |
| **ST** | shooting | .34 | .? | doğrulanmalı |

**Sapmanın etkisi**
Spec 7 özelliğin **tamamını** her pozisyonda ağırlıklandırıyor (toplam 1.00). Kod her pozisyonda 5 özellik kullanıp 2'sini sıfırlıyor. Sonuç: **oyuncu arketipleri yok**. "Hızlı stoper" ile "yavaş ama güçlü stoper" aynı OVR'yi alıyor → scouting kararı anlamsızlaşıyor, `altPositions` sistemi değersizleşiyor.

**Olması gereken**
Ağırlıkları `Map<Position, Map<Attribute, double>>` sabitine taşı, §9.2 tablosunu birebir gir, toplamın 1.00 olduğunu bir testle doğrula.

```dart
// lib/domain/entities/position_weights.dart  (YENİ DOSYA)
const kPositionWeights = <Position, PositionWeight>{
  Position.gk: PositionWeight(pace: .05, technique: .15, shooting: .00,
                              passing: .10, defending: .40, physical: .20, mentality: .10),
  // ... 8 pozisyon
};
```

**Kabul kriteri**
`for (final w in kPositionWeights.values) expect(w.sum, closeTo(1.0, 0.001));`

---

## B-2 ⚡ P1 · Oyuncu değeri formülü eksik ve yanlış kalibre

**Şu an** `player.dart:393-402`

| Bileşen | Spec (§9.9) | Kod | Sonuç |
|---|---|---|---|
| Yaş ≤19 | **1.55** | 1.35 | Gençler ucuz |
| Yaş 24–27 | **1.00** | 1.15 | Zirve yaş pahalı |
| Yaş 31–33 | **0.38** | 0.90 | ⚠️ **2.4× fazla** |
| Yaş 34+ | **0.15** | 0.65 | ⚠️ **4.3× fazla** |
| Potansiyel | × **0.028** | × 0.015 | Genç primi yarı yarıya |
| Sözleşme 3+ | **1.15** | 1.10 | — |
| Sözleşme 1 sezon | **0.72** | 0.85 | — |
| Sözleşme **son 6 ay** | **0.40** | ❌ **yok** | Bosman baskısı yok |
| **Lig çarpanı** | **0.55 + (21−tier) × 0.048** | ❌ **tamamen yok** | Lig kademesi değeri etkilemiyor |
| Form | 1 + form × 0.035 | (form/6.5).clamp | Yakın ama farklı |

**Sapmanın etkisi**
1. **34 yaşındaki oyuncu hâlâ değerli** → kadro yenileme baskısı yok, yaşlanma dramı ölü
2. **Sözleşme bitimi değeri düşürmüyor** → §9.10'daki *"Sözleşme biterse oyuncu bedava gider → gerçek kayıp → loss aversion motoru"* çalışmıyor
3. **Lig çarpanı yok** → Lig 20'de de Lig 1'de de aynı oyuncu aynı fiyat → terfi etmenin ekonomik anlamı yok

**Olması gereken** — §9.9 formülünü birebir uygula:
```
Deger = tabanDeger × yasCarpani × potansiyelCarpani × sozlesmeCarpani
        × formCarpani × ligCarpani
```
`marketValue` getter'ı `leagueTier`'a ihtiyaç duyduğu için imza değişmeli:
```dart
int marketValueIn(int leagueTier);   // getter yerine metot
int get marketValue => marketValueIn(20);  // geriye dönük uyumluluk
```

**Kabul kriteri**
Dokümandaki sağlama örneği geçmeli: *OVR 72, yaş 21, potansiyel 86, 3 sezon, form +1, Lig 10 → ≈ ₣29.400.*

---

## B-3 🎯 P2 · Beklenen maaş formülü hiç yok

**Şu an** Maaş elle giriliyor; pazarlıkta bir referans değeri yok.

**Olması gereken** (§9.10)
```
BeklenenMaaş(haftalık) = Değer × 0.0038 × egoÇarpanı × ligÇarpanı
egoÇarpanı: Ego 1.35 · Kariyerist 1.20 · Profesyonel 1.00 · Sadık 0.85
```

Bu olmadan `NegotiationEngine` ve `ContractRenewalDialog` "adil teklif nedir" bilmiyor.

```dart
// player.dart
int expectedWeeklyWage(int leagueTier);
bool isUnderpaid(int leagueTier) => weeklyWage < expectedWeeklyWage(leagueTier) * 0.85;
```

**Bağlantı:** §9.10 *"Sözleşme bitimine 1 sezon kala **otomatik karar kartı** üretilir"* — bu tetikleyici de yok (bkz. D-2).

---

## B-4 ⚡ P1 · Gelişim formülü: oynama süresi çarpanı ölü

**Şu an** `lib/domain/progression/player_growth.dart:45`
```dart
final appearancesFactor = player.appearances >= 10 ? 1.25
                        : (player.appearances >= 5 ? 1.0 : 0.75);
```
`appearances` hiç artmadığı için (A-2) bu çarpan **her oyuncu için sonsuza kadar 0.75**.

**Olması gereken** (§9.3)
```
oynamaCarpani = clamp(dakika_oynanan / 1200, 0.35, 1.25)
moralCarpani  = 0.75 + (morale / 200)          // kod: (morale/85).clamp(0.80,1.15)
tesisCarpani  = 1.00–2.10                       // kod: max 1.48 (lvl 5)
```

> §9.3'ün kritik notu: *"genç oyuncu oynatmazsan gelişmiyor. Bu, kadro rotasyonunu anlamlı bir strateji kararı haline getiriyor."* — A-2 + A-3 + B-4 birlikte çözülmeden rotasyon stratejisi doğmuyor.

**Ek sorun — özellik dağıtımı bozuk** (`player_growth.dart:53-59`):
```dart
final newTechnique = (player.technique + deltaInt).clamp(30, 99);
final newShooting  = (player.shooting  + deltaInt).clamp(30, 99);
final newPassing   = (player.passing   + deltaInt).clamp(30, 99);
final newDefending = (player.defending + deltaInt).clamp(30, 99);
```
Aynı `deltaInt` 4 özelliğe birden ekleniyor → **santrfor da defans gelişiyor**, stoper de şut. `pace` ise yalnızca `deltaInt > 2` ise +1 → kanat oyuncusu neredeyse hiç hızlanmıyor.

**Olması gereken:** Artış, **pozisyon ağırlıklarına göre** (B-1) dağıtılmalı:
```dart
final gain = deltaInt.toDouble();
for (final attr in Attribute.values) {
  newValue[attr] = value[attr] + (gain * kPositionWeights[position]![attr]! * 7).round();
}
```

**Ek edge-case:** `ageFactor` 27+ için negatif (`-0.25`, `-0.80`). `(potential - ovr)` de negatifse (potansiyelin altına düşmüş yaşlı oyuncu) çarpım **pozitif** çıkıp 33 yaşındaki oyuncu gelişir. Guard gerekli.

---

## B-5 ⚡ P1 · Takım kimyası spec'in tamamen farklı bir formülünü kullanıyor

**Şu an** `lib/domain/sim/team_chemistry.dart:26+` — `baseScore = 75`, sadece kişilik tiplerine bakıyor (lider/sadık/asi/paragöz).

**Olması gereken** (§9.8)
```
TakımUyumu = 100
  − (yanlış_pozisyon_oyuncu_sayısı × 6)
  − (30 günden yeni transfer sayısı × 3)     // uyum süresi
  + (aynı_uyruk_kümesi_bonusu, maks +8)
  + (5+ sezon birlikte oynayan çift başına +2, maks +10)
  + (kaptan varsa +4)
  + Analiz Merkezi bonusu
Çarpan = 0.88 + (TakımUyumu / 500)            // 0.88–1.08
```

**Kodda hiç olmayanlar:** yanlış pozisyon cezası, yeni transfer uyum süresi, kaptan bonusu, Analiz Merkezi tesisi bonusu.

**Sapmanın etkisi**
Kimya, **taktik kararlarından** değil yalnızca kadro kompozisyonundan etkileniyor. Oyuncuyu yanlış mevkide oynatmanın bedeli yok → `altPositions` alanı ve "Otomatik Diz" butonunun stratejik değeri sıfır.

**Ek:** Fonksiyon `squad`'ın tamamına bakıyor; **ilk 11'e** bakmalı (yedekteki 3 asi oyuncu kimyayı bozmamalı).

```dart
static TeamChemistry calculate({
  required List<Player> startingXI,     // squad değil
  required List<Player> fullSquad,
  required String formation,
  required int analysisCenterLevel,
});
```

---

## B-6 🎯 P2 · Kadro büyüklüğü kuralı yok

**Şu an** Yalnızca min-11 guard'ı (`game_state_provider.dart:1077, 1140`). Üst sınır yok.

**Olması gereken** (§9.7)
- Min 16, maks `18 + floor(KulüpSv / 5)`, mutlak maks 30
- Yaş 15–17 oyuncular sadece Akademi Sv.2+ ile kadroya alınabilir
- İlk 11 + 7 yedek, maç başına 5 değişiklik

> ⚠️ Bu kural **KulüpSv'ye bağlı ve KulüpSv hiç yok** (bkz. E-3). Önce o yazılmalı.

---

# BÖLÜM C — EKONOMİ

## C-1 🔥 P0 · Haftalık gider hiç kasaya yansımıyor

**Şu an**
`FinancialStatementCalculator.calculateWeeklyStatement()` (`financial_statement.dart:195`) yalnızca `finance_screen.dart:44`'te **ekrana çizmek için** çağrılıyor. `playMatch()` sadece ev sahibi maç günü hasılatını ekliyor.

**Kasaya hiç girmeyen/çıkmayan kalemler:**

| Kalem | Spec (§15.3) | Kodda |
|---|---|---|
| Oyuncu maaşları | `Σ(oyuncu.haftalıkMaaş)` | ❌ |
| Personel maaşları | `+ personelMaaşları` | ❌ |
| Tesis bakımı | `Σ(tesis.bakım)` | ❌ |
| Seyahat gideri | `deplasman × (150 + ligBonusu)` | ❌ hiç yok |
| Tıbbi gider | `sakat × 400 × şiddet` | ❌ hiç yok |
| Kredi taksiti | — | ❌ (C-2) |
| **Sponsor haftalık geliri** | musluk %18 | ❌ sadece ekranda |
| **Yayın geliri** | musluk %26 | ❌ sadece ekranda |
| Mevduat faizi | — | ❌ sadece ekranda |
| Maç günü hasılatı | musluk %34 | ✅ tek çalışan |

**Sapmanın etkisi**
Ekonominin **%66'sı sanal**. §15.5'teki musluk/lavabo oranı hedefi `1.16` — mevcut kodda pratikte **∞** (lavabolar kapalı). Bu, oyunun en temel gerilim kaynağını yok ediyor: §15.4'teki *"Kâr marjı hedefi %14–20 — oyuncu her zaman 'biraz daha para lazım' hissetmeli"*.

**Olması gereken**
```dart
// lib/domain/economy/weekly_ledger.dart  (YENİ DOSYA)
class WeeklyLedger {
  final int matchDayRevenue, broadcasting, sponsorship, merchandise, treasuryInterest;
  final int playerWages, staffWages, facilityUpkeep, travel, medical, loanInstallment;
  int get totalIncome;
  int get totalExpense;
  int get net;
}

class WeeklyLedgerCalculator {
  static WeeklyLedger calculate({
    required GameState state,
    required MatchResult result,
    required bool wasHome,
  });
}
```
`playMatch` tek satırla uygular: `deltaCash: ledger.net`. `finance_screen` **aynı** hesaplayıcıyı önizleme için kullanır → tek doğruluk kaynağı.

**Kalibrasyon hedefi (§15.4):**

| Lig | Haftalık Gelir | Haftalık Gider | Net |
|---|---|---|---|
| 20 | ₣28.000 | ₣21.000 | +₣7.000 |
| 16 | ₣95.000 | ₣72.000 | +₣23.000 |
| 10 | ₣760.000 | ₣615.000 | +₣145.000 |
| 1 | ₣19M | ₣16.3M | +₣2.7M |

**Kabul kriteri**
Lig 20 başlangıç kulübü ile 10 maç simüle et → haftalık net ₣5.000–9.000 bandında; musluk/lavabo oranı 1.10–1.25.

---

## C-2 🔥 P0 · Banka kredisi ne taksit ödüyor ne kapanıyor

**Şu an — iki ayrı hata birleşiyor:**

1. `BankLoan.payWeeklyInstallment()` (`financial_statement.dart:109`) prod kodunda **hiç çağrılmıyor** → `remainingWeeks` sonsuza kadar sabit, kasadan hiç para çıkmıyor.
2. `repayBankLoanEarly()` (`game_state_provider.dart:1509`) `activeLoan: null` gönderiyor ama `copyWith` `activeLoan ?? this.activeLoan` yazıyor (`game_state.dart:171`) → **null no-op**. Oyuncu parayı ödüyor, borç ekranda kalıyor.

**Sonuç:** Kredi = **geri ödemesiz bedava para**. §4377'deki tasarım niyeti (*"Banka ₣500.000 kredi veriyor. Haftalık ₣12.000 geri ödeme, 50 hafta."*) tamamen ölü.

**Olması gereken**
```dart
// GameState.copyWith
GameState copyWith({
  BankLoan? activeLoan,
  bool clearLoan = false,        // ← EKLE (headCoach/crisis deseninin aynısı)
  ...
}) => GameState(
  activeLoan: clearLoan ? null : (activeLoan ?? this.activeLoan),
);
```
```dart
// playMatch faz 4 içinde
if (current.activeLoan != null) {
  final loan = current.activeLoan!.payWeeklyInstallment();
  ledgerLoanInstallment = current.activeLoan!.weeklyPayment;
  nextLoan = loan.isPaidOff ? null : loan;
  if (loan.isPaidOff) log('🎉 Banka kredisi tamamen kapandı!');
}
```

**Ek kural (spec'te yok, önerilir):** Kasa taksidi karşılamıyorsa → `boardTrust −8` + "Ödeme Gecikmesi" kriz kartı. Bu, krediyi **gerçek bir risk** yapar.

**Kabul kriteri**
10 haftalık kredi → 10 `playMatch` sonra `activeLoan == null` ve toplam çıkan nakit `totalRepayment`'a eşit. Erken kapatmada `activeLoan == null`.

---

## C-3 🔥 P0 · Oyuncu kiralama sistemi zamansız ve yanlış bağlanmış

**Şu an**
- `LoanDeal` (`transfer_models.dart:6-38`) içinde `weeksRemaining` **yok**; `seasons` hiç azalmıyor
- `weeklyWageToPay` getter'ı var ama **hiçbir yerde kasadan düşülmüyor**
- `loan_contract_summary_modal.dart:173` kiralamayı **`buyPlayer()` ile** yapıyor → kiralık oyuncu kalıcı satın alınıyor
- `loanPlayer()` (`game_state_provider.dart:2167`, giden kiralama) **hiç çağrılmıyor**

**Olması gereken** (§10.2)

| Kanal | Ne zaman | Maliyet | Gelişim | Amaç |
|---|---|---|---|---|
| Kiralık (alma) | Transfer dönemi | Maaş payı | Gelişim senin değil | Kısa vadeli güç |
| Kiralık (verme) | Transfer dönemi | — | — | Genç gelişimi + maaş tasarrufu |

```dart
class LoanDeal {
  final Player player;
  final String parentClubName;
  final double borrowingClubWageShare;
  final int buyoutClause;
  final int weeksRemaining;        // ← EKLE
  final bool isOutgoing;           // ← EKLE (alma mı verme mi)
  final bool developmentCredited;  // ← EKLE (§10.2: alınan kiralıkta gelişim senin değil)
}
```
```dart
Future<bool> loanInPlayer(LoanDeal deal);    // yeni — modal buna bağlanacak
Future<bool> loanOutPlayer(Player p, String toClub, int wageShare, int buyout);
```
`playMatch` tick'i: `weeksRemaining--` → 0'da oyuncu ana kulübe döner + bildirim + buyout teklifi kartı.

**Kabul kriteri**
21 haftalık kiralık → 21 `playMatch` sonra oyuncu kadrodan çıkmış; her hafta `weeklyWageToPay` kadar nakit çıkmış.

---

## C-4 🔧 P3 · Tesis maliyet/süre üsteli spec ile birebir doğrulanmalı

**Şu an** `lib/domain/entities/facility.dart:52-65`
```dart
final cost     = type.baseCost * math.pow(3.9, nextLevel - 2);
final duration = type.baseDurationMinutes * math.pow(2.7, nextLevel - 2);
```

**Spec (§C.4)**
```
tesisMaliyet = tabanMaliyet × 3.9^(sv−1)
tesisSüre    = tabanSüre × 2.7^(sv−1), maks 48 sa
```

`sv`'nin "hedef seviye" mi "mevcut seviye" mi olduğu dokümanda net değil. Kod `nextLevel - 2` kullanıyor; `sv = nextLevel` yorumuyla **bir kademe ucuz** kalıyor (Sv1→2 geçişi `3.9^0 = 1×` yerine `3.9^1` olmalıydı).

**Yapılacak:** §8.3'teki *"Tesis Seviye Tablosu — Örnek: Stadyum"* sayılarıyla sağlama yap, hangi yorumun doğru olduğunu belirle ve **testle sabitle**. Bu, tüm ilerleme temposunu (pacing) etkilediği için tahminle bırakılmamalı.

**Kabul kriteri**
`facility_costs_test.dart` — §8.3 tablosundaki her satır için `upgradeCost` ve `upgradeDurationMinutes` beklenen değeri veriyor.

---

## C-5 🎯 P2 · Transfer dönemi (window) yok

**Şu an** `transferWindow` / `deadline` kavramı kod tabanında **hiç geçmiyor**. Transfer her an açık.

**Olması gereken** (§10.3, §14.3)
- Transfer dönemi Pazartesi açılır, **Cumartesi 12:00 kapanır**
- §14.3: *"Cmt: ... Transfer deadline 12:00"* + *"Deadline Day indirimleri"* live-ops kancası
- Kapalıyken `signPlayer` / `sellPlayer` / `loanInPlayer` reddedilmeli, UI kilitli görünmeli

```dart
// GameState
bool get isTransferWindowOpen => clock.matchday <= 15;   // §14.3 Cmt = ~15. maç
```

**Neden önemli:** Deadline Day, dokümanda **en yüksek DAU/IAP günü** olarak tasarlanmış (§14.3). Şu an hiç yok.

---

# BÖLÜM D — KART MOTORU

## D-1 🔥 P0 · Kart zincirleri (story arcs) tamamen ölü

**Şu an**
- `Card.chainId` alanı var (`card.dart:88`)
- `GameState.activeChains` alanı var ve `card_effects.dart:33` tarafından **yazılıyor**
- Ama `CardSelector` **`activeChains`'i hiç okumuyor** (`card_selector.dart` içinde tek referans yok)

Yani zincir ilerlemesi state'te birikiyor, hiçbir zaman kart seçimini etkilemiyor.

**Olması gereken** (§12.4 — dokümanda hazır pseudo-kod var)
```dart
Card selectNextCard(GameState s) {
  // 1) Aktif zincir varsa öncelik (Zeigarnik)
  final chain = s.activeChains.entries
      .where((ch) => _readyToAdvance(ch, s))
      .firstOrNull;
  if (chain != null) return _nextCardInChain(chain);
  ...
}
```

**Neden kritik**
§12.5: *"Zincir = 2–6 kartlık, günlere yayılan hikâye. **Zeigarnik etkisinin ana motoru.**"*
§6.5'te "Yarım Kalan İş Envanteri" diye ayrı bir bölüm var. §1.4'teki "Farklılaşma Üçlüsü"nün bir ayağı bu. **Oyunun rakiplerinden ayrıştığı iddia edilen mekanik hiç çalışmıyor.**

---

## D-2 ⚡ P1 · Bağlam tetikleyicisi (contextBoost) ve kriz enjeksiyonu yok

**Şu an** `card_selector.dart:44-84` — ağırlık formülünde yalnızca 3 bileşen var: gösterge baskısı, yenilik bonusu, kategori yorgunluğu.

**Olması gereken** (§12.4)

| Bileşen | Spec | Kodda |
|---|---|---|
| `baseWeight` | kart bazlı (1.0 tipik, nadir 0.15) | ❌ sabit `10.0` |
| `categoryWeight` | ×0.35 → ×1.25 toparlanma | ⚠️ string-hack (aşağıda) |
| `contextBoost` | maç kaybedildi / sakatlık / transfer | ❌ **yok** |
| `meterPressure` | düşük göstergeye dokunan kart ↑ | ✅ var |
| `noveltyBonus` | ×1.9 / ×1.3 / ×1.0 | ✅ var |
| `seasonRelevance` | sezon sonu ≠ sezon başı | ❌ **yok** |
| **Kriz kurtarma enjeksiyonu** | gösterge < 18 → %62 kurtarma kartı | ❌ **yok** |
| **Kart cooldown** | `s.now > c.cooldownUntil` | ❌ `Card.cooldownMatches` hiç okunmuyor |
| **Son 40 kart penceresi** | `!recentCardIds.contains(c.id)` | ⚠️ sayım var, pencere sınırı yok |

**Kategori yorgunluğu hatası** (`card_selector.dart:76-78`):
```dart
final lastId = state.recentCardIds.last;
if (lastId.contains(card.category.name)) weight *= 0.35;
```
Kart **ID string'i** içinde kategori adı geçiyor mu diye bakıyor. Kart id'leri kategori adını içermiyorsa hiç tetiklenmiyor; içeriyorsa da rastgele eşleşiyor. Gerçek çözüm: `GameState`'e `Map<CardCategory, double> categoryFatigue` ekle.

**§A-7 bağlantısı:** §11.5 *"maç sonrası her zaman 1–2 karar kartı gelir — maç sonucundan tetiklenmiş"* → `contextBoost` olmadan bu imkânsız.

---

## D-3 🎯 P2 · Sakatlık ve sözleşme kartları hiç üretilmiyor

§9.6: *"Sakatlık daima bir karar kartı üretir."*
§9.10: *"Sözleşme bitimine 1 sezon kala otomatik karar kartı üretilir."*

İkisi de yok. `CardDatabase.mvpCards` statik bir havuz; **runtime'da olay-tetikli kart üretimi** hiç yok.

```dart
// lib/domain/cards/dynamic_card_factory.dart  (YENİ DOSYA)
class DynamicCardFactory {
  static DecisionCard? fromInjury(Player p, InjurySeverity s);
  static DecisionCard? fromExpiringContract(Player p);
  static DecisionCard? fromUnhappyPlayer(Player p);       // Player.isUnhappy zaten var
  static DecisionCard? fromMatchResult(MatchResult r, GameState s);
}
```

> Not: `lib/domain/cards/extended_narrative_cards.dart` **hiçbir yerden import edilmemiş** — hazır bir kart havuzu kullanılmadan duruyor. Önce onu `CardDatabase`'e bağlamak en ucuz kazanç.

---

## D-4 ⚡ P1 · Kriz hattı cooldown'suz — aynı kriz sonsuz döngü

**Şu an** `CrisisTriggerEngine.evaluateCrisis()` tamamen anlık koşul tabanlı (`cash < 15000`, `boardTrust < 40`, `matchday == 7 || 14`). Krizi çözdükten sonra koşul hâlâ sağlanıyorsa **bir sonraki maçta birebir aynı kriz** geliyor.

Ayrıca `game_state_provider.dart:290-293`:
```dart
final finalState = updatedState.copyWith(
  activeCrisisCall: crisis,
  clearCrisisCall: crisis == null,   // ← çözülmemiş aktif kriz siliniyor
);
```

**Olması gereken**
```dart
// GameState
final int crisisCooldownMatches;      // ← EKLE
final List<String> resolvedCrisisIds; // ← EKLE

// playMatch
if (current.hasActiveCrisis) {
  nextCrisis = current.activeCrisisCall;          // koru, üzerine yazma
} else if (current.crisisCooldownMatches > 0) {
  nextCrisis = null;
  nextCooldown = current.crisisCooldownMatches - 1;
} else {
  nextCrisis = CrisisTriggerEngine.evaluate(current, exclude: resolvedCrisisIds);
}
```
`resolveCrisisCall` → `crisisCooldownMatches = 3` + `resolvedCrisisIds.add(id)` (son 5 tutulur, kayan pencere).

---

# BÖLÜM E — KARİYER VE İLERLEME

## E-1 🔥 P0 · Görevden alınma grace sayacı hiç çalışmıyor

**Şu an**
`ClubMeters.onMatchCompleted()` (`meter.dart:55`) — `consecutiveCriticalMatches`'i artıran **tek** metot, hiçbir yerden çağrılmıyor. `applyDeltas` sayacı olduğu gibi taşıyor. `isSacked` yalnızca `boardTrust == 0` tam eşitliğinde tetikleniyor.

**Olması gereken** (§12.8 — 3 aşamalı)

| Aşama | Koşul | UI |
|---|---|---|
| 1 | Yönetim < 30 | Sarı uyarı + "Başkan seni odasına çağırdı" kartı + **somut hedef**: "Önümüzdeki 3 maçta 5 puan" |
| 2 | Yönetim < 15 | Kırmızı alarm + ekranda geri sayım: "3 maç kaldı" |
| 3 | Yönetim = 0 **veya hedef tutmadı** | Görevden alındın |

> `GameState.sackingCountdownMatches` alanı **zaten var** (`game_state.dart:45`) ama hiç set/read edilmiyor. Aşama 2'nin geri sayımı tam olarak bu alan.
> `targetLeaguePosition` alanı da var — Aşama 1'in "somut hedef"i buna bağlanabilir.

---

## E-2 🔥 P0 · Görevden alınma sonrası akış tamamen yok

**Şu an**
`isGameOver` yalnızca `card_effects.dart:56`'da set ediliyor ve **`lib/presentation/` içinde hiçbir yerde okunmuyor**. `sacked_screen.dart` **hiçbir dosya tarafından import edilmemiş**. `recoverFromSacking()` ve `claimWinBackRewards()` orphan. `win_back_dialog.dart` orphan.

Sonuç: `playMatch()` `if (isGameOver) return null` diyor → **maç butonu sessizce hiçbir şey yapmıyor, oyun soft-lock**.

**Olması gereken** (§12.8 — dokümanda tam mockup var)

```
┌─── GÖREVDEN ALINDIN ────────────────────────┐
│  Ankara Gücü ile yollarınız ayrıldı.        │
│  Kariyer özeti: 47 maç · 18G · 12B · 17M    │
│  1 kupa · 2 terfi                           │
│  Ama menajer itibarın kaldı: 340 puan       │
│  Ve 3 kulüp seni istiyor:                   │
│  ▸ Bursa Yıldızspor (Lig 14) — İstikrarlı   │
│  ▸ Adana Şimşek     (Lig 9)  — Kriz içinde  │
│  ▸ Sivas Kalespor   (Lig 17) — Zengin başkan│
│  [ Kulüp seç ]                              │
└─────────────────────────────────────────────┘
```

§12.8'in tasarım gerekçesi aynen korunmalı:
- Ceza gerçek (kulüp, tesis, kadro kaybı → **loss aversion maksimum**)
- Ama oyun bitmiyor → öfkeyle silme yok
- **Menajer seviyesi, yetenekleri, itibarı kalıcı** → RPG ilerlemesi korunuyor
- Yeni kulüp seçimi = fresh start effect

**Denge hedefi:** Görevden alınma, ilk 30 günde oyuncuların **%12–18'inde** gerçekleşmeli (§12.8). Bu telemetri ile izlenir.

```dart
Future<void> triggerSacking(String reason);
Future<List<ClubOffer>> generateClubOffers(Manager m);   // itibara göre 3 teklif
Future<void> acceptClubOffer(ClubOffer offer);           // recoverFromSacking'in yerine
```

---

## E-3 🎯 P2 · Kulüp Seviyesi (KulüpXP/KulüpSv) hiç yok

**Şu an** `clubXp` / `clubLevel` kod tabanında **hiç geçmiyor**.

**Olması gereken** (§C.5, §8.6)
```
KulüpXP = Σ(tesisSv × 100) + galibiyet×25 + kupa×2000 + terfi×5000
KulüpSv = floor(sqrt(KulüpXP / 180)) + 1, maks 50
```

**Neden önemli:** §9.7'deki kadro büyüklüğü kuralı (`18 + floor(KulüpSv/5)`) bu değere bağlı → B-6 bunsuz yazılamaz. Ayrıca §7.4'teki "Aşamalı Açılım Takvimi" sistem kilitlerini kulüp seviyesine bağlıyor.

---

## E-4 🔥 P0 · Günlük görevlerin 2/3'ü tamamlanamaz

**Şu an**
`DailyQuest.currentCount` (`daily_quest.dart:9`) hiçbir yerde artmıyor. `claimDailyQuest` sadece `isClaimed`'i işaretliyor. `generateDailyQuests()` üç görev döndürüyor:

| Görev | Başlangıç | Durum |
|---|---|---|
| `q_tactics_check` | **1/1** (endowed progress) | ✅ claim edilebilir |
| `q_play_league_match` | 0/1 | ❌ **sonsuza kadar 0** |
| `q_club_development` | 0/2 | ❌ **sonsuza kadar 0** |

§7.2 (FTUE 7:30): *"Günlük Görevler ilk kez gösterilir (2'si zaten tamam → Endowed Progress)"* — spec **2 görevin** hazır tamam olmasını istiyor, kodda 1 tane var.

**Olması gereken**
```dart
enum QuestTrigger { leagueMatch, facilityUpgrade, cardChoice, transfer, scouting }

Future<void> _advanceQuest(QuestTrigger t, {int amount = 1});
```
`playMatch` → `leagueMatch`; `upgradeFacility` → `facilityUpgrade`; `chooseCardOption` → `cardChoice`.

**Ek eksik:** Görevler hiç **sıfırlanmıyor**. Gün değişiminde (`clock` veya gerçek tarih) yeni set üretilmeli, `isClaimed` sıfırlanmalı.

---

## E-5 ⚡ P1 · Kulüp Müzesi rekorları hardcoded

**Şu an** `trophy_room_screen.dart:47+`
```dart
const records = ClubMuseumRecords(
  biggestWinScore: '5-0',
  biggestWinOpponent: 'Kartaltepe SK',
  unbeatenStreak: 4,
  recordSigningName: 'Kerem Aktürkoğlu',
);
```
**Tamamen mock.** Oyuncunun gerçek kariyeriyle hiç ilgisi yok.

**Olması gereken**
`GameState`'e `ClubMuseumRecords` alanı; `playMatch` sonrası güncellenir:
- `biggestWin` — en yüksek averajlı galibiyet
- `unbeatenStreak` — mevcut + rekor yenilmezlik serisi
- `recordSigning` / `recordSale` — en yüksek bonservis (transfer akışında)
- `topScorerAllTime`

§14.3 madde 6: *"Kulüp Tarihi'ne kayıt düşülür"* — sezon finali akışının parçası.

---

## E-6 ⚡ P1 · Başarımlar kalıcı değil, menajer itibarı hiç değişmiyor

**Şu an**
`trophy_room_screen.dart:41-44` → `previouslyUnlockedIds: {}` **hardcoded boş**. Her `build`'de sıfırdan değerlendiriliyor → "yeni rozet açıldı!" bildirimi imkânsız. `GameState`'te `unlockedAchievementIds` alanı yok.

`Manager.reputation` yalnızca `save_repository.dart:140`'ta `30` olarak set ediliyor ve **hiç değişmiyor**.

Ayrıca `dynastyScore` hesabında `trophiesWon: (20 - state.currentLeague.tier)` proxy'si kullanılıyor — oysa gerçek `club.totalTrophies` alanı mevcut.

**Olması gereken** (§C.5, §14.7)
```
İtibar = Σ(maçPuanları) + kupa×150 + terfi×80 + hedef×60 − kovulma×120 + akademi×40
```
> İtibar §12.8'deki kovulma sonrası kulüp tekliflerinin **doğrudan girdisi**. E-2 bunsuz yazılamaz.

§14.7: 60+ rozet, 7 kategori (Kariyer, Transfer, Akademi, Maç, Ekonomi, Drama, Gizli). Rozetler **kozmetik + küçük kalıcı bonus** verir — asla güç değil.

```dart
// GameState
final Set<String> unlockedAchievementIds;   // ← EKLE + toJson/fromJson
```

---

# BÖLÜM F — TURNUVALAR VE TAKVİM

## F-1 ⚡ P1 · Kupa maçı MatchEngine kullanmıyor

**Şu an** `game_state_provider.dart:2029-2031`
```dart
final userGoals = 1 + _rng.nextInt(3);   // her zaman 1..3
final oppGoals  = _rng.nextInt(2);       // her zaman 0..1
```
Takım gücü, taktik, kadro, kimya **tamamen yok sayılıyor**. Kullanıcı pratikte hiç elenmiyor. `winnerId = homeScore >= awayScore` → beraberlik ev sahibine gidiyor; `CupMatch.homePenalties` / `awayPenalties` alanları **hiç kullanılmıyor**.

**Olması gereken**
- Lig maçıyla **aynı** `MatchEngine(setup)`
- Beraberlikte uzatma → penaltı serisi → `homePenalties`/`awayPenalties` doldurulur
- Kupa maçı da fitness/sakatlık/istatistik boru hattından geçer (A-2..A-5)
- Ödül: §14.3 *"Cmt: Kupa maçı"* — takvime bağlanmalı

## F-2 🔥 P0 · Avrupa Kıta Kupası kalıcı değil

**Şu an** `cup_tournament_screen.dart:37` — `ContinentalCup.generateTournament(...)` bir **StatefulWidget alanına** yazılıyor. `GameState`'te `continentalCup` alanı **yok**. Ekrandan çıkıp girince turnuva sıfırdan rastgele üretiliyor.

**Olması gereken**
`GameState`'e `ContinentalCup? continentalCup` + tam serileştirme. Üretim `_init()` / sezon geçişinde, katılım koşulu §14.5: **Lig ≤ 8**.

## F-3 ⚡ P1 · Sezon finali akışı yok, sezon geçişi manuel butona bağlı

**Şu an** `executeSeasonTransition()` yalnızca `league_screen.dart:274`'teki bir butondan çağrılıyor. Fikstür bitince otomatik tetiklenmiyor (A-9 ile birleşince tablo bozuluyor).

**Olması gereken** (§14.3 — peak-end rule için tasarlanmış 8 adımlı akış)
```
1. Son maç canlı oynanır (zorunlu Canlı Anlar)
2. Diğer maçlar eşzamanlı → "Diğer sahalardan haberler" akışı
3. Final lig tablosu animasyonu (takım takım yerleşir)
4. Terfi/kalma/düşme kararı — konfeti veya sessizlik
5. Yıllık ödüller: Sezonun Oyuncusu, En Golcü, Keşif, Sezonun Menajeri
6. Kulüp Tarihi'ne kayıt düşülür        → E-5
7. Sezon ödülleri açılır
8. Yeni sezon önizlemesi: "Sezon 4 teması: Genç Kan"
```
> Adım 5 (**En Golcü**) A-2 olmadan hesaplanamaz. Adım 6 E-5'e bağlı.

## F-4 🔥 P0 · Lig Gol/Asist Krallığı %100 sahte

**Şu an** `league_screen.dart:118-131` — 9 satır hardcoded `ScorerEntry` (Semih Kılıçsoy 8 gol, Alex de Souza 9 asist…). Sayılar hiç değişmiyor.

Altyapı **hazır ve kullanılmıyor**: `LeagueScorerBoard` (`match_depth_models.dart:59-95`) hiç instantiate edilmiyor.

**Olması gereken**
A-2 çözüldükten sonra `_buildLeaderboardsTab` doğrudan `gameState.currentLeague`'daki tüm kulüplerin kadrolarından türetir. AI kulüplerin oyuncu kadrosu yoksa, AI golleri **sanal golcülere** dağıtılmalı (kulüp başına 3–5 isim, deterministik seed).

---

# BÖLÜM G — KALICILIK VE ALTYAPI

## G-1 🔥 P0 · `activeCrisisCall` serileştirilmiyor

**Şu an** `game_state.dart:57` alan var, `copyWith`'te var, ama `toJson` (192-225) ve `fromJson` (227-364) **ikisinde de yok**. Kriz modalı açıkken uygulama kapanırsa kriz buharlaşıyor. 34 alanın kaçırılan tek alanı.

> **Tam tarama sonucu:** 148 dosyadaki tüm `final` alanlar `toJson`/`fromJson`/`copyWith` kapsamı açısından tarandı. Yalnızca **iki** boşluk var: bu ve `ProceduralFaceData` renkleri (aşağıda). Diğer tüm modeller tam kapsamlı.

## G-2 ⚡ P1 · `copyWith` null-temizleme desteği eksik

`GameState.copyWith` `X ?? this.X` deseni kullandığı için **hiçbir nullable alan null'a çekilemiyor**. `headCoach` ve `activeCrisisCall` için `clear*` bayrağı var, ama yok:
- `activeLoan` → **C-2'deki aktif hata**
- `gameOverReason`

**Kural olarak benimsenmeli:** Her nullable alan için `clearX` bayrağı zorunlu; bir lint testi bunu doğrulasın.

## G-3 🔧 P3 · `DeterministicRng` deterministik değil

`game_state_provider.dart:42` → `DeterministicRng(DateTime.now().millisecondsSinceEpoch)`. Sınıf adının vaadinin tersi.

§11.7 ("Determinizm ve Doğrulanabilirlik") diye ayrı bir bölüm var. Aynı kayıttan aynı maç tekrar üretilemiyor → bug reprodüksiyonu ve §11.8'deki "Sim Dengesi Doğrulama (Zorunlu Test)" imkânsız.

**Olması gereken:** `GameState`'e `rngSeed` ekle, notifier RNG'sini ondan türet, her tick'te ilerlet ve kaydet.

## G-4 🔧 P3 · Ölü / duplicate state alanları

| Alan | Sorun |
|---|---|
| `GameState.ticketPrice` (default **25**) | Hiçbir okuyucu yok; gerçek kaynak `Club.ticketPrice` (default **12**). Kaldırılmalı. |
| `GameState.winBonusPerMatch` | `setWinBonus` orphan, `playMatch` ödemiyor. Bağlanmalı. |
| `ProceduralFaceData` renkleri | `toJson`'da yok. `seed`'den türetiliyorsa doğru — **yorumla belgelenmeli**, palet değişirse tüm kayıtlı yüzler sessizce değişir. |

## G-5 🔧 P3 · Duplicate implementasyon çiftleri

| A | B | Durum |
|---|---|---|
| `renewContract`:746 | `renewPlayerContract`:2123 | `player_detail_screen` A'yı, `transfer_screen` B'yi çağırıyor → **davranış farkı** |
| `promoteYouthProspect`:1884 | `promoteU19Player`:492 | B kullanımda, A ölü |
| `signPlayer` / `buyPlayer` · `takeBankLoan` / `takeBankLoanPackage` · `unlockManagerPerk` / `spendSkillPoint` · `signSponsorshipDeal` / `signSponsorshipContract` | alias/wrapper | Tek metotta birleştir |

## G-6 🔧 P3 · Statik `const` marketler

`FreeAgentMarketGenerator.generateFreeAgents()` ve `LoanMarketGenerator.generateLoanCandidates()` `const [...]` döndürüyor. `signPlayer()` yalnızca `state.transferMarket`'ten çıkarma yapıyor → **aynı serbest futbolcu sınırsız kez, aynı `id` ile imzalanabiliyor**. Aynı sorun `StaffMarketCatalog` ve `HeadCoachCatalog`'da.

**Çözüm:** `GameState`'e `Set<String> signedMarketIds` ekle, üç listeyi de filtrele.

## G-7 🔧 P3 · `⚖` emoji'si iki kez case'lenmiş

`retro_pixel_icon.dart:150` → `scales`, `:178` → `gavel` (erişilemez). Hukuk ikonu **terazi olarak çiziliyor**. `dart fix` bunu "sil" diye önerir — **silme, düzelt**.

## G-8 🔧 P3 · Linter

53 issue: `prefer_const_constructors` 20 · `unused_import` 18 (9'u `main.dart`'ta, navigasyon registry'ye taşındığı için) · `deprecated_member_use` 5 · diğer 10. Detaylı liste `DYNASTY_XI_DENETIM_RAPORU.md`'de.

---

# 📋 TOPLU: `GameState` ŞEMA DEĞİŞİKLİKLERİ

| Alan | Tip | Neden | Madde |
|---|---|---|---|
| `activeCrisisCall` | *(mevcut)* | `toJson`/`fromJson`'a **ekle** | G-1 |
| `clearLoan` | `bool` param | `copyWith` null-temizleme | C-2 |
| `crisisCooldownMatches` | `int` | Kriz tekrarını önle | D-4 |
| `resolvedCrisisIds` | `List<String>` | Aynı krizi bir daha gösterme | D-4 |
| `continentalCup` | `ContinentalCup?` | Kıta kupası kalıcılığı | F-2 |
| `unlockedAchievementIds` | `Set<String>` | Rozet kalıcılığı | E-6 |
| `museumRecords` | `ClubMuseumRecords` | Kulüp tarihi | E-5 |
| `clubXp` | `int` | Kulüp Seviyesi | E-3 |
| `signedMarketIds` | `Set<String>` | Market filtreleme | G-6 |
| `categoryFatigue` | `Map<CardCategory,double>` | Kart çeşitliliği | D-2 |
| `rngSeed` | `int` | Determinizm | G-3 |
| ~~`ticketPrice`~~ | — | **Kaldır** (duplicate) | G-4 |
| ~~`sackingCountdownMatches`~~ | — | Ya kullan (E-1) ya kaldır | E-1 |

**Migration:** `SaveRepository._kSaveKey` `v1` → `v2`. `fromJson` zaten tüm alanlarda `?? default` kullanıyor → eski kayıtlar sorunsuz yüklenir, yeni alanlar varsayılana düşer.

---

# 📋 TOPLU: YENİ DOSYALAR

| Dosya | İçerik | Madde |
|---|---|---|
| `lib/domain/sim/match_stats_applier.dart` | Gol/asist/rating yazımı | A-2 |
| `lib/domain/sim/player_condition.dart` | Fitness/form/keskinlik tick | A-3 |
| `lib/domain/sim/injury_engine.dart` | Sakatlık rulosu + iyileşme | A-4 |
| `lib/domain/economy/weekly_ledger.dart` | Tek doğruluk kaynağı ekonomi | C-1 |
| `lib/domain/entities/position_weights.dart` | §9.2 OVR ağırlık tablosu | B-1 |
| `lib/domain/cards/dynamic_card_factory.dart` | Olay-tetikli kart üretimi | D-3 |

---

# 🗓️ YOL HARİTASI

## Sprint 0 — Zemin (1 gün)
`dart fix --apply` + 18 unused import + G-7. Hedef: `flutter analyze` → **0 issue**.
`copyWith` null-temizleme kuralı + lint testi (G-2).

## Sprint 1 — Tick mimarisi 🔥
**A-1** `playMatch` fazlara bölünür (davranış değişmeden, saf refactor + testler).
Bu sprint tek başına hiçbir oyun mekaniği eklemez — **sonraki 4 sprintin zeminidir**.

## Sprint 2 — Oyuncu boru hattı 🔥
A-2 → A-3 → A-4 → A-5 → B-4. Bu beşi birlikte "rotasyon stratejisi"ni doğurur.
**Doğrulama:** 21 maçlık sezon simülasyonunda golcü listesi anlamlı, en az 3 sakatlık, fitness dağılımı 40–100.

## Sprint 3 — Ekonomi 🔥
C-1 → C-2 → C-3 → A-6 → C-4 kalibrasyonu.
**Doğrulama:** §15.4 denge tablosu ±%15 içinde; musluk/lavabo 1.10–1.25.

## Sprint 4 — Kariyer döngüsü 🔥
E-1 → E-2 → E-6 (itibar) → A-9 → F-3. Soft-lock kapanır, kovulma gerçek olur.
**Doğrulama:** kasıtlı kötü oynanan 30 maçta kovulma tetikleniyor ve kulüp teklifi ekranı açılıyor.

## Sprint 5 — İçerik derinliği ⚡
D-1 (zincirler) → D-2 → D-3 → D-4 → F-4 → F-1 → F-2 → E-5.

## Sprint 6 — Spec kalibrasyonu ⚡
B-1 → B-2 → B-3 → B-5. Formülleri §9 ile hizala, her formül için sağlama testi.

## Sprint 7 — Eksik sistemler 🎯
E-3 (KulüpSv) → B-6 (kadro limiti) → C-5 (transfer dönemi) → G-6.

---

# ✅ KABUL KRİTERİ MATRİSİ

| # | Test | Dosya |
|---|---|---|
| 1 | `playMatch` gövdesi ≤ 40 satır | `analysis` |
| 2 | 2 gol atan oyuncunun `goals == 2`, `appearances == 1` | `match_stats_test.dart` |
| 3 | 3 maç üst üste oynayan `fitness <= 50` | `player_condition_test.dart` |
| 4 | 10.000 maçta sakatlık oranı %2.5–4.0 | `injury_engine_test.dart` |
| 5 | `injuryProneness:90` ≥2× sık sakatlanıyor | `injury_engine_test.dart` |
| 6 | Sakat oyuncu `starting11Ids`'e girmiyor | `squad_rules_test.dart` |
| 7 | 10 haftalık kredi 10 tick'te kapanıyor | `loan_test.dart` |
| 8 | Erken kapatmada `activeLoan == null` | `loan_test.dart` |
| 9 | Lig 20 haftalık net ₣5.000–9.000 | `economy_balance_test.dart` |
| 10 | §9.9 sağlama örneği ≈ ₣29.400 | `player_value_test.dart` |
| 11 | Tüm pozisyon ağırlıkları toplamı 1.00 | `position_weights_test.dart` |
| 12 | §8.3 tesis tablosu birebir tutuyor | `facility_costs_test.dart` |
| 13 | 21. maç sonrası sezon finali tetikleniyor | `season_flow_test.dart` |
| 14 | Puan tablosunda `played` 21'i geçmiyor | `season_flow_test.dart` |
| 15 | Aynı kriz üst üste 2 kez gelmiyor | `crisis_cooldown_test.dart` |
| 16 | Kayıt→yükle turunda `activeCrisisCall` korunuyor | `serialization_test.dart` |
| 17 | Tüm nullable alanların `clearX` bayrağı var | `copywith_lint_test.dart` |
| 18 | Kötü oynanan 30 maçta kovulma tetikleniyor | `sacking_test.dart` |
| 19 | Aynı serbest futbolcu 2 kez imzalanamıyor | `market_test.dart` |
| 20 | Aktif zincir varsa sıradaki kart zincirden | `card_chain_test.dart` |

---

# 📌 KAPSAM VE UYARILAR

**Bu doküman ne değil:** Bir uygulama planı değil, bir **hedef-durum tanımı**. Sprint sıralaması öneridir; formüller ise üretim dokümanından alınmış **bağlayıcı** referanslardır.

**Çözülmesi gereken tasarım kararları (kod yazmadan önce):**

1. **A-4 · Sakatlık birimi** — gün mü, maç mı? Doküman gün diyor, model maç. Öneri: maç (tutarlılık).
2. **C-4 · Tesis üsteli** — `sv` hedef seviye mi mevcut seviye mi? §8.3 tablosuyla sağlanmalı.
3. **F-4 · AI golcüleri** — AI kulüplerin gerçek kadrosu yok. Sanal golcü havuzu mu, yoksa tüm lige gerçek kadro üretimi mi? İkincisi çok daha pahalı.
4. **E-2 · Kovulma sonrası kulüp teklifleri** — mevcut kulüp tamamen kaybediliyor mu, yoksa "geri dön" yolu var mı? §12.8 kaybı savunuyor.

**Ölçüm:** §12.8 (%12–18 kovulma) ve §15.5 (1.16 musluk/lavabo) sayısal hedefler veriyor. Bunlar telemetri olmadan doğrulanamaz — `economy_net_flow` ve `manager_sacked` event'leri Sprint 3–4'te eklenmeli.
