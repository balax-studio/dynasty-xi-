# DYNASTY XI - UI ETKİLEŞİM VE İŞLEV DENETİM RAPORU
**Denetim Tarihi:** 2026-09-03  
**Kapsam:** `lib/presentation/screens/` (36 Ekran), `lib/presentation/widgets/` (41 Bileşen), `lib/main.dart`  
**Mimari Çerçeve:** Flutter (Dart) & Riverpod Durum Yönetimi (`GameStateNotifier`)  
**Denetim Tipi:** Statik Kod Analizi, Çağrı Ağacı Takibi ve Fonksiyonel Entegrasyon Denetimi (Salt Okunur)

---

## 1. YÖNETİCİ ÖZETİ

İşbu denetim raporu, Dynasty XI kulüp yönetim simülasyonu kod tabanında yer alan tüm ekran, diyalog, modal ve alt bileşenlerdeki buton etkileşimlerini, tetikleyici fonksiyonları ve Riverpod durum sağlayıcı entegrasyonlarını belgelemektedir.

Yapılan statik analiz kapsamında 36 ekran ve 41 widget taranmış, toplam 225 adet kullanıcı etkileşim noktası (`onPressed`, `onTap`, `GestureDetector`, `RetroButton`) incelenmiştir. Denetim sonucunda:
- **8 Kritik Seviye Problem:** Kullanıcıdan nakit tahsil edip vaat edilen etkiyi üretmeyen, bütçe kesintisi yapmadan sahte onay veren, seçilen oyuncu ve kaptan parametrelerini buharlaştıran ve canlı maç döngüsünde ödül ekranını atlayan kusurlar.
- **8 Orta Seviye Problem:** Tamamen hazır olmasına rağmen arayüzden hiçbir butona bağlanmamış yetim (orphan) diyaloglar, maç motoruna etki etmeyen yerel metin ekleyiciler ve panoya kopyalama yapmayan sahte butonlar.
- **5 Düşük Seviye Problem:** Eksik navigasyon ikonları, eski kredi çağrıları ve backend'de hazır olmasına rağmen arayüzü çizilmemiş antrenman ayar kontrolleri.

Aşağıdaki tablolarda her bir bulgu; dosya yolu, satır numarası, mevcut arıza durumu, olması gereken teknik entegrasyon ve öncelik derecesiyle sunulmuştur.

---

## 2. ETKİLEŞİM VE İŞLEV DENETİM TABLOSU

