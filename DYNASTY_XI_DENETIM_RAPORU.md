# 🔍 DYNASTY XI — DERİN KOD TABANI DENETİMİ

**Tarih:** 20 Ağustos 2026
**Branch:** `main` @ `975e134`
**Kapsam:** `lib/` altındaki 148 Dart dosyası
**Test durumu:** ✅ 145/145 geçiyor
**Analyze:** 53 issue (0 error, 24 warning, 29 info)

> **Metodoloji notu:** İstenen `agent-architecture-audit` ve `repo-scan` skill'leri bu kurulumda kayıtlı değil (ne proje `.claude/skills/` altında ne de global listede). Onların yerine manuel statik analiz yapıldı: `flutter analyze`, `flutter test`, AST-benzeri serileştirme kapsam tarayıcısı (Python), çağrı-grafı orphan taraması ve dosya-bazlı import erişilebilirlik taraması.

---

## Özet

| Kategori | Adet | Etki |
|---|---|---|
| 🔴 Kritik | 13 | Oyun döngüsünü bozan / veri kaybı / soft-lock |
| 🟠 Orta | 13 | Ölü sistem, sahte veri, mimari borç |
| 🟡 Minör | 53 | Linter temizliği |

---

# 🔴 KRİTİK

## K-1 · Erken kredi kapatma parayı alıyor ama borcu silmiyor

`lib/application/providers/game_state_provider.dart:1509` `activeLoan: null` gönderiyor, ama `lib/domain/entities/game_state.dart:171` `activeLoan ?? this.activeLoan` yazıyor → **null geçmek no-op**. Oyuncu `earlyRepaymentDiscountedAmount` kadar nakit kaybediyor, kredi ekranda duruyor. Aynı hata sınıfı `gameOverReason` için de geçerli.

**Düzeltme:** `GameState.copyWith`'e `bool clearLoan = false` bayrağı ekle (`headCoach` / `activeCrisisCall` deseninin aynısı), 1509'u `clearLoan: true` yap.

## K-2 · Banka kredisi hiç taksit ödemiyor

`BankLoan.payWeeklyInstallment()` — `lib/domain/economy/financial_statement.dart:109` — prod kodunda **hiç çağrılmıyor** (sadece `test/domain/economy_and_board_test.dart:102`). `remainingWeeks` sonsuza kadar sabit, kasadan hiç para çıkmıyor. Kredi = bedava para.

**Düzeltme:** `playMatch()` içine sponsor tick'inin yanına kredi tick'i ekle: taksit kadar `deltaCash` düş, `isPaidOff` olunca `clearLoan: true`.

## K-3 · Oyuncu kiralama sistemi zamansız

`LoanDeal` — `lib/domain/economy/transfer_models.dart:6-38` — içinde `weeksRemaining` alanı **yok**, `seasons` hiç azalmıyor, `weeklyWageToPay` hiçbir yerde kasadan düşülmüyor. Üstelik `lib/presentation/widgets/loan_contract_summary_modal.dart:173` kiralamayı `buyPlayer()` ile yapıyor → **kiralık oyuncu kalıcı satın alınıyor**.

**Düzeltme:** `LoanDeal`'e `weeksRemaining` ekle + `playMatch` tick'i + modal'ı gerçek bir `loanInPlayer()` metoduna bağla.

## K-4 · Tesis inşaat timer'ı sadece uygulama açılışında tamamlanıyor

`checkFacilityUpgrades()` — `lib/application/providers/game_state_provider.dart:1777` — yalnızca `_init()` ve `claimSponsorReward()` içinden çağrılıyor. `playMatch()` çağırmıyor, `facilities_screen` / `facility_detail_screen` de çağırmıyor.

Ayrıca ekranlarda `Timer.periodic` yok — `lib/presentation/screens/facilities_screen.dart:138` ve `lib/presentation/screens/facility_detail_screen.dart:42` `DateTime.now()`'ı sadece `build()` anında okuyor, **geri sayım ekranda donuk duruyor**.