| Ekran / Dosya Yolu | Bileşen / Buton Etiketi | Satır No | Mevcut Durum | Olması Gereken / Gerekli Entegrasyon | Öncelik |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [boardroom_summit_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/boardroom_summit_screen.dart) | ONAYLA & UYGULA (Yönetim Kurulu Önergesi) | 292-306 | **Sahte / Görsel Tetikleyici:** Buton yalnızca `clubCash >= m.requiredCost` kontrolü yapıp SnackBar mesajı basmaktadır. Kasadan bütçe kesilmemekte, vaat edilen kazanım (`rewardDescription`) uygulanmamakta ve önerge kabul edilmiş olarak işaretlenmemektedir. | `ref.read(gameStateProvider.notifier)` üzerinden yeni bir `passBoardroomMotion(motionId)` metodu çağrılmalı; bütçe düşülmeli, etki GameState'e işlenmeli ve önerge karara bağlanmalıdır. | **KRİTİK** |
| [facilities_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/facilities_screen.dart) | BAŞKANLIK MÜTEAHHİT İHALESİ & İMAR KOMİSYONU AÇ | 99-118 | **Parayı Tahsil Edip İnşaatı Başlatmayan Buton:** Müteahhit seçildiğinde `adjustCash(-cost)` ile kulüp kasasından on binlerce Frank kesilmektedir; ancak `upgradeFacility` veya ilgili tesis geliştirme fonksiyonu çağrılmadığı için stadyum seviyesi ve inşaat süreci ASLA başlamamaktadır. | `ContractorTenderModal` geri çağrımında (`onSelected`) `adjustCash` sonrasında ilgili tesisin yükseltme döngüsünü başlatan `startContractedUpgrade(facilityType, durationWeeks)` metodu tetiklenmelidir. | **KRİTİK** |
| [finance_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/finance_screen.dart) | ERKEN KAPAT (-%10 İNDİRİMLİ) (Banka Kredisi) | 944-964 | **Nakit Tüketen Ancak Borcu Silmeyen Askıda Durum:** Notifier'da `activeLoan: null` atanmasına rağmen `GameState.copyWith` metodu `activeLoan ?? this.activeLoan` mantığıyla çalıştığından kredi sıfırlanamamaktadır. Kullanıcı parasını kaybetmekte ancak borç ve haftalık kesintiler devam etmektedir. | `GameState.copyWith` metoduna `clearActiveLoan: true` desteği eklenmeli ve erken ödeme tıklandığında kredi entity'si hafızadan kalıcı olarak silinmelidir. | **KRİTİK** |
| [presidential_directives_modal.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/presidential_directives_modal.dart) | TALİMATLARI RESMİLEŞTİR & TEBLİĞ ET | 133-156 | **Buharlaşan Parametreler & Sahte Yönetim Kararı:** Kullanıcının modalda seçtiği `_selectedBannedPlayerId` (kadro dışı) ve `_selectedCaptainId` (kaptan atama) değerleri notifier çağrısına hiç iletilmemektedir. Seçilen oyuncu kadro dışı kalmamakta, seçilen kaptan atanmamaktadır. | `formalizePresidentialDirectives` metoduna `bannedPlayerId` ve `captainId` parametreleri eklenmeli; oyuncu entity'sinde `isBanned` güncellenmeli ve kulüp kaptanı değiştirilmelidir. | **KRİTİK** |
| [contract_renewal_dialog.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/contract_renewal_dialog.dart) | SÖZLEŞMEYİ İMZALA | 129-153 | **Kaybolan Kadro Rolü ve Prim Entegrasyonu:** Kullanıcının sözleşme yenilerken taahhüt ettiği `SquadRole` (Kilit Oyuncu, Rotasyon vb.) ve imza primi `renewContract` metoduna aktarılmamakta, oyuncunun `squadRole` alanı hiçbir zaman güncellenmemektedir. | `renewContract(playerId, years, wage, signingBonus, squadRole)` tam imzası ile provider'a bağlanmalı; rol taahhüdü oyuncu entity'sine işlenmelidir. | **KRİTİK** |
| [match_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/match_screen.dart) | OFİSE DÖN & MAÇI BİTİR (Canlı Maç Sonu) | 557, 1004 | **Atlanan Maç Sonu Ödül Arayüzü:** Hızlı maç simülasyonunda maç sonunda `MatchRewardDialog` (MOTM, tecrübe puanı ve primler) açılırken, canlı maç ekranında maç bittiğinde doğrudan `Navigator.pop` çağrılmakta; kullanıcı maç sonu ödüllerini görememektedir. | Canlı maç bitiş düdüğünün ardından "MAÇI BİTİR" butonuna basıldığında `MatchRewardDialog.show(...)` açılmalı ve kullanıcı ödülleri teyit ettikten sonra ofise dönmelidir. | **KRİTİK** |
| [office_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/office_screen.dart) | AL (Günlük Görev Ödülü) | 394-406 | **Kalıcı Olarak Kilitli Kalan Butonlar:** `q_play_league_match` (Lig Maçı Oyna) ve `q_club_development` (Tesis Geliştir) günlük görevlerinin sayaçları maç motorunda veya tesis yükseltildiğinde artırılmadığından buton `onPressed: null` olarak kilitli kalmaktadır. | `simulateMatch` ve `upgradeFacility` metotlarının başarıyla tamamlandığı noktalarda `updateDailyQuestProgress(questId, 1)` tetiklenmelidir. | **KRİTİK** |
| [cup_tournament_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/cup_tournament_screen.dart) | ÇEYREK/YARI FİNAL MAÇINI OYNA | 37-120 | **Kalıcı Olmayan Geçici Durum:** Kupa turnuvası eşleşmeleri ve ilerlemesi yerel `StatefulWidget` durumunda tutulmaktadır. Ekrandan çıkıldığında turnuva sıfırlanmakta, kupa şampiyonluğu kulüp müzesine veya kupa vitrinine yansımamaktadır. | Turnuva aşamaları ve sonuçları `GameState.cupTournament` olarak modellenmeli, maç simülasyonu kupa fikstürünü kalıcı olarak ilerletmelidir. | **KRİTİK** |
| [opposition_report_dialog.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/opposition_report_dialog.dart) | ANLAŞILDI, TAKTİK ODASINA DÖN | 1-120 | **Yetim (Orphan) UI Bileşeni:** Tam teşekküllü brutalist rakip analiz scout penceresi olarak kodlanmış olmasına rağmen ne Maç Merkezi'nden ne de canlı maç ekranından hiçbir butona bağlanmamıştır. | `office_screen.dart` Maç Merkezi kartına veya `match_screen.dart` başlama butonunun yanına "RAKİP ANALİZ RAPORU" butonu eklenerek bu diyalog açılmalıdır. | **ORTA** |
| [win_back_dialog.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/win_back_dialog.dart) | HİBEYİ KASAYA AKTAR & DEVAM ET | 1-92 | **Yetim UI Bileşeni & Çağrılmayan Notifier Metodu:** Oyuna uzun süre sonra dönen yöneticiler için hazırlanan diyalog ve bağlı `claimWinBackRewards` notifier metodu hiçbir ekrandan veya uygulama açılışından tetiklenmemektedir. | `main.dart` veya `office_screen.dart` açılışında son oturum açma zamanı denetlenmeli; 3 günden uzun aralıklarda bu karşılama modalı gösterilmelidir. | **ORTA** |
| [match_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/match_screen.dart) | MEŞALE & PANKART ŞOVU (-₣5K) | 509 | **Etkisiz Canlı Maç Aksiyon Butonu:** Yalnızca yerel `setState` ile `visibleEvents` listesine metin eklemektedir. Maç motoruna, taraftar coşkusuna veya saha içi baskıya hiçbir etkisi bulunmamaktadır. | Maç motoruna anlık taraftar momentumu aktaran `injectMatchMomentum(fanIntensity: +20)` çağrısı bağlanmalıdır. | **ORTA** |
| [match_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/match_screen.dart) | BOLT HOCAYA: HÜCUM ET | 523 | **Etkisiz Taktik Müdahale Butonu:** Yalnızca yerel `setState` ile metin yazdırmaktadır. Sahadaki takımın taktik dizilimine veya hücum agresifliğine hiçbir etkisi yoktur. | `liveMatchEngine.setTacticalIntervention(TacticalFocus.allOutAttack)` şeklinde canlı maç motoruna bağlanmalıdır. | **ORTA** |
| [match_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/match_screen.dart) | PRİM VADET (-₣10K) & DEV DERBİ PRİMİ (-₣25K) | 475, 491 | **Yanıltıcı API Çağrısı:** Kasadan nakit düşmek için yanlışlıkla `claimSponsorReward(-10000)` hack'i kullanılmıştır; ayrıca sahadaki oyuncuların moral veya kondisyonuna hiçbir etkisi yoktur. | Doğrudan `adjustCash(-amount)` çağrılmalı ve sahadaki 11 oyuncunun galibiyet hırsı / şut isabeti metriklerine geçici pozitif etki uygulanmalıdır. | **ORTA** |
| [league_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/league_screen.dart) | GOL VE ASİST KRALLIĞI LİSTESİ | 118-131 | **Statik Mock Veri & Tıklanamayan Satırlar:** Lig ekranında gol krallığı tablosu statik isimlerden oluşmaktadır; gerçek maç verileriyle beslenmemekte ve oyuncu profiline giden bir `onTap` bulunmamaktadır. | `currentLeague.topScorers` dinamik listesine bağlanmalı ve satıra tıklandığında `PlayerDetailScreen` açılmalıdır. | **ORTA** |
| [transfer_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/transfer_screen.dart) | OYUNCU TAKASI (SWAP) BUTONU | Yok | **Arayüzü Olmayan Backend Yeteneği:** `GameStateNotifier` içinde `swapPlayerTransfer` metodu ve `SwapEvaluationEngine` tam hazır olmasına karşın transfer arayüzünde takas teklif etme butonu bulunmamaktadır. | Transfer detay veya müzakere kartına "TAKAS TEKLİF ET" butonu eklenmeli ve kadrodan takas edilecek oyuncu seçimi sağlanmalıdır. | **ORTA** |
| [urgent_phone_call_modal.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/urgent_phone_call_modal.dart) | TELEFONU KAPAT / ERTELE BUTONU | Yok | **Eksik Arayüz Butonu & Yetim Notifier Çağrısı:** Modalda sadece 3 karar seçeneği bulunmaktadır. Notifier'da yazılmış olan `dismissCrisisCall()` metodunu tetikleyen bir "Telefonu Kapat/Ertele" butonu bulunmamaktadır. | Modala "ÇAĞRIYI ERTELE / DAHA SONRA ARA" butonu eklenmeli ve `dismissCrisisCall()` ile ilişkilendirilmelidir. | **ORTA** |
| [career_share_dialog.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/widgets/career_share_dialog.dart) | PAYLAŞ / KOPYALA | 101-106 | **Sahte Kopyalama Butonu:** Tıklandığında sadece SnackBar göstermekte, gerçekte sistem panosuna (`Clipboard.setData`) hiçbir kariyer özeti kopyalamamaktadır. | `Clipboard.setData(ClipboardData(text: summaryText))` eklenerek hanedan derecesi ve kupa sayısı panoya yazılmalıdır. | **DÜŞÜK** |
| [board_room_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/board_room_screen.dart) | BANKA KREDİSİ ÇEK (25K / 50K / 100K) | 396, 410, 424 | **Eski Tip Kredi Çağrısı:** Finans ekranındaki faizli ve vadeli kredi paketleri yerine yönetim kurulunda geri ödeme planı olmayan eski `takeBankLoan` çağrılmaktadır. | Butonlar finans ekranındaki resmi kredi paketleri modalına (`takeBankLoanPackage`) yönlendirilmelidir. | **DÜŞÜK** |
| [player_detail_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/player_detail_screen.dart) | BİREYSEL ANTRENMAN ŞİDDETİ SEÇİCİ | Yok | **Arayüzü Olmayan Notifier Fonksiyonu:** Notifier'da `setPlayerTraining(playerId, intensity)` metodu mevcut olmasına rağmen oyuncu detay ekranında antrenman yükünü değiştiren buton bulunmamaktadır. | Oyuncu kondisyon/fizik kartına 3 kademeli (Hafif / Normal / Yoğun) antrenman butonları eklenmeli ve bu metoda bağlanmalıdır. | **DÜŞÜK** |
| [head_coach_dialogue_screen.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/presentation/screens/head_coach_dialogue_screen.dart) | DİYALOG KONU SEÇİM KARTLARI | 155 | **Sadece Görsel Durum Değişimi:** Konu kartları tıklandığında yalnızca yerel `setState` ile seçim çerçevesi güncellenmekte, nihai onay butonu basılmadıkça akış askıda kalmaktadır. | Seçim anında teknik direktörün anlık nabız/tavır önizlemesi sunulmalı veya çift tıklama ile doğrudan talimata dönüştürülmelidir. | **DÜŞÜK** |
| [main.dart](file:///c:/Users/YSR_MONSTER/.antigravity/Futbol/lib/main.dart) | MENAJER NAVİGASYON İKONU | 197 | **Eksik İkon Tanımı:** Alt gezinme çubuğunda Menajer sekmesi için ikon metni boş bırakılmıştır (`(icon: '', label: 'MENAJER')`). | Brutalist vektör ikonu veya `[YÖNETİM]` metin etiketi atanmalıdır. | **DÜŞÜK** |

---

## 3. KRİTİK FONKSİYONEL KOPUKLUKLARIN DETAYLI ANALİZİ

### 3.1. Yönetim Kurulu Önerge Onayının Sahte Kalması (`boardroom_summit_screen.dart`)
Yönetim Kurulu Zirvesi ekranında (Satır 288-308) kulüp başkanı yasal önergeleri oylamaya sunmaktadır. Kabul edilen bir önerge için "ONAYLA & UYGULA" butonuna basıldığında:
```dart
RetroButton(
  onPressed: clubCash >= m.requiredCost
      ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.neonLime,
              content: Text('[HUKUK] ${m.title} kabul edildi ve yürürlüğe girdi!', style: const TextStyle(color: Colors.black)),
            ),
          );
        }
      : null,
  child: const Text('ONAYLA & UYGULA'),
)
```
Görüldüğü üzere buton `ref.read` çağırmamakta, bütçeyi kesmemekte, kazanımı (`rewardDescription`) GameState'e işlememekte ve önergeyi silmemektedir. Kullanıcı sadece bir SnackBar mesajı görmektedir.

### 3.2. Müteahhit İhalesinde Paranın Alınıp İnşaatın Başlatılmaması (`facilities_screen.dart`)
Tesisler ekranında yer alan ihale butonu (Satır 99-118), modal üzerinden bir müteahhit firma ile anlaşıldığında şu geri çağrımı çalıştırmaktadır:
```dart
onSelected: (cost, weeks, name) {
  ref.read(gameStateProvider.notifier).adjustCash(-cost);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('[TESİS] $name ile $weeks haftalık ihale sözleşmesi imzalandı (-₣$cost)!'),
    ),
  );
}
```
Kullanıcıdan sözleşme bedeli kesilmekte, ancak `upgradeFacility(FacilityType.stadium)` çağrılmadığı için stadyum seviyesi veya inşaat geri sayımı hiçbir zaman başlamamaktadır. Kullanıcı parasını kalıcı olarak kaybetmekte ve hiçbir tesis kazanımı elde edememektedir.

### 3.3. Erken Kredi Ödemesinde Borcun Ekranda Asılı Kalması (`finance_screen.dart`)
Finans ekranında (Satır 946) aktif banka kredisini %10 erken ödeme indirimiyle kapatmak isteyen kullanıcı butona bastığında:
`repayBankLoanEarly()` çağrılmakta, kullanıcıdan para tahsil edilmekte, ancak `GameState.copyWith` metodundaki `activeLoan ?? this.activeLoan` yapısı nedeniyle nesneye `null` atanamamaktadır. Sonuç olarak kullanıcı borcunu ödemiş olmasına karşın ekranda kredi açık kalmaya ve her hafta faiz kesmeye devam etmektedir.

### 3.4. Başkanlık Talimatlarında Parametrelerin Buharlaşması (`presidential_directives_modal.dart`)
Kadro ekranındaki başkanlık talimatları modalında kullanıcı bir oyuncuyu kadro dışı bırakmak ve yeni bir kaptan atamak için seçim yapmaktadır:
```dart
ref.read(gameStateProvider.notifier).formalizePresidentialDirectives();
```
Çağrılan fonksiyon hiçbir parametre almamaktadır! Modal içinde seçilen `_selectedBannedPlayerId` ve `_selectedCaptainId` yerel state değişkenleri fonksiyona hiç gönderilmediği için oyuncu asla kadro dışı kalmamakta, kaptanlık unvanı değişmemektedir.

### 3.5. Canlı Maç Simülasyonunda Ödül Arayüzünün Atlanması (`match_screen.dart`)
Hızlı maç simülasyonu ofis ekranında tamamlandığında `MatchRewardDialog` açılarak maçın adamı, primler ve menajerlik tecrübe puanları oyuncuya teslim edilmektedir. Ancak canlı maç ekranında (`match_screen.dart:557 & 1004`) maç bittiğinde:
```dart
Navigator.of(context).pop();
```
çalıştırılmakta, ödül ve tecrübe ekranı gösterilmeden doğrudan ofise dönülmektedir. Canlı maçı yöneten kullanıcı bu ödül akışından mahrum kalmaktadır.

---

## 4. YETİM (ORPHAN) BİLEŞEN VE FONKSİYON LİSTESİ

Aşağıdaki bileşenler ve sağlayıcı fonksiyonları projede eksiksiz kodlanmış olmasına karşın kullanıcı arayüzünde hiçbir butona bağlanmamış durumdadır:

1. **`OppositionReportDialog` (`lib/presentation/widgets/opposition_report_dialog.dart`):**
   - Rakip takımın taktik dizilişi, kilit tehditleri ve zafiyet analizlerini sunan brutalist scout diyaloğudur. Arayüzde hiçbir giriş butonu yoktur.
2. **`WinBackDialog` (`lib/presentation/widgets/win_back_dialog.dart`):**
   - Oyuna geri dönen menajerlere kulüp başkanı hibe fonu sunan diyalogdur. Arayüzde hiçbir tetikleyicisi yoktur.
3. **`swapPlayerTransfer` (`lib/application/providers/game_state_provider.dart:2635`):**
   - Oyuncu takası transfer mekanizması backend ve domain seviyesinde hazır olmasına rağmen transfer arayüzünde takas butonu bulunmamaktadır.
4. **`setPlayerTraining` (`lib/application/providers/game_state_provider.dart:1391`):**
   - Oyuncunun antrenman yoğunluğunu ayarlayan fonksiyon hazırdır ancak oyuncu detay ekranında kontrolü yoktur.
5. **`dismissCrisisCall` (`lib/application/providers/game_state_provider.dart:519`):**
   - Acil kriz telefonunu erteleme/kapatma fonksiyonu hazırdır ancak telefon modalında butonu yoktur.

---

## 5. DÜZELTME VE İYİLEŞTİRME YOL HARİTASI

Denetim bulgularının çözüme kavuşturulması için önerilen teknik sıra:

1. **Faz 1: Veri Güvenliği ve Kasa Bütünlüğü (Kritik Öncelik)**
   - `boardroom_summit_screen.dart` içindeki önerge butonuna `passBoardroomMotion` metodunun yazılıp bağlanması.
   - `facilities_screen.dart` müteahhit ihalesinde nakit kesintisiyle eş zamanlı `upgradeFacility` döngüsünün başlatılması.
   - `finance_screen.dart` erken kredi kapama aksiyonunda `activeLoan` nesnesinin kalıcı olarak `null` yapılabilmesi için `GameState` yapısının güncellenmesi.
   - `presidential_directives_modal.dart` fonksiyonuna `bannedPlayerId` ve `captainId` parametrelerinin eklenmesi.

2. **Faz 2: Oyun Döngüsü ve Canlı Maç Entegrasyonu (Kritik Öncelik)**
   - `match_screen.dart` canlı maç bitiş noktasına `MatchRewardDialog.show(...)` açılışının eklenmesi.
   - `office_screen.dart` günlük görev sayaçlarının lig maçı oynandığında ve tesis geliştirildiğinde artırılması.
   - `cup_tournament_screen.dart` yerel durumunun `GameState` içine kalıcı olarak taşınması.

3. **Faz 3: Yetim Bileşenlerin ve Eksik Butonların Bağlanması (Orta Öncelik)**
   - `match_screen.dart` öncesine veya `office_screen.dart` maç merkezine `OppositionReportDialog` butonunun eklenmesi.
   - `main.dart` veya `office_screen.dart` açılışına `WinBackDialog` kontrolünün yerleştirilmesi.
   - Transfer ekranına "TAKAS TEKLİF ET" arayüzünün ve modalının eklenmesi.
   - Acil telefon modalına `dismissCrisisCall` tetikleyen "KAPAT / ERTELE" butonunun eklenmesi.

4. **Faz 4: Mikro Etkileşim ve UI İyileştirmeleri (Düşük Öncelik)**
   - `career_share_dialog.dart` butonuna gerçek `Clipboard.setData` fonksiyonunun eklenmesi.
   - `main.dart` menajer sekmesine eksik olan navigasyon ikonunun tanımlanması.
   - `player_detail_screen.dart` içine bireysel antrenman şiddeti seçicisinin yerleştirilmesi.