**Düzeltme:**
1. `playMatch()` başında `await checkFacilityUpgrades()`;
2. İki ekrana da `Timer.periodic(1s)` + `setState`.

## K-5 · Sakatlık sistemi tamamen ölü

`Player.injuryMatchesLeft` / `injuryType` / `injurySeverity` — `lib/domain/entities/player.dart:161-163` — kod tabanında **hiçbir yerde set edilmiyor**. `MatchEventType.injury` (`lib/domain/sim/match_events.dart:12`) sadece görsel log üretiyor, state'e yazmıyor. Tek azaltma `lib/domain/progression/player_growth.dart:17` içinde ve o da yalnızca **sezon geçişinde** çalışıyor. `lib/presentation/screens/squad_screen.dart:690`'daki 🚑 rozeti hiç görünmez.

**Düzeltme:** `playMatch()` sonrası ilk 11'e `injuryProneness` + `trainingIntensity.injuryRiskMultiplier` tabanlı sakatlık rulosu at; maç başına `injuryMatchesLeft--`.

## K-6 · Ekonomi tek yönlü — hiçbir gider kasaya yansımıyor

`FinancialStatementCalculator.calculateWeeklyStatement()` — `lib/domain/economy/financial_statement.dart:195` — sadece `lib/presentation/screens/finance_screen.dart:44`'te **ekrana çizmek için** hesaplanıyor. `playMatch()` yalnızca ev sahibi maç günü hasılatını ekliyor (`game_state_provider.dart:159`).

Yansımayanlar:
- Oyuncu maaşları
- Staff maaşları
- Tesis bakımı
- Kredi taksiti
- Mevduat faizi (`treasuryInterestIncome`)
- **Haftalık sponsor gelirleri** (`sleeveSponsorIncome`, `stadiumNamingIncome`, `sponsorWeeklyIncome` — hiçbiri `calculateMatchDayRevenue`'da yok, o sadece bilet + merchandise)
- Yayın geliri (`calculateWeeklyBroadcasting()` de kasaya girmiyor)

**Düzeltme:** `playMatch()` içinde `statement.netBalance` hesaplayıp tek `deltaCash` olarak uygula; `finance_screen` aynı fonksiyonu önizleme amaçlı kullanmaya devam etsin.

## K-7 · `activeCrisisCall` serileştirilmiyor (veri kaybı)

`lib/domain/entities/game_state.dart:57` alan var, `copyWith`'te var, ama `toJson` (satır 192-225) ve `fromJson` (satır 227-364) **ikisinde de yok**. Kriz modalı açıkken uygulama kapanırsa kriz sessizce buharlaşıyor. 34 alanın kaçırılan tek alanı bu.

**Düzeltme:** `'activeCrisisCall': activeCrisisCall?.toJson()` + `fromJson` karşılığı. (`PresidentCrisisCall`'ın `toJson`/`fromJson`'ı olduğu doğrulanmalı.)

## K-8 · Kriz cooldown mekanizması yok → aynı kriz sonsuz döngü

`CrisisTriggerEngine.evaluateCrisis()` — `lib/domain/president/crisis_trigger_engine.dart` — tamamen anlık koşul tabanlı (`cash < 15000`, `boardTrust < 40`…). Krizi çözdükten sonra koşul hâlâ sağlanıyorsa **bir sonraki maçta birebir aynı kriz tekrar tetikleniyor**. `GameState`'te ne `lastCrisisId` ne `crisisCooldownMatches` var.

Ayrıca `game_state_provider.dart:290-293` `clearCrisisCall: crisis == null` yazdığı için **çözülmemiş aktif bir kriz sessizce siliniyor**.

**Düzeltme:** `GameState`'e `crisisCooldownMatches` + `resolvedCrisisIds` ekle; `playMatch`'te önce `if (current.hasActiveCrisis) → koru`, sonra cooldown 0 ise değerlendir.

## K-9 · `isGameOver` hiçbir UI tarafından okunmuyor → soft-lock

`isGameOver` yalnızca `lib/domain/cards/card_effects.dart:56`'da set ediliyor. `lib/presentation/` ve `lib/main.dart` içinde **tek bir okuma yok**. Buna karşılık `playMatch()` (`game_state_provider.dart:114`) `if (current.isGameOver) return null;` diyor → oyuncu kovulduğunda maç butonu sessizce hiçbir şey yapmıyor, ekran değişmiyor.

**`lib/presentation/screens/sacked_screen.dart` hiçbir dosya tarafından import edilmemiş** (bkz. O-2).

**Düzeltme:** `main.dart` `MainLayoutScreen.build`'de `if (state.isGameOver) return SackedScreen(...)`.

## K-10 · Kovulma grace sayacı ölü

`ClubMeters.onMatchCompleted()` — `lib/domain/entities/meter.dart:55` — `consecutiveCriticalMatches`'i artıran **tek** metot, hiçbir yerden çağrılmıyor. `applyDeltas` sayacı olduğu gibi taşıyor. Sonuç: `graceMatchesAllowed = 3` kuralı hiç işlemiyor, `isSacked` yalnızca `boardTrust == 0` tam eşitliğinde tetikleniyor.

**Düzeltme:** `playMatch()` içinde metre güncellemesinden sonra `.onMatchCompleted()` zincirle, dönen `isSacked`'ı `isGameOver`'a bağla.

## K-11 · Lig Gol/Asist Krallığı %100 sahte veri

`lib/presentation/screens/league_screen.dart:118-131` — 9 satır hardcoded `ScorerEntry` (Semih Kılıçsoy 8 gol, Alex de Souza 9 asist…). Sayılar hiç değişmiyor, maçtan bağımsız.

Buna karşılık altyapı **hazır ve kullanılmıyor**:
- `LeagueScorerBoard` (`lib/domain/match/match_depth_models.dart:59-95`) hiç instantiate edilmiyor
- `Player.goals` / `Player.assists` (`lib/domain/entities/player.dart:167`) hiçbir yerde artmıyor
- `Player.appearances` de öyle (`lib/domain/progression/season_transition.dart:98` yalnızca sıfırlıyor) → `PlayerGrowth`'taki `appearancesFactor` sonsuza kadar `0.75`

**Düzeltme:** `playMatch()`'te `MatchResult` olaylarından golcü/asistçiyi çıkar → `squad`'da `goals++` / `assists++` / `appearances++`; `_buildLeaderboardsTab` bunları lig geneli üzerinden sıralasın.

## K-12 · Avrupa Kıta Kupası kalıcı değil

`lib/presentation/screens/cup_tournament_screen.dart:37` — `ContinentalCup.generateTournament(...)` bir **StatefulWidget alanına** yazılıyor (`_isInit` guard'lı). `GameState`'te `continentalCup` diye bir alan **yok**. Ekrandan çıkıp girince turnuva sıfırdan rastgele üretiliyor; hiçbir sonuç kaydedilmiyor.

**Düzeltme:** `GameState`'e `ContinentalCup? continentalCup` alanı + `toJson`/`fromJson`/`copyWith`; üretimi `_init()` / sezon geçişine taşı.

## K-13 · Günlük görevlerin 2/3'ü matematiksel olarak tamamlanamaz

`DailyQuest.currentCount` — `lib/domain/progression/daily_quest.dart:9` — hiçbir yerde artırılmıyor. Tek yazan `claimDailyQuest` (`game_state_provider.dart:1246`) ve o da sadece `isClaimed`'i işaretliyor.

`generateDailyQuests()` (`daily_quest.dart:88-106`) şunlarla doğuyor:
- `q_tactics_check` → 1/1 (endowed progress, claim edilebilir)
- `q_play_league_match` → 0/1 → **sonsuza kadar 0**
- `q_club_development` → 0/2 → **sonsuza kadar 0**

**Düzeltme:** `playMatch` / `upgradeFacility` / `chooseCardOption` içine `_advanceQuest(id)` yardımcı çağrısı; ayrıca gün değişiminde quest reset'i yok, o da eklenmeli.

---

# 🟠 ORTA

## O-1 · 13 orphan notifier metodu

`lib/application/providers/game_state_provider.dart` içinde tanımlı, **hiçbir UI'dan çağrılmayan** metotlar:

| Metot | Satır | Durum |
|---|---|---|
| `dismissCrisisCall` | 324 | `urgent_phone_call_modal` sadece `resolveCrisisCall` çağırıyor → "Ertele" butonu yok |
| `setPlayerTraining` | 1040 | Antrenman yoğunluğu UI'ı hiç yapılmamış → `TrainingIntensity` ölü |
| `setPlayerSquadRole` | 1091 | `SquadRole` seçilemiyor ama `Player.isUnhappy` buna bakıyor |
| `setWinBonus` | 2113 | `winBonusPerMatch` alanı hiç ödenmiyor da |
| `loanPlayer` | 2167 | Bkz. K-3 |
| `swapPlayerTransfer` | 2192 | `SwapEvaluationEngine` var, tetik yok |
| `updateContractClauses` | 708 | `ContractRenewalDialog` bunu kullanmıyor |
| `promoteYouthProspect` | 1884 | **`promoteU19Player`:492 ile duplicate** — UI ikincisini kullanıyor |
| `unlockManagerPerk` | 979 | `spendSkillPoint` alias'ı üzerinden dolaylı erişiliyor |
| `signSponsorshipDeal` | 1439 | `signSponsorshipContract` wrapper'ı, ölü |
| `updateSponsors` | 1297 | Sponsorluk sistemi tarafından tamamen ikame edilmiş |
| `setPinnedShortcuts` | 351 | Modal `toggleShortcutPinned` kullanıyor |
| `claimWinBackRewards` | 2265 | `win_back_dialog.dart` hiç import edilmemiş |

**Düzeltme — ikiye ayır:**
- **Sil:** `signSponsorshipDeal`, `updateSponsors`, `promoteYouthProspect`, `setPinnedShortcuts`
- **UI'ya bağla:** `dismissCrisisCall`, `setPlayerTraining`, `setPlayerSquadRole`, `updateContractClauses`, `swapPlayerTransfer`, `loanPlayer`, `setWinBonus`, `claimWinBackRewards`

## O-2 · 7 dosya hiçbir yerden import edilmemiş (ölü ağırlık)

```
lib/presentation/screens/sacked_screen.dart             ← K-9
lib/presentation/widgets/match_reward_dialog.dart       ← maç sonu MOTM/ödül ekranı hiç açılmıyor
lib/presentation/widgets/win_back_dialog.dart           ← claimWinBackRewards ile eşleşiyor
lib/presentation/widgets/opposition_report_dialog.dart  ← OppositionScoutReport ölü kalıyor
lib/presentation/widgets/stadium_isometric_widget.dart
lib/domain/cards/extended_narrative_cards.dart          ← CardDatabase'e beslenmiyor
lib/domain/progression/player_natural_summary.dart
```

`match_reward_dialog.dart` özellikle acı: hızlı sim sonrası `lib/presentation/screens/office_screen.dart:612` yalnızca bir `SnackBar` gösteriyor.

**Düzeltme:** Bağla veya sil. Bağlanacaklar: `SackedScreen` (K-9), `MatchRewardDialog` (playMatch sonrası), `OppositionReportDialog` (match_screen ön-maç).

## O-3 · Duplicate implementasyon çiftleri

| A | B | Kullanım |
|---|---|---|
| `renewContract`:746 | `renewPlayerContract`:2123 | `player_detail_screen` A'yı, `transfer_screen` B'yi çağırıyor → **davranış farkı** |
| `promoteYouthProspect`:1884 | `promoteU19Player`:492 | B kullanımda |
| `signPlayer`:796 | `buyPlayer`:837 | alias |
| `takeBankLoan`:1284 | `takeBankLoanPackage`:1462 | alias |
| `unlockManagerPerk`:979 | `spendSkillPoint`:996 | alias |
| `signSponsorshipDeal`:1439 | `signSponsorshipContract`:1330 | wrapper |

**Düzeltme:** `renewContract` / `renewPlayerContract`'ı tek metotta birleştir (öncelik: madde-destekli olan `renewContract`), diğerlerini `@Deprecated` işaretle veya kaldır.

## O-4 · `playCupMatch` sahte simülasyon

`game_state_provider.dart:2016-2081` — `MatchEngine` **kullanmıyor**:

```dart
final userGoals = 1 + _rng.nextInt(3);   // 1..3
final oppGoals  = _rng.nextInt(2);       // 0..1
```

Takım gücü, taktik, kadro tamamen yok sayılıyor; kullanıcı pratikte hiç elenmiyor. `winnerId = homeScore >= awayScore` → beraberlik ev sahibine gidiyor, `CupMatch.homePenalties` / `awayPenalties` alanları hiç kullanılmıyor. Ayrıca kupa maçı lig takvimine bağlı değil (`clock` ilerlemiyor).

**Düzeltme:** `MatchEngine(setup)` ile simüle et; beraberlikte penaltı serisi çalıştırıp `homePenalties`/`awayPenalties` doldur; kupa turlarını `clock.matchday`'e bağla.

## O-5 · Kupa Müzesi / Başarımlar sahte

`lib/presentation/screens/trophy_room_screen.dart:41-44` → `previouslyUnlockedIds: {}` **hardcoded boş**. Başarımlar her `build`'de sıfırdan değerlendiriliyor, "yeni açıldı" bildirimi imkânsız; `GameState`'te `unlockedAchievementIds` alanı yok.

`trophy_room_screen.dart:47+` → `const ClubMuseumRecords(biggestWinScore: '5-0', biggestWinOpponent: 'Kartaltepe SK', recordSigningName: 'Kerem Aktürkoğlu', ...)` — **tamamen mock**.

Ayrıca `trophiesWon: (20 - state.currentLeague.tier)` proxy'si kullanılıyor, oysa gerçek `club.totalTrophies` alanı mevcut.

**Düzeltme:** `GameState`'e `unlockedAchievementIds` + `ClubMuseumRecords` alanları; `playMatch`'te rekor güncellemesi; `trophiesWon: state.userClub.totalTrophies`.

## O-6 · Statik `const` marketler — imzalananlar listeden düşmüyor

`FreeAgentMarketGenerator.generateFreeAgents()` (`lib/domain/economy/transfer_models.dart:117`) ve `LoanMarketGenerator.generateLoanCandidates()` (`transfer_models.dart:41`) `const [...]` döndürüyor; `lib/presentation/screens/transfer_screen.dart:112-113` her `build`'de bunları çağırıyor.

`signPlayer()` yalnızca `state.transferMarket`'ten çıkarma yapıyor → **aynı serbest futbolcu sınırsız kez, aynı `id` ile imzalanabiliyor** (kadroda duplicate id).

Aynı sorun:
- `StaffMarketCatalog.getAvailableMarketCandidates()` → `lib/presentation/screens/staff_screen.dart:416`
- `HeadCoachCatalog.getCandidateCoaches()` → `lib/presentation/screens/head_coach_hiring_screen.dart:36`

**Düzeltme:** `GameState`'e `signedMarketIds: Set<String>` ekle ve üç listeyi de bununla filtrele; ya da bu havuzları `transferMarket` gibi state'e taşı.

## O-7 · Fikstür fallback tabloyu bozuyor

`game_state_provider.dart:117-120` ve `lib/presentation/screens/match_screen.dart:61-64` — `orElse: () => fixtures.first`. O matchday'de oynanmamış maç yoksa **1. haftanın maçı tekrar oynanıyor**, puan tablosuna ikinci kez yazılıyor.

**Düzeltme:** `firstWhereOrNull` + null ise sezon sonu akışına yönlendir.

## O-8 · Ölü / duplicate state alanları

- **`GameState.ticketPrice`** (default `25`) — hiçbir okuyucu yok; gerçek kaynak `Club.ticketPrice` (default `12`). `setTicketPrice` ikisini birden yazıyor (`game_state_provider.dart:1315-1319`) ama sadece `Club` olanı okunuyor.
- **`GameState.sackingCountdownMatches`** (`game_state.dart:45`) — sadece `toJson`/`fromJson`'da geçiyor, hiç set/read edilmiyor.
- **`GameState.winBonusPerMatch`** — `setWinBonus` orphan, `playMatch` ödemiyor.

**Düzeltme:** `ticketPrice` ve `sackingCountdownMatches`'i `GameState`'ten kaldır (migration: `fromJson` zaten toleranslı); `winBonusPerMatch`'i `playMatch`'te galibiyette `deltaCash` olarak uygula.

## O-9 · `DeterministicRng` deterministik değil

`game_state_provider.dart:42` → `DeterministicRng(DateTime.now().millisecondsSinceEpoch)` — sınıf adının vaadinin tersi. `playMatch` seed'i de `... + _rng.nextInt(99)` içerdiği için aynı kayıttan aynı maç asla tekrar üretilemiyor (save-scum tespiti / bug reprodüksiyonu imkânsız).

**Düzeltme:** Notifier RNG'sini `GameState`'te saklanan bir `rngSeed`'den türet.

## O-10 · AI maç simülasyonunda tek kalan kulüp atlanıyor

`game_state_provider.dart:189` → `for (var i = 0; i + 1 < otherClubs.length; i += 2)` — tek sayıda diğer kulüp varsa sonuncusu **o hafta hiç maç oynamıyor**, oynanan maç sayısı tabloda tutarsızlaşıyor.

## O-11 · Sezon geçişi tamamen manuel

`executeSeasonTransition()` sadece `lib/presentation/screens/league_screen.dart:274`'teki bir butondan çağrılıyor. Fikstür bitince otomatik tetiklenmiyor → oyuncu butona basmazsa `playMatch` sonsuza kadar `fixtures.first`'ü tekrar oynuyor (O-7 ile birleşince tablo tamamen bozuluyor).

## O-12 · `⚖` emoji'si iki kez case'lenmiş — yanlış ikon çiziliyor

- `lib/presentation/widgets/retro_pixel_icon.dart:150` → `'⚖'` → `scales`
- `lib/presentation/widgets/retro_pixel_icon.dart:178` → `'⚖'` → `gavel` **(unreachable)**

Hukuk / Legal Defense ikonu **terazi olarak çiziliyor**, tokmak asla görünmüyor. `flutter analyze` bunu `unreachable_switch_case` olarak raporluyor ama bu bir lint değil, gerçek görsel hata.

## O-13 · Serileştirme: `ProceduralFaceData` renkleri

`lib/domain/visuals/face_generator.dart:76+` — `toJson` `skinColor` / `hairColor` / `eyeColor`'ı yazmıyor. `seed`'den yeniden türetiliyorsa **kasıtlı ve doğru** — ama palet dizileri değişirse tüm kayıtlı yüzler sessizce değişir. Yorum satırıyla belgelenmeli.

---

### 📦 Serileştirme taraması — tam sonuç

148 dosya / tüm `final` alanlar `toJson` / `fromJson` / `copyWith` kapsamı açısından tarandı. **Yalnızca iki gerçek boşluk** bulundu:

1. `GameState.activeCrisisCall` → K-7
2. `ProceduralFaceData` renkleri → O-13

Diğer tüm modeller **tam kapsamlı**: `Club` (19 alan), `Player` (40+ alan), `Manager`, `ClubMeters`, `CupMatch`, `CupTournament`, `NegotiationState`, `LoanDeal`, `BankLoan`, `DailyQuest`, `ManagerSkill`, `SponsorshipContract`, `GameClock`, `League`, `Fixture`, `StaffMember`, `HeadCoach`, `VipBoxDeal`, `DynastyLegacyPerk`.

`copyWith`'te null-clear desteği eksikliği (K-1) ayrı bir sorun sınıfıdır ve alan kapsamı taramasında görünmez.

---

# 🟡 MİNÖR — 53 `flutter analyze` issue

**Dağılım:**

| Kural | Adet |
|---|---|
| `prefer_const_constructors` | 20 |
| `unused_import` | 18 |
| `deprecated_member_use` | 5 |
| `use_build_context_synchronously` | 2 |
| `unused_local_variable` | 2 |
| `prefer_final_fields` | 2 |
| `prefer_const_literals_to_create_immutables` | 2 |
| `unreachable_switch_case` | 1 |
| `unnecessary_const` | 1 |

## Kullanılmayan import (18)

**`lib/main.dart` — 9 tane.** Navigasyon `DynastyNavigationRegistry` üzerinden yapıldığı için ekran import'ları artık gereksiz:

| Satır | Import |
|---|---|
| 12 | `presentation/screens/board_room_screen.dart` |
| 19 | `presentation/screens/press_conference_screen.dart` |
| 20 | `presentation/screens/scouting_screen.dart` |
| 23 | `presentation/screens/staff_screen.dart` |
| 25 | `presentation/screens/trophy_room_screen.dart` |
| 26 | `presentation/screens/head_coach_hiring_screen.dart` |
| 27 | `presentation/screens/boardroom_summit_screen.dart` |
| 28 | `presentation/screens/cup_tournament_screen.dart` |
| 29 | `presentation/screens/prestige_screen.dart` |

**Kalan 9:**

```
lib/presentation/screens/head_coach_dialogue_screen.dart:10   ../../domain/president/head_coach.dart
lib/presentation/screens/office_screen.dart:9                 ../../domain/entities/facility.dart
lib/presentation/screens/squad_screen.dart:18                 staff_screen.dart
lib/presentation/screens/transfer_negotiation_screen.dart:4   dart:math
lib/presentation/screens/transfer_screen.dart:16              ../widgets/face_avatar_widget.dart
lib/presentation/screens/u19_squad_screen.dart:10             ../../domain/entities/player.dart
lib/presentation/screens/u19_squad_screen.dart:15             player_detail_screen.dart
lib/presentation/widgets/club_emblem_widget.dart:6            ../../app/theme/app_colors.dart
lib/presentation/widgets/loan_contract_summary_modal.dart:12  retro_pixel_icon.dart
```

## Deprecated API (5)

```
lib/presentation/screens/transfer_negotiation_screen.dart:391:23   value: → initialValue:  (DropdownButtonFormField)
lib/presentation/screens/transfer_negotiation_screen.dart:412:23   value: → initialValue:
lib/presentation/widgets/loan_contract_summary_modal.dart:91:66    withOpacity → withValues(alpha:)
lib/presentation/widgets/player_sale_offer_modal.dart:101:59       withOpacity → withValues(alpha:)
lib/presentation/widgets/retro_impact_confirm_modal.dart:172:62    withOpacity → withValues(alpha:)
```

## Unreachable switch case (1)

```
lib/presentation/widgets/retro_pixel_icon.dart:178:7
```

⚠️ **Bu bir lint değil, O-12'deki gerçek görsel hata.** Sadece silme; `'⚖'`'i satır 150'den kaldırıp 178'de bırak (veya legal için `'⚖️'` VS16'lı varyanta ayır).

## Kullanılmayan local değişken (2)

```
lib/domain/media/newspaper_story_engine.dart:50:11   lockerRoom
lib/presentation/widgets/retro_pixel_icon.dart:309:11 outlinePaint
```

İkisi de "sil" değil, **"kullan"** adayı:
- `lockerRoom` → haber üretiminde moral hiç kullanılmıyor, muhtemelen eksik özellik
- `outlinePaint` → `secondaryColor` hiç boyanmıyor, retro ikonlar tek renk çiziliyor (tasarım niyeti iki renkli görünüyor)

## Diğer (7)

```
lib/presentation/screens/finance_screen.dart:563:64          use_build_context_synchronously
lib/presentation/screens/finance_screen.dart:851:58          use_build_context_synchronously
lib/presentation/screens/transfer_negotiation_screen.dart:42:7  _goalBonus → final
lib/presentation/screens/transfer_screen.dart:71:8           _showFreeAgents → final
lib/main.dart:549:35                                         unnecessary_const
lib/presentation/widgets/loan_contract_summary_modal.dart:108:35   prefer_const_literals
lib/presentation/screens/transfer_negotiation_screen.dart:564:25   prefer_const_literals
```

## `prefer_const_constructors` (20)

```
lib/domain/rpg/head_coach_dialogue_engine.dart:95, 108, 116, 139
lib/presentation/screens/head_coach_dialogue_screen.dart:93, 94
lib/presentation/screens/transfer_negotiation_screen.dart:561, 562
lib/presentation/screens/u19_squad_screen.dart:49
lib/presentation/screens/youth_academy_screen.dart:48, 94
lib/presentation/widgets/loan_contract_summary_modal.dart:106
test/domain/dynasty_navigation_registry_test.dart:16, 17
test/domain/sponsorship_contracts_test.dart:81
test/presentation/impact_confirm_test.dart:63, 134, 135, 136
test/presentation/transfer_screen_test.dart:59
```

---

# ⚙️ ÖNERİLEN REFAKTÖR SIRASI

## PR 1 — Lint sıfırlama (~15 dk, sıfır risk)

`dart fix --apply` 29 info'nun neredeyse tamamını otomatik kapatır. Ardından 18 unused import + 2 unused local elle.

> ⚠️ **İstisna:** `retro_pixel_icon.dart:178`'i `dart fix`'e silletme — O-12'yi manuel çöz.

**Hedef:** `flutter analyze` → 0 issue.

```bash
dart fix --apply && flutter analyze
```

## PR 2 — Ekonomi & timer döngüsü

**Kapsam:** K-1, K-2, K-3, K-4, K-6, O-8

Tek bir `_advanceWeeklyEconomy(GameState)` yardımcısı yaz, `playMatch()` içinde çağır:
- Sponsor tick (mevcut, çalışıyor)
- Kredi taksiti (`payWeeklyInstallment`)
- Kira maaşları (`LoanDeal.weeklyWageToPay`)
- `statement.netBalance`
- Galibiyet primi (`winBonusPerMatch`)

Ek olarak: `copyWith`'e `clearLoan` ekle; `playMatch` başına `checkFacilityUpgrades()`; tesis ekranlarına `Timer.periodic`.

## PR 3 — Maç döngüsü bütünlüğü

**Kapsam:** K-5, K-10, K-11, O-7, O-10, O-11

`playMatch()` içinde:
- Sakatlık rulosu + iyileşme tick'i
- `onMatchCompleted()` zinciri → `isGameOver`
- Golcü / asist / appearance yazımı
- `firstWhereOrNull` + otomatik sezon geçişi
- AI eşleştirmede tek kalan kulüp düzeltmesi

## PR 4 — Kayıt bütünlüğü & kalıcılık

**Kapsam:** K-7, K-12, O-5

`GameState`'e ekle + tam serileştirme:
- `activeCrisisCall`
- `continentalCup`
- `unlockedAchievementIds`
- `ClubMuseumRecords`

`SaveRepository` sürüm bump (`_kSaveKey` v1 → v2, eski kayıt için tolerant fallback).

## PR 5 — Ölü kod temizliği & UI bağlama

**Kapsam:** K-8, K-9, K-13, O-1, O-2, O-3, O-4, O-6

- Orphan metotların yarısını sil, yarısını bağla
- 7 ölü dosyayı bağla veya sil
- Duplicate metot çiftlerini birleştir
- Kriz cooldown mekanizması
- `playCupMatch`'i `MatchEngine`'e taşı
- Market filtreleme (`signedMarketIds`)

---

## Kapsam notu

Denetim `lib/` (148 dosya) üzerinde yapıldı. `build/`, `web/` bundle ve `assets/` kapsam dışıydı.

`DYNASTY_XI_URETIM_DOKUMANI.md` (251 KB) ile spec-vs-implementation karşılaştırması **yapılmadı** — ayrı bir tur olarak çıkarılabilir. K-11 / K-13 gibi bulguların birçoğu muhtemelen orada tanımlı ama yarım kalmış özellikler.
