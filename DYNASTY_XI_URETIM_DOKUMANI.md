# DYNASTY XI — Futbol Kulübü Tycoon/RPG
## Sıfırdan Sona Üretim Dokümanı (Game Design + Brand + Tech + Live-Ops Bible)

| | |
|---|---|
| **Doküman sürümü** | v1.0 |
| **Tarih** | 16 Ağustos 2026 |
| **Platform** | iOS 14+ / Android 8+ (API 26+) |
| **Teknoloji** | Flutter 3.3x · Dart 3.x · Firebase/Supabase hibrit |
| **Tür** | Management Tycoon + Narrative RPG + Card Decision |
| **İş modeli** | Free-to-Play · IAP + Rewarded Ads + Sezon Bileti |
| **Hedef pazarlar** | TR, BR, MX, ID, EG, DE, UK, ES, IT (aşamalı) |
| **Doküman sahibi** | Kurucu / Game Director |

---

## 0. BU DOKÜMAN NASIL KULLANILIR

Bu doküman **tek kaynaklı gerçek (single source of truth)** olarak tasarlandı. Her bölüm bağımsız okunabilir ama sayısal değerler birbirine bağlı — bir sayıyı değiştirirsen **§15 Ekonomi Denge Tablosu**'nu ve **§20 KPI hedeflerini** de güncelle.

**Rol bazlı okuma sırası:**

| Rolün | Önce oku | Sonra |
|---|---|---|
| Solo geliştirici | §1, §6, §25 (MVP kapsamı), §19 | Kalan her şey |
| Game Designer | §6–§14, §15, §17 | Ek A (kart kütüphanesi) |
| Flutter Developer | §19, §11.4 (sim), Ek B (şemalar) | §21 (UI) |
| Artist / UI | §2 (marka), §21, §22 | §8 (tesis görselleri) |
| Marketing / ASO | §2.7, §3, §27 | §17 (retention hikâyesi) |
| Yatırımcıya sunum | §1, §3, §16, §25.4 | — |

**Renk kodu konvansiyonu:**
- 🟢 **MVP** — İlk sürümde olmalı (soft launch)
- 🟡 **v1.1–v1.3** — Global lansman öncesi
- 🔵 **Live-Ops** — Lansman sonrası, 6–18 ay
- ⚫ **Backlog** — Nice-to-have, ölçüm sonrası karar

---

## İÇİNDEKİLER

**BÖLÜM I — STRATEJİ VE KİMLİK**
1. [Yönetici Özeti](#1-yönetici-özeti)
2. [Marka Kimliği](#2-marka-kimliği)
3. [Pazar ve Rakip Analizi](#3-pazar-ve-rakip-analizi)
4. [Hedef Kitle ve Personalar](#4-hedef-kitle-ve-personalar)
5. [Tasarım Sütunları (Design Pillars)](#5-tasarım-sütunları)

**BÖLÜM II — OYUN TASARIMI**
6. [Zaman Modeli ve Core Loop](#6-zaman-modeli-ve-core-loop)
7. [Onboarding / FTUE — Dakika Dakika](#7-onboarding--ftue)
8. [Kulüp, Tesisler ve İnşa Ağacı](#8-kulüp-tesisler-ve-i̇nşa-ağacı)
9. [Oyuncu ve Kadro Sistemi](#9-oyuncu-ve-kadro-sistemi)
10. [Transfer Pazarı ve Scouting](#10-transfer-pazarı-ve-scouting)
11. [Maç Simülasyonu ve Taktik](#11-maç-simülasyonu-ve-taktik)
12. [Karar Kartları Sistemi](#12-karar-kartları-sistemi)
13. [Menajer RPG Katmanı](#13-menajer-rpg-katmanı)
14. [Meta İlerleme, Lig Piramidi, Sezon Döngüsü](#14-meta-i̇lerleme)

**BÖLÜM III — EKONOMİ VE PSİKOLOJİ**
15. [Ekonomi Tasarımı ve Denge](#15-ekonomi-tasarımı-ve-denge)
16. [Monetizasyon](#16-monetizasyon)
17. [Psikoloji, Hook Modeli ve Retention Mimarisi](#17-psikoloji-hook-modeli-ve-retention-mimarisi)
18. [Bildirim, CRM ve Win-Back](#18-bildirim-crm-ve-win-back)

**BÖLÜM IV — ÜRETİM**
19. [Teknik Mimari (Flutter)](#19-teknik-mimari-flutter)
20. [Analytics, KPI ve A/B Test](#20-analytics-kpi-ve-ab-test)
21. [UI/UX ve Tasarım Sistemi](#21-uiux-ve-tasarım-sistemi)
22. [Ses ve Müzik](#22-ses-ve-müzik)
23. [İçerik Üretimi ve Lokalizasyon](#23-i̇çerik-üretimi-ve-lokalizasyon)
24. [Hukuk, Uyumluluk ve Mağaza Politikaları](#24-hukuk-uyumluluk-ve-mağaza-politikaları)
25. [Prodüksiyon Planı, Ekip, Bütçe](#25-prodüksiyon-planı-ekip-bütçe)
26. [Risk Kaydı](#26-risk-kaydı)
27. [Soft Launch ve Global Lansman](#27-soft-launch-ve-global-lansman)
28. [Live-Ops Takvimi](#28-live-ops-takvimi)

**EKLER**
- [Ek A — Karar Kartı Kütüphanesi (50 kart)](#ek-a--karar-kartı-kütüphanesi)
- [Ek B — Veri Şemaları (JSON/Dart)](#ek-b--veri-şemaları)
- [Ek C — Formül Sayfası](#ek-c--formül-sayfası)
- [Ek D — İsim ve İçerik Havuzları](#ek-d--i̇sim-ve-i̇çerik-havuzları)
- [Ek E — Analytics Event Sözlüğü](#ek-e--analytics-event-sözlüğü)
- [Ek F — SSS: "Aklına Gelecek Her Soru"](#ek-f--sss)
- [Ek G — Terim Sözlüğü](#ek-g--terim-sözlüğü)
- [Ek H — Kontrol Listeleri](#ek-h--kontrol-listeleri)

---
---

# BÖLÜM I — STRATEJİ VE KİMLİK

## 1. YÖNETİCİ ÖZETİ

### 1.1 Tek Cümlelik Tanım
> **Dynasty XI**, oyuncunun 20. ligdeki bir amatör kulübü devralıp, transfer pazarında pazarlık yaparak, tesis inşa ederek ve her gün karşısına çıkan zor kararları vererek Avrupa'nın en büyük futbol hanedanına dönüştürdüğü; günde 3–5 dakikalık kısa seanslara bölünmüş, hikâye kartlarıyla anlatılan bir futbol tycoon RPG'sidir.

### 1.2 Elevator Pitch (30 sn)
"Football Manager çok derin, çok zaman istiyor. Top Eleven çok PvP ve ödeme baskılı. **Dynasty XI** ikisinin arasında: 3 dakikada bir seans, ama gerçek bir yönetim hissi. *Reigns* gibi kart kararları veriyorsun — 'Yıldız oyuncun zam istiyor, kabul mü, tehdit mi?' — ve bu kararlar dört göstergeyi (Kasa, Taraftar, Soyunma Odası, Başkanın Güveni) hareket ettiriyor. Yanlış yönetirsen **kovuluyorsun**. Sezonlar 7 gerçek gün sürüyor, yani her Pazar bir final, her Pazartesi bir yeni başlangıç var."

### 1.3 Neden Bu Oyun, Neden Şimdi

| Fırsat | Kanıt / Gerekçe |
|---|---|
| Futbol yönetim türü mobilde **derinlik açığı** yaşıyor | Top Eleven (10+ yıl) ve SM (basit) arasında modern, hikâye odaklı bir ürün yok |
| **Narrative-choice** mekaniği türe hiç uygulanmadı | Reigns/Choices tarzı kart kararları, yönetim temasıyla doğal eşleşiyor ama pazarda örneği yok |
| Kısa seans + yüksek frekans yeni normal | 2024+ mobil kullanıcı ortalama seansı 3–5 dk; 45 dakikalık maç izleme modeli ölüyor |
| Futbol = evrensel + düşük CPI | TR/BR/MX/ID/EG'de futbol CPI'ı $0.35–1.20 aralığında, kadın+erkek karma erişim |
| Flutter ile **tek kod tabanı** | Sim motoru saf Dart; UI ağır 3D gerektirmiyor → küçük ekip ile mümkün |
| Lisanssız üretim mümkün | Prosedürel oyuncu/kulüp üretimi ile FIFPro lisansına ihtiyaç yok (§24.2) |

### 1.4 Farklılaşma Üçlüsü (Bu 3 şey olmazsa oyun sıradan)
1. **Kovulma Riski** — Diğer futbol oyunlarında kaybedecek bir şey yok. Burada dört göstergeden biri dibe vurursa işini kaybedersin, kariyerin sekteye uğrar. Gerçek gerilim = gerçek bağlanma.
2. **Karar Kartları** — Her seansın kalbi maç değil, **karar**. Maç sonucun kararlarının sonucudur.
3. **7 Günlük Sezon** — Takvimle senkron. Pazartesi umut, Pazar final. Haftalık ritim retention'ı yapıya gömer.

### 1.5 Hedeflenen Sonuçlar (Soft Launch → Global)

| Metrik | Soft Launch eşiği | Global hedef | "İyi" sayılan sektör bandı |
|---|---|---|---|
| D1 Retention | ≥ %38 | %45–50 | %35–45 |
| D7 Retention | ≥ %16 | %22–25 | %13–20 |
| D21 Retention | ≥ %9 | %13–15 | %7–11 |
| D30 Retention | ≥ %7 | %10–12 | %5–9 |
| Günlük seans / DAU | ≥ 2.8 | 4.0–5.5 | 2–4 |
| Ortalama seans süresi | ≥ 4 dk | 5–7 dk | 3–6 dk |
| Payer Conversion (D30) | ≥ %1.8 | %3.0–4.0 | %1.5–3 |
| ARPDAU | ≥ $0.055 | $0.10–0.15 | $0.05–0.20 |
| LTV(180) / CPI | ≥ 1.0 | ≥ 1.6 | ≥ 1.3 sağlıklı |
| Crash-free users | ≥ %99.2 | ≥ %99.6 | %99+ |

### 1.6 MVP Kapsamı — Tek Paragraf
🟢 20 lig kademesi, prosedürel 4.000 oyuncu, 7 günlük sezon, 21 maç fikstür, olay-tabanlı maç simülasyonu (hızlı sim + 90 sn canlı mod), 4 göstergeli karar kartı sistemi (200 kart), 12 tesis / 5 seviye, transfer pazarı + pazarlık, scouting, menajer seviyesi 1–30 + 3 uzmanlık dalı, sezon bileti + 6 IAP paketi, rewarded ads, TR+EN lokalizasyon. **Bunun dışındaki her şey v1.1+.**

---

## 2. MARKA KİMLİĞİ

### 2.1 İsim Kararı

**Birincil isim: `DYNASTY XI`**
**Store başlığı (EN):** `Dynasty XI: Football Tycoon`
**Store başlığı (TR):** `Dynasty XI: Futbol Kulübü Tycoon`

**Neden bu isim:**

| Kriter | Değerlendirme |
|---|---|
| Anlam | "Dynasty" = hanedan/imparatorluk → tycoon'un uzun vadeli inşa vaadi. "XI" = ilk on bir → futbolun evrensel simgesi. İkisi birlikte "kuşaklar boyu süren bir takım kurma" fikrini tek başlıkta veriyor. |
| Telaffuz | TR'de "daynesti onbir" olarak kolayca okunuyor; İngilizce doğal. |
| ASO | "Dynasty" ve "Football" ayrı ayrı yüksek hacimli, kombinasyonu düşük rekabetli. XI karakteri başlıkta görsel imza. |
| Görsellik | "XI" tek başına bir logo işareti olabiliyor (monogram) — ikon, forma sırtı, splash. |
| Genişleme | "Dynasty XI: Legends", "Dynasty XI World" gibi seri uzatmaya açık. |
| Risk | "Dynasty" jenerik bir kelime — tek başına marka tescili zor, **birleşik marka (Dynasty XI)** tescil edilmeli. |

**Alternatifler (yedek / bölgesel test için):**

| İsim | Güçlü yanı | Zayıf yanı | Kullanım |
|---|---|---|---|
| **Boot Room** | Futbol kültüründe derin anlam (Liverpool'un efsanevi teknik ekip odası) | TR kullanıcısı anlamıyor, ASO zayıf | ⚫ Hardcore niş sürüm |
| **Club Empire XI** | Tycoon'u net söylüyor | Klişe, çok "empire" oyunu var | 🟡 A/B test adayı |
| **The Gaffer** | Karakterli, RPG hissini güçlü veriyor | Sadece UK argosu, global anlaşılmaz | ⚫ |
| **Matchday Dynasty** | Ritim + inşa birleşimi | Uzun, ikonda sığmaz | 🟡 |
| **Efsane 11** | TR pazarında sıcak | Sadece TR, global taşınmaz | 🔵 TR store subtitle olarak kullan |
| **Kulüp Reisi** | TR'de akılda kalıcı, mizahi | Global yok | 🔵 TR pazarlama sloganı |

**⚠ Yapılacak (lansman öncesi zorunlu):**
1. TÜRKPATENT ve EUIPO'da "Dynasty XI" marka araması → Nice sınıf 9 (yazılım) + 41 (eğlence hizmetleri)
2. App Store & Play'de tam isim çakışması araması
3. `dynastyxi.com`, `dynastyxi.app` domain + @dynastyxi sosyal handle rezervasyonu
4. Google Trends + AppTweak ile arama hacmi doğrulaması

### 2.2 Marka Konumlandırma İfadesi

> **Futbolu seven ama Football Manager'a 4 saat ayıramayan insan için**, Dynasty XI, kahve molasında verilen üç kararla kulüp kaderini değiştirebildiğin bir futbol tycoon oyunudur. Rakiplerinden farkı: burada takımı sen dizmiyorsun — **kulübü sen yönetiyorsun**, ve her kararın bir bedeli var.

### 2.3 Marka Kişiliği ve Ses Tonu

**Kişilik arketipi:** *The Ruler* (Yönetici) + hafif *The Rebel* dokunuşu.
Kendine güvenen, ironik, futbol argosuna hakim ama küfretmeyen bir "eski kurt yönetici" sesi.

| Ses Tonu | ✅ Yap | ❌ Yapma |
|---|---|---|
| Metin uzunluğu | Kısa, gazete manşeti ritmi | Paragraf paragraf açıklama |
| Mizah | Kuru, futbol camiasına gönderme ("Başkan yine televizyona çıkmış.") | Emoji spamı, çocuksu şaka |
| Otorite | "Karar senin." | "Lütfen bir seçenek seçiniz." |
| Baskı | "Taraftar sabırsız." | "SON ŞANS!! HEMEN AL!!" |
| Kayıp anlatımı | "Bu maçı kaybettik. Soyunma odası sessiz." | "Üzgünüz :( Tekrar dene!" |

**Marka sözlüğü (her yerde tutarlı kullan):**
- Oyuncu karakteri → **"Menajer"** (Türkçe'de teknik direktör + yönetici karışımı; oyunda ikisi de sensin)
- Para → **"Kasa"** (₺/€ değil, jenerik "₣" para birimi sembolü — bkz §15.1)
- Premium kur → **"Altın Rozet"** (💠 değil, futbolvari)
- Karar kartı → **"Masa"** ("Masana bir dosya geldi.")
- Sezon → **"Sezon"** (numaralı: Sezon 7)
- Kovulma → **"Görevden Alınma"**

### 2.4 Logo ve İşaret Sistemi

**Ana logo (wordmark + monogram):**
```
   ╔═══════╗
   ║  XI   ║      DYNASTY
   ╚═══════╝      ─── XI ───
   Kalkan/rozet   FOOTBALL TYCOON
```

**Yapı:**
1. **Monogram:** Kalkan (futbol arma silueti) içinde stilize **XI**. Rakam serifsiz, kalın, hafif italik (hız hissi). Kalkanın alt ucu sivri (klasik arma), üst kenar düz.
2. **Wordmark:** DYNASTY — geniş harf aralıklı (letter-spacing +0.18em), tümü büyük harf, ağır ağırlık.
3. **Descriptor:** FOOTBALL TYCOON — ince, küçük, %60 opaklık.

**Uygulama kuralları:**
- Minimum boyut: monogram 24×24 px, tam kilit 120 px genişlik
- Boşluk alanı (clear space): monogram yüksekliğinin %25'i, her yönde
- Tek renk versiyonu zorunlu (beyaz / siyah)
- **Yasak:** logoyu eğme, gradyan ekleme, gölge, çerçeveyi bozma, XI'ı ayrı kullanma (monogram dışında)

**Uygulama ikonu (App Icon) konsepti:**
- Arka plan: derin gece yeşili → siyah dikey gradyan (#0B2E20 → #05120C)
- Merkez: altın (#D9A62E) kalkan + XI
- Kalkanın arkasında hafif stadyum ışığı ışını (subtle radial)
- **Test:** 48×48'e küçültüldüğünde XI hâlâ okunmalı. Okunmuyorsa kalkanı büyüt, ışını sil.
- A/B varyantları: (a) altın kalkan, (b) yeşil saha + beyaz XI, (c) menajer silueti + XI. Play Store Custom Store Listing ile test et.

### 2.5 Renk Paleti

**Ana palet:**

| Rol | İsim | HEX | Kullanım |
|---|---|---|---|
| Primary Dark | Gece Sahası | `#0B2E20` | Ana arka plan, üst bar |
| Primary Deep | Tribün Karası | `#05120C` | Gradyan uçları, modal arka |
| Accent Gold | Kupa Altını | `#D9A62E` | CTA, premium, başarı, kupa |
| Accent Gold Lt | Işık Altını | `#F2C75C` | Altın hover/parıltı |
| Signal Green | Saha Yeşili | `#2FBF71` | Pozitif değişim, gelir, +stat |
| Signal Red | Kırmızı Kart | `#E23D3D` | Negatif, sakatlık, gider, risk |
| Signal Amber | Sarı Kart | `#F2A93B` | Uyarı, sözleşme bitiyor, düşük moral |
| Neutral 900 | Kömür | `#14181B` | Kart yüzeyi (dark) |
| Neutral 700 | Duman | `#2A3138` | Ayraç, disabled |
| Neutral 300 | Saha Çizgisi | `#B9C2C9` | İkincil metin |
| Neutral 50 | Kireç | `#F5F7F8` | Ana metin (dark tema) |
| Rival Blue | Rakip Mavisi | `#3B82F6` | Rakip takım, karşılaştırma |

**Kural:** Oyun **dark-first** tasarlanır (gece maçı hissi). Light tema v1.2'de ⚫ opsiyonel.

**Nadirlik renkleri (oyuncu kartları):**

| Nadirlik | Renk | HEX | Anlamı |
|---|---|---|---|
| Amatör | Gri | `#8A9199` | 1★ |
| Profesyonel | Yeşil | `#2FBF71` | 2★ |
| Kaliteli | Mavi | `#3B82F6` | 3★ |
| Yıldız | Mor | `#8B5CF6` | 4★ |
| Efsane | Altın | `#D9A62E` | 5★ |
| İkon | Beyaz-alev | `#FFFFFF` + animasyon | 5★+ özel |

**Erişilebilirlik:** Metin/arka plan kontrastı ≥ 4.5:1 (WCAG AA). Kırmızı-yeşil ayrımı **asla tek başına** anlam taşımaz — daima ok işareti (▲▼) veya +/− işaretiyle birlikte (§21.8).

### 2.6 Tipografi

| Rol | Font | Ağırlık | Neden |
|---|---|---|---|
| Başlık / Sayı | **Barlow Condensed** | 600/700 | Spor tabelası estetiği, dar → küçük ekranda çok bilgi |
| Gövde metin | **Inter** | 400/500/600 | Yüksek okunabilirlik, tüm dilleri destekler |
| Sayısal vurgu (skor, para) | **Barlow Condensed** tabular-nums | 700 | Rakamlar hizalı akar |
| Kart hikâye metni | **Inter** | 400, 1.55 line-height | Uzun okuma konforu |

Her ikisi de Google Fonts / SIL Open Font License → ticari kullanım serbest, gömme (embedding) serbest.

**Tip ölçeği (Flutter TextTheme eşlemesi):**

| Token | Boyut | Ağırlık | Kullanım |
|---|---|---|---|
| `display` | 34 | 700 | Skor, sezon numarası |
| `h1` | 26 | 700 | Ekran başlığı |
| `h2` | 20 | 600 | Bölüm başlığı |
| `h3` | 17 | 600 | Kart başlığı |
| `body` | 15 | 400 | Genel metin |
| `bodyS` | 13 | 400 | Yardımcı metin |
| `label` | 12 | 600, +0.06em | Buton, etiket, sekme |
| `mono` | 13 | 500 tabular | Tablo sayıları |

### 2.7 App Store / Play Store Metinleri (ASO Paketi)

**iOS Başlık (30 karakter):**
`Dynasty XI: Football Tycoon` (27)

**iOS Alt Başlık (30 karakter):**
`Build your club empire` (22)

**Play Store Başlık (30 karakter):**
`Dynasty XI: Football Tycoon`

**Play Kısa Açıklama (80 karakter):**
`Sign stars, build your stadium, survive the boardroom. Your club, your rules.` (76)

**Uzun Açıklama (EN, ilk 3 satır kritik — "Read more" öncesi):**
```
You just took over a 20th-division club with an empty bank account and
a locker room that doesn't trust you. In 8 weeks the board decides if
you stay. Every decision counts.

⚽ RUN A REAL CLUB
Sign players in a living transfer market. Negotiate wages, agents,
release clauses. Build training grounds, youth academies, and expand
your stadium tier by tier.

🃏 DECISION CARDS
Your star wants a raise. The press wants blood. The ultras want the
manager's head. Swipe left or right — but every choice moves four
meters: Bank, Fans, Locker Room, Board Trust. Let one hit zero and
you're sacked.

📈 CLIMB 20 DIVISIONS
Seasons last 7 real days. 21 league matches, cups, promotions,
relegations. Reach the Elite League and start a dynasty.

🎯 90-SECOND MATCHES
Watch key moments unfold and make live tactical calls — or fast-sim
and get straight to the result.

🏆 NO GRIND WALLS
No energy bar. Play as much as you want. Progress by making better
decisions, not by paying more.
```

**Türkçe uzun açıklama (ilk 3 satır):**
```
20. ligde, kasası boş ve sana güvenmeyen bir soyunma odasıyla bir
kulüp devraldın. Yönetim 8 hafta sonra kalıp kalmayacağına karar
verecek. Her karar sayılıyor.
```

**Anahtar kelime alanı (iOS, 100 karakter, virgülle, boşluksuz):**
```
manager,soccer,club,transfer,tycoon,league,stadium,coach,team,career,sim,cards,idle,legend
```

**Ekran görüntüsü sırası (kanıtlanmış dönüşüm sırası):**
1. **Karar kartı** — "Yıldızın zam istiyor" + 4 gösterge (en özgün mekanik önce)
2. **Görevden alınma sayacı** — "Yönetim güveni: %23" (gerilim)
3. **Transfer pazarlığı** — pazarlık slider'ı
4. **Stadyum inşası** — önce/sonra
5. **Lig tablosu** — 20→1 tırmanış
6. **Maç canlı anı** — 89' gol
7. Sosyal kanıt — "4.7★ · 500K menajer"

**Video/Preview:** 15 saniye, ses kapalı anlaşılır olmalı, ilk 3 saniyede kart kaydırma.

### 2.8 Ses Kimliği (Sonic Branding)
- **Mnemonic:** 1.2 saniyelik, düşük→yüksek iki nota + stadyum uğultusu kuyruğu. Splash'te ve kupa kazanınca çalar.
- Detaylar §22'de.

### 2.9 Marka Varlıkları Teslim Listesi

| Varlık | Format | Boyutlar |
|---|---|---|
| App Icon | PNG | 1024×1024 (mağaza) + tüm mipmap/AppIcon setleri |
| Adaptive Icon (Android) | PNG | foreground 432×432, background 432×432 |
| Logo yatay kilit | SVG + PNG@3x | vektör |
| Logo monogram | SVG + PNG@3x | vektör |
| Feature Graphic (Play) | PNG | 1024×500 |
| Ekran görüntüsü seti | PNG | iPhone 6.7"/6.5"/5.5", iPad 12.9", Android telefon/tablet |
| Promo video | MP4 H.264 | 1080×1920, ≤30 sn |
| Splash / Launch | PNG | 9 yoğunluk |
| Sosyal medya kiti | PNG | 1080×1080, 1200×675, 1080×1920 |
| Marka kılavuzu PDF | PDF | 12 sayfa |

---
## 3. PAZAR VE RAKİP ANALİZİ

### 3.1 Pazar Büyüklüğü ve Konum

Mobil spor-yönetim (sports management sim) alt türü, mobil oyun pazarının küçük ama **yüksek LTV'li** bir dilimi. Kullanıcı başına ortalama gelir aksiyon oyunlarının 2–3 katı, çünkü:
- Oyuncular türü **yıllarca** oynuyor (retention eğrisi düz, dik değil)
- Ödeme motivasyonu "kolaylık" değil **"kulübüm"** — duygusal sahiplik
- Reklam toleransı yüksek (menajer oyuncusu ödüllü reklamı "sponsor anlaşması" olarak kabul ediyor)

**Bizim TAM/SAM/SOM yaklaşımımız:**
- **TAM:** Mobil futbol oyunu oynayan küresel kitle — çok büyük ama alakasız (çoğu arcade)
- **SAM:** Yönetim/tycoon türüne ilgi duyan futbol oyuncusu — hedefimiz
- **SOM (3 yıl):** SAM'in %1–2'si, 3–6M yükleme, 250–500K MAU

> **Not:** Bu doküman içinde kesin pazar rakamları vermiyorum çünkü hızla eskiyor. Lansman öncesi Sensor Tower / data.ai / AppMagic üzerinden **kendi rakip listenle** güncel indirme+gelir verisini çek ve bu bölümü doldur. Kontrol listesi Ek H.3'te.

### 3.2 Rakip Haritası

| Oyun | Güçlü Yanı | Zayıf Yanı | Bizim Cevabımız |
|---|---|---|---|
| **Top Eleven** | Devasa PvP altyapısı, canlı maç, 10+ yıllık topluluk | Ağır PvP baskısı, "pay-to-compete" algısı, eskimiş UI, seans uzun | PvP'yi zorunlu tutmuyoruz; asenkron lig. Modern UI. Kararlar merkezde. |
| **Football Manager Mobile** | Derinlik, marka gücü, gerçek lisanslar | Ücretli, yıllık sürüm, uzun seans, mobil-doğal değil | F2P, 3 dakikalık seans, dokunmatik-doğal |
| **Soccer Manager 20XX** | Ücretsiz, geniş veritabanı | Sığ mekanik, zayıf görsel, monetizasyon zayıf | Aynı erişilebilirlik + hikâye katmanı + görsel kalite |
| **Club Soccer Director** | Tesis/kulüp inşası fikri var | Kaba UX, sığ ekonomi, retention zayıf | İnşa ağacını ekonomik dengeye tam bağlıyoruz |
| **Golden Boot / Idle Eleven** | Idle döngü, çok kolay giriş | Sığ, hızla tükeniyor, "boş" hissi | Idle geliri var ama **karar** çekirdek |
| **Reigns (tür dışı)** | Kart kararı mekaniği mükemmel | Meta ilerleme yok, kısa ömür | Kart mekaniğini kalıcı tycoon meta'sına bağlıyoruz — bu boşluk bizim |
| **FIFA/eFootball Mobile** | Lisans, grafik, marka | Yönetim yok, oyun oynama odaklı | Rakip değil, kullanıcı havuzu kaynağı (çapraz ilgi) |

### 3.3 Türün Ölümcül Hataları (Yapmayacaklarımız)

Bu tür sürekli aynı beş hatayla kullanıcı kaybediyor:

1. **Excel hissi.** Tablo tablo sayı gösterip "yönetim" demek. → Biz her sayıyı bir **cümleye** çeviriyoruz ("Ahmet, kadroda oynamadığı için küskün" > "Moral: 34").
2. **Boş bekleme.** İnşaat/antrenman zamanlayıcıları tek eğlence olunca oyun bir bildirim uygulamasına dönüşüyor. → Bekleme sadece **arka planda**; her açılışta yapacak iş var.
3. **PvP zorbalığı.** Ödeme yapan rakiplerin karşısında ezilme. → Ana ilerleme **PvE**; PvP opsiyonel lig sıralaması, ödülleri kozmetik/kaynak ağırlıklı.
4. **Sonu olmayan grind.** 40. seviyeden sonra ilerleme durup "aynı gün"ün tekrarı. → Prestij/yeni kulüp döngüsü + sezon değişimi + hikâye kampanyaları.
5. **Duygusuz kayıp.** Maçı kaybetmenin hiçbir anlamı yok. → Kayıplar dört göstergeyi hareket ettiriyor, kariyeri tehdit ediyor.

### 3.4 Rekabetçi Kırılma Noktamız — "Boşluk Analizi"

```
                    DERİNLİK (yüksek)
                          ▲
                          │
        Football Manager  │
             Mobile ●     │
                          │
                          │      ◆ DYNASTY XI
                          │        (hedef konum)
  ────────────────────────┼────────────────────────►
  UZUN SEANS              │             KISA SEANS
                          │
              Top Eleven ●│  ● Soccer Manager
                          │        ● Idle Eleven
                          │
                    DERİNLİK (düşük)
```

**Boşluk:** "Kısa seans + yüksek algılanan derinlik". Bu boşluğu dolduran mekanik **karar kartları**dır — 8 saniyede alınan bir karar, 40 dakikalık taktik ayarının verdiği "sonucu ben belirledim" hissini verir.

---

## 4. HEDEF KİTLE VE PERSONALAR

### 4.1 Birincil Kitle
- **Yaş:** 18–34 (çekirdek 22–30)
- **Cinsiyet:** %78 erkek / %22 kadın (tür ortalaması; kadın oranını %30'a çıkarmak hedef — bkz §4.5)
- **Davranış:** Günde 3–6 kez, 3–6 dakika. Metroda, kuyrukta, yatakta.
- **Motivasyon (Quantic Foundry çerçevesi):** Mastery(Strateji) > Achievement(Tamamlama) > Immersion(Fantezi) > Social(Rekabet)
- **Cihaz:** Orta segment Android (2–4 GB RAM) ağırlıklı TR/BR/ID; iPhone ağırlıklı UK/DE

### 4.2 Persona 1 — "Kerem, 26, Kadıköy" (Çekirdek)
> Yazılımcı. Fenerbahçe taraftarı. FM'i bilgisayarda oynamış ama 3 sezon sonra bırakmış çünkü zamanı yok. Metroda 20 dakika, öğle arası 15 dakika boş vakti var.
- **İster:** "Bir şey inşa ettiğimi hissetmek."
- **Nefret eder:** Enerji barı, zorunlu bekleme, ödeme duvarı.
- **Bizi bırakma sebebi:** İlk 3 günde "sadece butona basıyorum" hissi.
- **Bizi tutan şey:** Kovulma riski + 7 günlük sezon finali.
- **Ödeme davranışı:** Sezon Bileti alır (₺79/sezon algısı yerine aylık). Rastgele kutu almaz.

### 4.3 Persona 2 — "Bruno, 31, São Paulo" (Yüksek LTV)
> Satış temsilcisi. Günde 8+ seans, hepsi 2–3 dakika. Sıralama tablosunda ilk 100'e girmek istiyor.
- **İster:** Rekabet, statü, "en iyi kadro benim".
- **Ödeme davranışı:** Aylık $20–60. Transfer için premium harcar, kozmetik alır.
- **Risk:** İçerik tüketimi hızlı — "bitirdim" duygusu. Live-ops olmazsa 45. günde gider.

### 4.4 Persona 3 — "Selin, 23, İzmir" (Genişleme kitlesi)
> Üniversite öğrencisi. Futbolu takip ediyor ama istatistik ilgisini çekmiyor. Hikâye ve karakterleri seviyor.
- **İster:** Karakterler, drama, kararın sonucunu görmek.
- **Bizi tutan şey:** Karar kartlarındaki kişisel hikâye yayları (oyuncunun sakatlığı, akademiden çıkan çocuk, başkanla çekişme).
- **Tasarım sonucu:** Kart metinleri istatistik dilinde değil, insan dilinde yazılır. Her NPC'nin adı, yüzü ve hafızası olur.

### 4.5 Kitle Genişletme Notu
Türün kadın oyuncu oranı düşük; bunun ana sebebi jargon yoğunluğu ve "istatistik duvarı". Bizim üç düzeltmemiz:
1. Tüm sayısal bilgi bir **doğal dil özeti** ile birlikte sunulur.
2. NPC kadrosunda kadın karakterler yönetim/tıbbi/scout rollerinde eşit temsil.
3. 🔵 v1.4: Kadın futbol takımı şubesi açma (tesis olarak) — hem tematik genişleme hem içerik.

### 4.6 Kitleden Çıkardığımız Tasarım Direktifleri

| Gözlem | Direktif |
|---|---|
| Seans 3–6 dk | Her ekran ≤ 3 dokunuşta ulaşılabilir; "yapılacak" listesi ana ekranda |
| Kesintili oynama | Her aksiyon anında kaydedilir; uygulama öldürülse kayıp yok |
| Orta segment Android | 60 FPS hedefi ama 30 FPS'te bozulmayan animasyon; APK < 120 MB |
| Veri tasarrufu | Offline-first; internet olmadan tam oynanabilir (lig senkronu sonra) |
| Jargon duvarı | Her istatistik yanında tooltip + doğal dil özeti |

---

## 5. TASARIM SÜTUNLARI

Her özellik kararı bu beş sütuna karşı test edilir. **Bir özellik hiçbir sütunu güçlendirmiyorsa yapılmaz.**

### Sütun 1 — "Her karar bir bedel taşır"
Bedava iyi seçenek yoktur. Her kart, her transfer, her tesis bir şeyi verirken bir şeyi alır. Oyuncu "doğru" cevabı aramaz, **kendi önceliğini** seçer.
> **Test:** Bir seçenek her koşulda en iyiyse, o seçenek yanlış tasarlanmıştır.

### Sütun 2 — "3 dakika yeterli, 30 dakika ödüllendirici"
Kısa seans tam bir tatmin döngüsü tamamlar (aç → karar ver → sonuç gör → yatırım yap → kapat). Uzun seans daha fazla ilerleme verir ama **zorunlu değildir**.
> **Test:** 3 dakikada oyunu kapatan biri "boşa gitti" hissetmemeli.

### Sütun 3 — "Kulüp benim, kaybedebilirim"
Sahiplik duygusu (endowment) + kayıp riski (loss aversion) aynı anda. Kulübün adı, rengi, forması, stadyumu oyuncunun. Ama görevden alınabilir.
> **Test:** Oyuncu kulübünü ekran görüntüsüyle paylaşmak ister mi?

### Sütun 4 — "Sayı değil, hikâye"
Simülasyon derinliği arkada çalışır, önde **insan hikâyesi** anlatılır. `Moral: 34` değil, "Kaan üç maçtır kulübede, menajerine bakmıyor bile."
> **Test:** Bir ekranı okuduğunda futbol bilmeyen biri ne olduğunu anlıyor mu?

### Sütun 5 — "Adil ilerleme"
Ödeme hız verir, **güç tavanı vermez**. Ödemeyen oyuncu her lige çıkabilir, sadece daha yavaş. Rekabet ligleri harcama bandına göre eşleştirilir (§16.7).
> **Test:** Hiç ödemeyen bir oyuncu 90 gün sonra Elit Lig'e çıkabiliyor mu? Cevap evet olmalı.

---
---

# BÖLÜM II — OYUN TASARIMI

## 6. ZAMAN MODELİ VE CORE LOOP

### 6.1 Zaman Modeli Kararı (En kritik tasarım kararı)

Futbol yönetim oyunlarında en büyük tasarım sorusu şudur: **oyun içi zaman gerçek zamanla nasıl ilişkilenir?**

**Seçenekler ve değerlendirme:**

| Model | Örnek | Artı | Eksi | Karar |
|---|---|---|---|---|
| Tam serbest (oyuncu ilerletir) | FM Mobile | Özgürlük, offline | Retention kancası yok, seans planlanamaz | ❌ |
| Gerçek zamanlı 1:1 | — | Gerçekçi | Çok yavaş, oynanmaz | ❌ |
| Zamanlayıcı bazlı (maç her 4 saatte) | Top Eleven | Geri dönüş kancası | Oyuncu zamanı kontrol edemiyor, öfke | ❌ |
| **7 günlük sezon + günlük 3 maç penceresi** | — | Takvimle senkron, 3 doğal seans, sezon finali = haftalık zirve | Kaçırılan maç yönetimi gerekiyor | ✅ **SEÇİLDİ** |

### 6.2 Seçilen Zaman Modeli — Detay

```
1 SEZON = 7 GERÇEK GÜN (Pazartesi 00:00 → Pazar 23:59, oyuncunun yerel saati)

Her gün 3 "maç penceresi":
  ┌─────────────────────────────────────────────────────┐
  │ SABAH   09:00–13:00  → Maç 1  (+ 2 karar kartı)     │
  │ ÖĞLE    14:00–19:00  → Maç 2  (+ 2 karar kartı)     │
  │ AKŞAM   20:00–23:59  → Maç 3  (+ 2 karar kartı)     │
  └─────────────────────────────────────────────────────┘

7 gün × 3 maç = 21 maç = tam lig sezonu (11 takımlı lig, çift devre + 1 kupa)
```

**Kritik kurallar:**
1. **Maç pencereyi kaçırırsan kaybolmaz.** Pencere kapandığında maç otomatik simüle edilir (asistan menajer yönetir, %-10 performans cezası ile). Oyuncu geri geldiğinde "Yokluğunda ne oldu?" özet ekranı görür. → **Ceza var ama kaybetme yok** (öfke yönetimi).
2. **Biriktirme (banking) sınırı: 3 maç.** Yani bir gün tamamen kaçırırsan ertesi gün 3'ünü de oynayabilirsin; 2 gün kaçırırsan sadece 3'ü telafi edilir. → FOMO var ama makul.
3. **Sezon geçişi Pazartesi 00:00.** Sezon sonu ekranı (ödüller, terfi/düşme, yıllık ödüller) oyuncunun **Pazartesi ilk açılışında** oynatılır — asla kaçmaz.
4. **Zaman dilimi:** Oyuncunun cihaz saat diliminde. Sunucu UTC tutar, istemci dönüştürür. Saat dilimi değişikliği istismarı engeli: sezon başı TZ kilitlenir (§19.9).

**Neden 7 gün?**
- Haftalık ritim = insanın doğal ritmi. "Pazar akşamı final" alışkanlığı gerçek futbolla eşleşiyor.
- D7 retention ölçüm noktası tam bir sezon tamamlanmasına denk geliyor → **D7'de oyuncu bir bütün deneyim yaşamış olur** (en kritik retention hilesi).
- D21 = 3 sezon = terfi hikâyesi tamamlanmış olur.
- D30 = 4+ sezon = "kariyer" hissi oluşmuş olur.
- Live-ops için mükemmel: her hafta yeni tema, yeni sıralama, yeni ödül.

### 6.3 Core Loop Katmanları

**🔁 KATMAN 1 — Mikro Döngü (8–20 saniye): "Karar"**
```
Kart gelir → Oku → İki (bazen dört) seçenekten birini seç
   → Göstergeler anında hareket eder (haptik + ses)
      → Sonuç metni → Sonraki kart
```
Bu döngü *Reigns* mantığıdır ama ödülü kalıcıdır: göstergeler ve kaynaklar meta ilerlemeyi etkiler.

**🔁 KATMAN 2 — Seans Döngüsü (3–6 dakika): "Maç Günü"**
```
1. AÇILIŞ      → Push/ikon → Kulüp Ofisi ekranı
2. TAHSİLAT    → Birikmiş gelir topla (offline earnings), rozet animasyonu
3. MASA        → 2 karar kartı (bazen zincirin devamı → Zeigarnik)
4. HAZIRLIK    → Kadro/taktik hızlı düzenleme (opsiyonel, "Otomatik Diz" var)
5. MAÇ         → Hızlı Sim (8 sn) VEYA Canlı Anlar (90 sn, 4–6 taktik kararı)
6. SONUÇ       → Skor, öne çıkan oyuncu, gösterge değişimi, ödül
7. YATIRIM     → Tesis yükselt / transfer teklifi / antrenman ata
8. KAPANIŞ     → "Sonraki maç 14:20'de" + sıradaki hedef görünür → çıkış
```
> Adım 8 kritik: **Oyuncu asla "bitti, yapacak bir şey yok" ekranıyla çıkmaz.** Daima bir sonraki randevu ve yarım kalmış bir iş görünür.

**🔁 KATMAN 3 — Günlük Döngü (24 saat): "Gün"**
```
3 maç penceresi + Günlük Görevler (3 adet) + Günlük Ödül Zinciri
+ Transfer pazarı yenilenmesi (00:00, 12:00) + Antrenman raporu
```

**🔁 KATMAN 4 — Haftalık Döngü (7 gün): "Sezon"**
```
Pzt: Sezon açılışı, hedef belirleme (Başkan hedefi), transfer dönemi açılır
Sal–Cum: 21 maçın 15'i, hikâye yayları ilerler
Cmt: Kupa maçı, transfer dönemi kapanır
Paz: Son 3 maç + SEZON FİNALİ → terfi/düşme, ödüller, yıllık ödül töreni
```

**🔁 KATMAN 5 — Meta Döngü (4–12 hafta): "Kariyer"**
```
Lig 20 → Lig 1 tırmanışı → Elit Lig → Kıta Kupası
→ Prestij (Yeni Kulüp Kur) → kalıcı bonuslarla tekrar
```

### 6.4 Core Loop Diyagramı

```
                       ┌──────────────────────┐
          ┌───────────►│   TETİKLEYİCİ        │◄──────────┐
          │            │ push / maç saati /   │           │
          │            │ yarım kalan iş       │           │
          │            └──────────┬───────────┘           │
          │                       ▼                       │
          │            ┌──────────────────────┐           │
          │            │   AKSİYON            │           │
          │            │ karar ver / dizil /  │           │
          │            │ transfer / inşa et   │           │
          │            └──────────┬───────────┘           │
          │                       ▼                       │
          │            ┌──────────────────────┐           │
          │            │ DEĞİŞKEN ÖDÜL        │           │
          │            │ maç sonucu, scout    │           │
          │            │ raporu, kart sonucu  │           │
          │            └──────────┬───────────┘           │
          │                       ▼                       │
          │            ┌──────────────────────┐           │
          └────────────┤   YATIRIM            ├───────────┘
                       │ para/oyuncu/tesis/   │
                       │ ilişki biriktirme    │
                       └──────────────────────┘
                       (Hook Model — detay §17.2)
```

### 6.5 "Yarım Kalan İş" Envanteri (Zeigarnik Motorları)

Oyuncu her çıkışta **en az 2 tane** yarım kalmış iş bırakmalı. Sistem bunu garantiler:

| Yarım İş | Süre | Doğal olarak nasıl oluşur |
|---|---|---|
| Devam eden inşaat | 20 dk – 8 sa | Tesis yükseltme |
| Scout gözlem raporu | 45 dk – 6 sa | Oyuncu izleme |
| Transfer teklifine cevap | 1–4 sa | Karşı kulüp düşünüyor |
| Antrenman bloğu | 4 sa | Oyuncu geliştirme |
| Sakatlık iyileşmesi | 2 sa – 3 gün | Maç sonrası |
| Devam eden kart zinciri | Sonraki seans | 3 kartlık hikâye yayı |
| Sıradaki maç | ≤ 5 sa | Fikstür |
| Günlük görev (2/3 tamam) | Gün sonu | Görev sistemi |

**Kural (motorda kodlanır):** `SessionEndGuard` — oyuncu çıkarken açık iş sayısı < 2 ise, sistem bir tane üretir (ör. bir scout ipucu, bir sponsor teklifi). Bkz §19.7.

### 6.6 Seans Uzunluğu Hedefleri

| Seans tipi | Hedef süre | Tamamlanma oranı hedefi |
|---|---|---|
| Hızlı check-in (tahsilat + 1 kart) | 45–90 sn | %100 |
| Standart maç günü | 3–6 dk | %75 |
| Derin oturum (transfer + inşa + 3 maç) | 12–20 dk | %20 |
| Sezon finali oturumu | 8–12 dk | %85 (Pazar akşamı) |

---

## 7. ONBOARDING / FTUE

> **En kritik 10 dakika.** İlk seansta bırakan oyuncu %55–65 civarındadır ve bu tamamen FTUE tasarımına bağlıdır. Hedefimiz: **ilk oturumu tamamlama %72+**, D1 %45+.

### 7.1 FTUE Tasarım Prensipleri
1. **İlk 20 saniyede oyna, sonra öğren.** Menü/ayar/hesap yok — direkt sahnenin içine.
2. **Anlatma, yaptır.** Hiçbir yerde 2 satırdan uzun açıklama yok.
3. **Sahiplik erken kurulur.** Kulüp adı/renk seçimi ilk 90 saniyede (IKEA etkisi).
4. **İlk kayıp planlıdır.** İlk maç kaybedilir (senaryolu) — çünkü hikâye "dipten çıkış".
5. **Hesap oluşturma ertelenir.** Anonim başla; hesap bağlama Sezon 1 sonunda istenir.

### 7.2 Dakika Dakika FTUE Akışı

| Zaman | Ekran / Olay | Amaç | Öğretilen mekanik |
|---|---|---|---|
| 0:00 | **Splash + mnemonic** (1.5 sn), yükleme yok | Marka | — |
| 0:03 | **Cold open kartı:** "Yağmurlu bir salı. Telefonun çalıyor. Aradıkları kişi sensin." → [Aç] | Merak | Dokunma |
| 0:15 | **Kart 1:** Başkan Recep Vardar: "Kulüp batıyor. 8 haftan var. Kabul ediyor musun?" → [Kabul] / [Şartlarım var] | İlk anlamlı seçim | **Kart kaydırma/seçme** |
| 0:35 | **Göstergeler belirir** (animasyonla): Kasa ₣12K · Taraftar 40 · Soyunma Odası 35 · Yönetim 50 | Kural çerçevesi | **4 gösterge** |
| 0:50 | **Kulüp Kimliği:** ad (öneri listesi + serbest), forma rengi (6 preset), arma (12 şablon) | **Sahiplik/IKEA** | Kişiselleştirme |
| 1:30 | **Kulüp Ofisi ilk kez açılır**, kamera stadyumu tarar (harap tribün) | Vaat: "burayı büyüteceksin" | Ana ekran |
| 1:45 | **Kart 2:** "Kaptan Osman Yalçın: 3 aydır maaş almadık." → [Kasadan öde -₣5K] / [Söz ver] | İlk gerçek ödünleşim | **Trade-off** |
| 2:10 | **İlk Maç: Demirspor deplasmanı.** Canlı Anlar modu zorunlu (90 sn) | Maç mekaniği | **Canlı taktik kararı** |
| 3:40 | **Maç kaybedilir 0–2** (senaryolu). Soyunma odası kartı: "Ne diyeceksin?" → 3 seçenek | Duygusal dip + faillik | **Konuşma kartı** |
| 4:10 | **İlk Transfer:** Scout: "Serbest bir 10 numara var. 19 yaşında, potansiyeli bilinmiyor." → İzle / Direkt İmzala | Transfer mekaniği | **Scouting + potansiyel** |
| 5:00 | **İlk İnşa:** Antrenman Sahası Sv.1 (bedava, 20 sn inşa) | İnşa mekaniği | **Tesis + zamanlayıcı** |
| 5:30 | **İkinci Maç** — kazanılır (senaryolu, rakip zayıf). İlk kupa/konfeti anı | İlk zafer | Ritim |
| 6:15 | **Menajer Profili açılır:** Seviye 2 → ilk yetenek puanı → 3 daldan biri seçilir | RPG kancası | **Yetenek ağacı** |
| 7:00 | **Sezon Hedefi kartı:** Başkan "Bu sezon ilk 5'e gireceksin." | Uzun vadeli hedef | **Hedef sistemi** |
| 7:30 | **Günlük Görevler** ilk kez gösterilir (2'si zaten tamam → **Endowed Progress**) | Anında ilerleme hissi | Görev |
| 8:00 | **Bildirim izni istenir** — ama "İzin ver" değil: "Maç saatinde haber vereyim mi?" bağlamlı | Push opt-in maksimizasyonu | — |
| 8:30 | **Serbest oynanış.** Yönlendirme biter, sadece "sıradaki hedef" oku kalır | Özerklik | — |

**Zorunlu tutorial burada biter (8:30).** Kalan mekanikler **bağlamsal ipucu** olarak açılır (progressive disclosure — §7.4).

### 7.3 FTUE'de Bilinçli Olarak GÖSTERİLMEYENLER
Aşağıdakiler ilk oturumda **kilitli** ve görünmez — bilişsel yükü düşürmek için:
- Sözleşme/maaş pazarlığı detayı (Sezon 1 Gün 2)
- Akademi (Sezon 2)
- Sponsorluk sistemi (Sezon 1 Gün 3)
- Bilet fiyatlandırma (Sezon 1 Gün 4)
- PvP/Rekabet ligi (Sezon 2 sonu)
- Mağaza (Sezon 1 Gün 2 — **ilk 24 saat mağaza rozeti bile yanmaz**)
- Prestij (Sezon 8)

### 7.4 Aşamalı Açılım Takvimi (Progressive Disclosure)

| Ne zaman | Açılan sistem | Açılış tetiği | Neden burada |
|---|---|---|---|
| S1 G1 | Kart, maç, transfer, tesis | FTUE | Çekirdek |
| S1 G2 | Sözleşme yönetimi, Mağaza | 3. maç sonrası | Ekonomi kavranmışken |
| S1 G3 | Sponsorluk, Antrenman planı | Antrenman Sahası Sv.2 | Gelir çeşitlendirme |
| S1 G4 | Bilet fiyatı, Taraftar memnuniyeti | Stadyum Sv.2 | Fiyat-talep dengesi kavramı |
| S1 G7 | **Sezon Finali**, terfi/düşme, Sezon Bileti teklifi | Sezon sonu | İlk büyük duygusal zirve |
| S2 | Akademi, Genç oyuncu, Kiralık | Terfi | Yeni derinlik katmanı |
| S2 sonu | Rekabet Ligi (asenkron PvP), Arkadaş ekleme | Lig 18'e çıkış | Sosyal kanca (D14 kritik) |
| S3 | Yabancı scout ağı, Uluslararası transfer | Lig 16 | Dünya genişliyor |
| S4 | Kıta Kupası, Menajer itibarı, Diğer kulüplerden teklif | Lig 12 | Kariyer fantezisi |
| S6 | Yıldız oyuncu kişilik sistemi, Basın savaşları | Lig 8 | Drama derinliği |
| S8 | **Prestij / Yeni Kulüp**, Hanedan sistemi | Elit Lig | Uzun vadeli tekrar oynanabilirlik |

### 7.5 FTUE Ölçüm Noktaları (Funnel)

Her adım ayrı event olarak loglanır (§Ek E). Hedef dönüşüm oranları:

| Adım | Event | Hedef geçiş |
|---|---|---|
| Uygulama açıldı | `app_first_open` | %100 |
| Cold open geçildi | `ftue_step_complete{step:1}` | %96 |
| Kulüp adlandırıldı | `ftue_club_created` | %90 |
| İlk maç bitti | `ftue_first_match_end` | %84 |
| İlk transfer | `ftue_first_signing` | %80 |
| İlk tesis | `ftue_first_build` | %78 |
| FTUE tamam | `ftue_complete` | **%72** |
| Push izni verildi | `push_permission_granted` | %55 (iOS) / %78 (Android) |
| D1 dönüş | `day1_return` | **%45** |

> **Kırmızı bayrak:** Herhangi bir adımda %8'den fazla düşüş varsa o adım yeniden tasarlanır. Ölçüm penceresi: her sürümde ilk 5.000 kullanıcı.

### 7.6 FTUE A/B Test Kuyruğu (öncelik sırası)
1. Cold open uzunluğu: 3 kart vs 1 kart
2. Kulüp kişiselleştirme zamanı: 0:50 vs FTUE sonu
3. İlk maç sonucu: planlı yenilgi vs planlı galibiyet
4. Push izni zamanı: 8:00 vs Sezon 1 sonu
5. Tutorial elle mi otomatik mi (forced tap vs auto-play)

---
## 8. KULÜP, TESİSLER VE İNŞA AĞACI

### 8.1 Kulüp Nesnesi — Ne Sahip Olunur?

```
KULÜP
├── Kimlik      : ad, kısa ad (3 harf), arma, forma (iç/dış), stadyum adı, kuruluş yılı
├── Konum       : şehir (prosedürel), bölge, ülke → taraftar tabanı ve ekonomi çarpanı
├── Finans      : Kasa (₣), haftalık gelir/gider, borç, kredi limiti
├── Prestij     : 0–1000 (transfer çekiciliği, sponsor kalitesi, scout erişimi)
├── Taraftar    : sayı (fan base), memnuniyet (0–100), sadakat, ultra grubu
├── Tesisler    : 12 tesis × 5 seviye
├── Kadro       : 18–30 oyuncu, 11 ilk 11, 7 yedek
├── Personel    : asistan, scout ×N, fizyoterapist, altyapı hocası, analist
├── Sözleşmeler : sponsorlar (3 slot), yayın geliri (lige bağlı), tedarikçi
└── Tarih       : sezon sonuçları, kupalar, efsane oyuncular, rekorlar
```

### 8.2 Tesis Ağacı (12 Tesis)

Her tesis **5 seviye**. Seviye 1 kilit açma, 2–5 yükseltme.

| # | Tesis | Ana Etkisi | Kilit Şartı | İkincil Etki |
|---|---|---|---|---|
| 1 | **Stadyum** | Kapasite → bilet geliri | Başlangıç | Taraftar memnuniyeti, ev sahibi avantajı |
| 2 | **Antrenman Sahası** | Oyuncu gelişim hızı | Başlangıç | Sakatlık riski ↓ |
| 3 | **Kondisyon Merkezi** | Fizik/Dayanıklılık gelişimi | S1 G3 | Maç sonu yorgunluk ↓ |
| 4 | **Tıbbi Merkez** | İyileşme süresi ↓ | S1 G5 | Sakatlık şiddeti ↓ |
| 5 | **Altyapı Akademisi** | Genç oyuncu üretimi | Sezon 2 | Yerel taraftar ↑ |
| 6 | **Scout Ağı** | Scout sayısı + rapor doğruluğu | S1 G4 | Uluslararası erişim |
| 7 | **Analiz Merkezi** | Rakip zayıflık raporu | Sezon 3 | Taktik bonusu |
| 8 | **Kulüp Mağazası** | Ürün geliri | S1 G4 | Taraftar sadakati ↑ |
| 9 | **VIP Localar** | Yüksek marjlı gelir | Stadyum Sv.3 | Sponsor kalitesi ↑ |
| 10 | **Medya Merkezi** | Basın kartlarında avantaj | Sezon 3 | Prestij ↑ |
| 11 | **Yurt / Kamp** | Genç oyuncu tutma | Akademi Sv.2 | Yabancı oyuncu uyumu ↑ |
| 12 | **Taraftar Evi** | Ultra grubu memnuniyeti | Sezon 4 | Deplasman desteği |

### 8.3 Tesis Seviye Tablosu — Örnek: Stadyum

| Sv | Kapasite | İnşa Maliyeti | Süre | Ön Koşul | Haftalık Bakım | Bilet Geliri (dolu, ort. fiyat ₣12) |
|---|---|---|---|---|---|---|
| 1 | 2.000 | Başlangıç | — | — | ₣400 | ₣24K/hafta (3 iç saha maçı) |
| 2 | 6.000 | ₣45.000 | 4 sa | Kulüp Sv.3 | ₣1.100 | ₣72K |
| 3 | 15.000 | ₣180.000 | 12 sa | Kulüp Sv.8, Lig ≤15 | ₣3.200 | ₣180K |
| 4 | 35.000 | ₣720.000 | 24 sa | Kulüp Sv.15, Lig ≤8 | ₣9.000 | ₣420K |
| 5 | 68.000 | ₣2.900.000 | 48 sa | Kulüp Sv.25, Lig ≤3 | ₣24.000 | ₣816K |

**Maliyet formülü (tüm tesisler için tek formül — dengelemeyi kolaylaştırır):**
```
Maliyet(t, s) = TabanMaliyet(t) × 3.9^(s-1) × BölgeÇarpanı
Süre(t, s)    = TabanSüre(t) × 2.7^(s-1)          [maks 48 sa ile sınırlı]
Bakım(t, s)   = Maliyet(t,s) × 0.0085             [haftalık]
```

**Taban maliyetler (₣):**

| Tesis | Taban Maliyet | Taban Süre |
|---|---|---|
| Stadyum | 45.000 | 4 sa |
| Antrenman Sahası | 12.000 | 40 dk |
| Kondisyon Merkezi | 18.000 | 1 sa |
| Tıbbi Merkez | 22.000 | 1.5 sa |
| Altyapı Akademisi | 60.000 | 6 sa |
| Scout Ağı | 15.000 | 45 dk |
| Analiz Merkezi | 40.000 | 3 sa |
| Kulüp Mağazası | 25.000 | 2 sa |
| VIP Localar | 90.000 | 8 sa |
| Medya Merkezi | 35.000 | 3 sa |
| Yurt/Kamp | 30.000 | 2.5 sa |
| Taraftar Evi | 28.000 | 2 sa |

### 8.4 Tesis Etkileri — Sayısal

| Tesis | Sv.1 | Sv.2 | Sv.3 | Sv.4 | Sv.5 |
|---|---|---|---|---|---|
| Antrenman Sahası → gelişim hızı | ×1.00 | ×1.20 | ×1.45 | ×1.75 | ×2.10 |
| Tıbbi → iyileşme süresi | ×1.00 | ×0.85 | ×0.72 | ×0.60 | ×0.48 |
| Akademi → genç üretimi (sezon başına) | 1 | 2 | 3 | 4 | 6 |
| Akademi → genç potansiyel tavanı | 55 | 65 | 74 | 82 | 90 |
| Scout Ağı → eşzamanlı scout | 1 | 2 | 3 | 4 | 6 |
| Scout Ağı → rapor doğruluğu | ±14 | ±11 | ±8 | ±5 | ±2 |
| Mağaza → haftalık gelir | Taraftar×0.4₣ | ×0.75 | ×1.3 | ×2.1 | ×3.4 |
| Analiz → taktik uyum bonusu | +1% | +3% | +5% | +8% | +12% |
| VIP → maç başı ek gelir | ₣2K | ₣7K | ₣18K | ₣45K | ₣95K |

### 8.5 İnşa Kuyruğu ve Hızlandırma
- **Eşzamanlı inşa: 1 slot** (başlangıç). 2. slot = Altın Rozet ile kalıcı satın alma (₣ değil, premium) veya Kulüp Sv.20'de bedava.
- **Hızlandırma:** Kalan süre ≤ 5 dk → **bedava bitir** (goal gradient hilesi: son adım hep bedava, ilerleme hissi güçlenir).
- **Rewarded ad ile hızlandırma:** Günde 3 kez, her biri −30 dk. ("Sponsor devreye girdi.")
- **Premium hızlandırma fiyatı:** `Rozet = ceil(kalan_dakika / 6)` — sektör standardı taban.

### 8.6 Kulüp Seviyesi
Kulüp Seviyesi (1–50) tüm tesis seviyelerinin toplamından türetilir + sezon başarıları.
```
KulüpXP = Σ(tesis_seviyeleri × 100) + (kazanılan_maç × 25) + (kupa × 2000) + (terfi × 5000)
KulüpSv = floor( sqrt(KulüpXP / 180) ) + 1     [tavan 50]
```
Kulüp Seviyesi neyi açar: tesis üst seviyeleri, kadro büyüklüğü limiti, sözleşme slotları, transfer bütçesi limiti, sponsor kalitesi.

### 8.7 Stadyum Görsel Evrimi (Sanat Direktifi)
Oyuncunun gördüğü **en büyük ilerleme kanıtı** stadyumdur. Her seviyede görsel siluet belirgin biçimde değişmeli:

| Sv | Görsel | Detay |
|---|---|---|
| 1 | Tek tribün, çim düzensiz, tel örgü | Ahşap sıralar, sis, birkaç kişi |
| 2 | İki tribün, sayı tabelası | Plastik koltuklar, reklam panosu |
| 3 | Dört tribün kapalı, ışıklandırma | Gece maçı mümkün, kalabalık |
| 4 | Çatı, dev ekran, VIP kat | Renkli koreografi |
| 5 | Modern arena, tam kapalı, ikonik cephe | Havai fişek, dolu tribün, marş |

**Uygulama:** Katmanlı 2.5D — tek bir arka plan illüstrasyonu + değişen katmanlar (tribün, çatı, ışık, kalabalık, hava). Tam yeniden çizim değil, **katman değişimi** → sanat maliyeti 5× yerine ~1.8×.

---

## 9. OYUNCU VE KADRO SİSTEMİ

### 9.1 Oyuncu Veri Modeli

```dart
class Player {
  final String id;               // uuid
  final String firstName, lastName;
  final int birthSeason;         // yaş hesabı için
  final String nationalityCode;  // prosedürel ülke
  final Position position;       // GK, CB, LB, RB, DM, CM, AM, LW, RW, ST
  final List<Position> altPositions;

  // Görünen özellikler (0-99)
  final int pace, technique, shooting, passing, defending, physical;
  final int mentality;           // baskı altında performans

  // Gizli özellikler
  final int potential;           // 0-99, scout ile tahmin edilir
  final int consistency;         // 0-99, performans varyansı
  final int injuryProneness;     // 0-99
  final int growthCurveType;     // erken/normal/geç patlayan
  final PersonalityType personality;

  // Dinamik durum
  int morale;                    // 0-100
  int fitness;                   // 0-100
  int form;                      // -3..+3 (son 5 maç)
  int matchSharpness;            // 0-100 (maç eksiği)
  Injury? injury;
  int chemistryWith;             // takım uyumu katkısı

  // Sözleşme
  int weeklyWage;                // ₣
  int contractSeasonsLeft;
  int releaseClause;             // 0 = yok
  int transferValue;             // hesaplanır
  bool isYouthProduct;           // akademiden mi
  bool isTransferListed;
}
```

### 9.2 Genel Güç (Overall / OVR) Formülü

**Pozisyona göre ağırlıklı ortalama.** Ağırlıklar toplamı 1.00:

| Poz | Pace | Tech | Shoot | Pass | Def | Phys | Ment |
|---|---|---|---|---|---|---|---|
| GK | .05 | .15 | .00 | .10 | .40 | .20 | .10 |
| CB | .10 | .08 | .02 | .10 | .40 | .22 | .08 |
| LB/RB | .22 | .14 | .04 | .16 | .26 | .12 | .06 |
| DM | .08 | .16 | .05 | .22 | .30 | .13 | .06 |
| CM | .10 | .20 | .10 | .28 | .16 | .10 | .06 |
| AM | .14 | .26 | .18 | .26 | .04 | .06 | .06 |
| LW/RW | .26 | .26 | .16 | .16 | .04 | .06 | .06 |
| ST | .18 | .20 | .34 | .10 | .02 | .10 | .06 |

```
OVR = round( Σ(özellik_i × ağırlık_i) )
GörünenOVR = OVR                        // kendi oyuncun
TahminiOVR = OVR ± scoutHatası          // izlenmemiş oyuncu
```

**Yıldız derecesi (görsel nadirlik):**

| OVR aralığı | Yıldız | Etiket |
|---|---|---|
| < 45 | 1★ | Amatör |
| 45–58 | 2★ | Profesyonel |
| 59–70 | 3★ | Kaliteli |
| 71–82 | 4★ | Yıldız |
| 83–92 | 5★ | Efsane |
| 93+ | 5★+ | İkon |

> ⚠ Yıldız derecesi **lig bağlamına göre relatif de gösterilir**: "Bu ligde 4★" rozeti. Böylece alt liglerde 3★ oyuncu heyecan verici kalır (referans noktası kaydırma — §17.5).

### 9.3 Yaş ve Gelişim Eğrisi

```
Yaş 15–17 : Potansiyele doğru hızlı gelişim (×1.6 hız), tavan düşük
Yaş 18–22 : Ana gelişim penceresi (×1.3)
Yaş 23–26 : Zirve platosu (×0.6, ince ayar)
Yaş 27–29 : Yavaş düşüş başlangıcı (Pace/Physical −0.8/sezon)
Yaş 30–33 : Belirgin düşüş (Pace −2.2/sezon), Mentality +1/sezon
Yaş 34+   : Hızlı düşüş, emeklilik riski (%15/sezon, 37'de %60)
```

**Gelişim formülü (sezon sonu, oyuncu başına):**
```
temelArtis   = (potential - OVR) × 0.18
yasCarpani   = ageMultiplier(age)                 // yukarıdaki tablo
tesisCarpani = antrenmanSahasiCarpani             // 1.00–2.10
oynamaCarpani= clamp(dakika_oynanan / 1200, 0.35, 1.25)
moralCarpani = 0.75 + (morale / 200)              // 0.75–1.25
rastgele     = uniform(0.80, 1.25)

sezonArtisi = temelArtis × yasCarpani × tesisCarpani × oynamaCarpani × moralCarpani × rastgele
```
> Kritik: `oynamaCarpani` — genç oyuncu oynatmazsan gelişmiyor. Bu, kadro rotasyonunu **anlamlı bir strateji kararı** haline getiriyor (Sütun 1).

### 9.4 Kişilik Tipleri (RPG Katmanı)

Her oyuncunun bir kişiliği var; karar kartlarını ve gelişimi etkiler.

| Kişilik | Etki | Kart davranışı |
|---|---|---|
| **Profesyonel** | Gelişim +10%, moral stabil | Nadiren sorun çıkarır |
| **Lider** | Takım morali +5, genç gelişimi +8% | Soyunma odası kartlarında müttefik |
| **Ego** | OVR +3 ama moral kırılgan | Zam/kadro dışı kalma kartları sık |
| **Sadık** | Sözleşme yenileme ucuz, transfer istemez | Kulüp geçmişi kartları |
| **Kariyerist** | Büyük kulüp teklifinde gitmek ister | Transfer talebi kartları |
| **Cam** | Yetenek yüksek, sakatlık riski ×1.8 | Sakatlık kartları |
| **Geç Olgunlaşan** | 25 yaşına kadar yavaş, sonra patlar | "Sabret" kartları |
| **Problemli** | Ucuz, yüksek OVR, disiplin olayları | Basın/disiplin kartları |

Kişilik oyuncu kartında **gizlidir**, scout ile veya 5 maç birlikte çalışınca açılır.

### 9.5 Moral, Form, Fitness

| Durum | Aralık | Ne değiştirir | Nasıl iyileşir |
|---|---|---|---|
| **Moral** | 0–100 | Performans ±8%, gelişim, transfer isteği | Galibiyet +4, oynatma +2, konuşma kartları, zam |
| **Form** | −3..+3 | Performans ±6% | Son 5 maç puanı ortalaması |
| **Fitness** | 0–100 | Performans, sakatlık riski | Maç −18, dinlenme +12/gün, Kondisyon Merkezi |
| **Maç Keskinliği** | 0–100 | Yeni transfer/sakatlıktan dönenin ilk maçları | Maç oynayarak +15/maç |

**Moral tetikleyicileri:**
```
+6  Galibiyet (kadroda)          −5  Mağlubiyet
+3  Gol/asist                    −4  Üst üste 3 maç kadro dışı
+8  Sözleşme yenileme (iyi)      −10 Zam talebi reddedildi
+5  Takım arkadaşı transferi     −7  Kaptan satıldı
+4  Kaptanlık verildi            −12 Transfer talebi reddedildi
+10 Kupa                         −6  Küme düşme
```

### 9.6 Sakatlık Sistemi

```
SakatlıkOlasılığı(maç) = temel(0.030)
  × (1 + injuryProneness/100)
  × (2.0 - fitness/100)
  × tıbbiMerkezÇarpanı(0.48–1.00)
  × taktikYoğunluğuÇarpanı(0.85–1.35)
  × yaşÇarpanı(≥31 ise 1.25)
```

| Şiddet | Olasılık | Süre | Etki |
|---|---|---|---|
| Hafif (darbe) | %55 | 1–3 gün | Fitness −20 |
| Orta (kas) | %30 | 4–10 gün | Kadro dışı |
| Ciddi (bağ) | %12 | 2–5 hafta | Kadro dışı + OVR −2 dönüşte |
| Ağır (kırık/çapraz) | %3 | 6–14 hafta | OVR −4, Pace kalıcı −2 riski |

Sakatlık daima bir **karar kartı** üretir: "Riskli ama oynatabilirim / Dinlendireyim / Sağlık kuruluna sor". Bu, sakatlığı sıkıcı bir cezadan **anlamlı bir seçime** çeviriyor (Sütun 1).

### 9.7 Kadro Kuralları
- Kadro büyüklüğü: min 16, maks `18 + floor(KulüpSv/5)` (maks 30)
- Yabancı sınırı: yok (basitlik) 🟢, 🔵 v1.3'te lig kuralı olarak eklenebilir
- Yaş 15–17 oyuncular sadece Akademi Sv.2+ ile kadroya alınabilir
- İlk 11 + 7 yedek; maç başına 5 değişiklik hakkı
- **Otomatik Diz** butonu: en yüksek OVR + fitness + pozisyon uyumu ile diziyor (kolaylık — kısa seans desteği)

### 9.8 Takım Uyumu (Chemistry)
```
TakımUyumu = 100
  − (yanlış_pozisyon_oyuncu_sayısı × 6)
  − (30 günden yeni transfer sayısı × 3)   // uyum süresi
  + (aynı_uyruk_kümesi_bonusu, maks +8)
  + (5+ sezon birlikte oynayan çift başına +2, maks +10)
  + (kaptan varsa +4)
  + Analiz Merkezi bonusu
```
Takım gücüne çarpan: `0.88 + (TakımUyumu / 500)` → 0.88–1.08 aralığı.

### 9.9 Oyuncu Değeri (Transfer Value)
```
tabanDeger = 1.35^((OVR - 40) / 4.2) × 1000                       // ₣
yasCarpani = { ≤19: 1.55, 20-23: 1.40, 24-27: 1.00,
               28-30: 0.68, 31-33: 0.38, 34+: 0.15 }
potansiyelCarpani = 1 + max(0, (potential - OVR)) × 0.028
sozlesmeCarpani   = { 3+ sezon: 1.15, 2: 1.00, 1: 0.72, son 6 ay: 0.40 }
formCarpani       = 1 + (form × 0.035)
ligCarpani        = 0.55 + (21 - ligKademesi) × 0.048

Deger = tabanDeger × yasCarpani × potansiyelCarpani × sozlesmeCarpani
        × formCarpani × ligCarpani
```

**Örnek sağlama:** OVR 72, yaş 21, potansiyel 86, 3 sezon sözleşme, form +1, Lig 10.
```
tabanDeger = 1.35^((72-40)/4.2) × 1000 = 1.35^7.62 × 1000 ≈ 11.7 × 1000 = 11.700
× 1.40 (yaş) × 1.392 (potansiyel) × 1.15 (sözleşme) × 1.035 (form) × 1.083 (lig)
≈ 29.400 ₣
```

### 9.10 Sözleşme ve Maaş
```
BeklenenMaaş(haftalık) = Değer × 0.0038 × egoÇarpanı × ligÇarpanı
egoÇarpanı: Ego 1.35 · Kariyerist 1.20 · Profesyonel 1.00 · Sadık 0.85
```
- Sözleşme uzunluğu 1–5 sezon. Uzun sözleşme = daha yüksek imza bonusu ama esneklik kaybı.
- Sözleşme bitimine 1 sezon kala **otomatik karar kartı** üretilir ("Yenileyelim mi?").
- Sözleşme biterse oyuncu **bedava gider** → gerçek kayıp → loss aversion motoru.
- **Serbest kalma bedeli (release clause):** koyarsan maaş +%12 ama rakip kulüp o rakamı ödeyip alabilir → ödünleşim.

---

## 10. TRANSFER PAZARI VE SCOUTING

### 10.1 Transfer Pazarı Felsefesi
Transfer pazarı bu oyunun **en çok tekrar edilen keyif kaynağı** (variable reward'un ana kaynağı). Üç prensip:
1. **Pazar canlıdır** — AI kulüpler de alır satar; kaçırdığın oyuncu gerçekten gider.
2. **Bilgi eksiktir** — potansiyeli asla tam bilmezsin, scout azaltır ama sıfırlamaz.
3. **Pazarlık bir mini oyundur** — sadece "Satın Al" butonu değil.

### 10.2 Transfer Kanalları

| Kanal | Ne zaman | Maliyet | Risk | Ödül |
|---|---|---|---|---|
| **Serbest oyuncular** | Her zaman | Sadece maaş + imza bonusu | Genelde yaşlı/formsuz | Bedava fırsat |
| **Transfer listesi** | Transfer dönemi | Bonservis + maaş | Standart | Bilinen kalite |
| **Scout keşfi** | Scout raporu sonrası | Düşük bonservis | Potansiyel belirsiz | En yüksek ROI |
| **Akademi** | Sezon başı | Bedava | Düşük tavan | Sahiplik/duygusal bağ |
| **Kiralık (alma)** | Transfer dönemi | Maaş payı | Gelişim senin değil | Kısa vadeli güç |
| **Kiralık (verme)** | Transfer dönemi | — | — | Genç gelişimi + maaş tasarrufu |
| **Takas** | Transfer dönemi | Oyuncu + fark | Değer kaybı riski | Kadro dengeleme |
| **Serbest kalma bedeli** | Her zaman | Yüksek nakit | Pahalı | Anında alım |

### 10.3 Transfer Dönemleri
- **Sezon içi:** Pazartesi 00:00 – Cumartesi 12:00 açık, Cumartesi 12:00 – Pazar 23:59 **kapalı** (fikstür kilidi).
- Kapalı dönemde sadece serbest oyuncu alınır.
- 🔵 Live-ops: "Deadline Day" etkinliği — Cumartesi 10:00–12:00 arası %30 indirimli bonservis, yüksek trafik penceresi.

### 10.4 Scouting Sistemi

**Scout ataması:**
```
Scout gönder → Bölge seç (Yerel / Ulusal / Kıtasal / Global)
             → Odak seç (Pozisyon / Yaş bandı / Bütçe bandı)
             → Süre: 45 dk / 3 sa / 6 sa (uzun = daha iyi sonuç)
```

**Scout raporu doğruluğu:**

| Scout Ağı Sv | Potansiyel hata payı | Kişilik görünürlüğü | Bölge erişimi |
|---|---|---|---|
| 1 | ±14 | Gizli | Yerel |
| 2 | ±11 | %30 şans | Ulusal |
| 3 | ±8 | %55 şans | Kıtasal |
| 4 | ±5 | %80 şans | Global |
| 5 | ±2 | Her zaman | Global + gizli yetenek |

**Rapor sunumu (dil önemli — Sütun 4):**
> ❌ "Potansiyel: 78 ±8"
> ✅ "Bu çocuk bu ligde kalmaz. Scout'un notu: *'İyi bir takımda ilk 11'e oynar. Belki daha fazlası.'*" + görsel bant (68 ─── 86)

**Gizli yetenek (hidden gem) mekaniği:**
Her scout raporunun %4'ünde (Sv.5'te %9) rapor **düşük gösterir** ama gerçek potansiyel çok yüksektir. Bu, "keşif" hikâyelerinin kaynağı — oyuncular bunu arkadaşlarına anlatır (organik pazarlama).

### 10.5 Pazarlık Mini-Oyunu

Bir oyuncuya teklif verince pazarlık ekranı açılır. **3 tur, her tur bir karar.**

```
┌──────────────────────────────────────────┐
│  ARSLAN DEMİR · 22 · AM · 4★             │
│  İstenen: ₣180.000                       │
│                                          │
│  Teklifin:  [────────●─────]  ₣145.000   │
│                                          │
│  Karşı tarafın sabrı: ███████░░░  70%    │
│                                          │
│  [ TEKLİF VER ]  [ EK MADDE ] [ ÇEKİL ]  │
└──────────────────────────────────────────┘
```

**Mekanik:**
- Kabul olasılığı: `P = clamp( (teklif / istenen)^2.4 × prestijÇarpanı × ilişkiÇarpanı , 0.02, 0.97 )`
- Düşük teklif → sabır düşer. Sabır 0 → görüşme kapanır (24 sa cooldown, oyuncu başka kulübe gidebilir).
- **Ek maddeler** (ödünleşim yaratır):
  - *Taksitli ödeme*: nakit ihtiyacı ↓ ama toplam +%18
  - *Satıştan pay* (%10–25): bonservis −%15 ama gelecekteki satıştan pay verirsin
  - *Performans bonusu*: bonservis −%20, 20 maç oynarsa +%30 öde
  - *Takasa oyuncu ekle*: değerinin %85'i sayılır
  - *Karşılıklı dostluk maçı*: −%5, ilişki +
- **İlişki sistemi:** Her AI kulüple bir ilişki puanı (0–100). Adil davranırsan yükselir → indirim. Sürekli lowball → düşer → seninle çalışmazlar.

**Neden mini-oyun:** Tek dokunuşla alım, transferin duygusal ağırlığını yok eder. 3 turluk pazarlık, oyuncuyu **çabasının sahibi** yapar (IKEA etkisi) ve kazanılan oyuncu daha değerli hissettirir.

### 10.6 Oyuncu İkna Etme (Kişisel Şartlar)
Bonservis anlaşması sonrası oyuncunun kendisiyle görüşme:
```
Talepleri:  Maaş ₣4.200/hafta · İlk 11 garantisi · 3 sezon · İmza bonusu ₣15.000
Sunabileceğin: [maaş slider] [rol seçimi] [süre] [bonus]
```
- **Rol vaadi** (Yıldız / İlk 11 / Rotasyon / Yedek) — verdiğin sözü tutmazsan moral çöker ve karar kartı çıkar. → Sözün bir bedeli var.
- Prestij yüksekse talepler düşer. Alt ligdeyken yıldız almak **çok zor** olmalı (ilerleme hissi).

### 10.7 AI Kulüp Davranışı
AI kulüpler pasif olmamalı:
- Her AI kulübün bütçesi, ihtiyaç haritası ve transfer iştahı var
- Senin izlediğin oyuncuya **rakip teklif** gelebilir → "3 kulüp daha ilgileniyor" bildirimi (kıtlık/aciliyet, doğal olarak)
- AI kulüpler **senin oyuncularına teklif verir** → satmak/reddetmek bir karar kartı
- Sezon sonu AI kulüpler arası transferler simüle edilir → dünya canlı hissettirir

### 10.8 Transfer Ekonomisi Koruması (Enflasyon Önleme)
Uzun süre oynayan oyuncularda ekonomi patlar. Korumalar:
1. **Maaş tavanı:** Haftalık maaş toplamı ≤ haftalık gelirin %65'i. Aşarsan **Yönetim Güveni** hızla düşer.
2. **Kadro limiti** (§9.7) — sınırsız oyuncu biriktirilemez.
3. **Değer amortismanı:** Sattığın oyuncunun değeri, satın alma fiyatının %90'ıyla sınırlı (ilk 30 gün) → flip-farming engeli.
4. **Lig kalite tavanı:** Alt liglerde 80+ OVR oyuncu "buraya gelmem" der. Para her şeyi çözmez.

---
## 11. MAÇ SİMÜLASYONU VE TAKTİK

### 11.1 Tasarım Hedefi
Maç, oyunun **doğrulama anıdır** — verdiğin kararların sonucunu burada görürsün. Ama maç 45 dakika sürmemeli. İki mod:

| Mod | Süre | Ne zaman | Etkileşim |
|---|---|---|---|
| **Hızlı Sim** | 6–8 sn | Acele varken, kolay maçta | Yok, sadece sonuç |
| **Canlı Anlar** | 75–110 sn | Önemli maçta, oyuncu isterse | 4–7 taktik kararı |

> **Kritik:** Canlı Anlar modu **istatistiksel avantaj sağlar** (+%4–7 beklenen sonuç) ama zorunlu değildir. Hızlı Sim'i seçen ceza almaz, sadece bonus alamaz. Bu, "zamanı olan kazanır" değil "zamanı olan biraz daha iyi yapar" dengesi.

### 11.2 Simülasyon Mimarisi — Olay Tabanlı (Event-Driven)

Klasik "iki takım gücünü karşılaştır, rastgele skor üret" yaklaşımı **duygusuz**. Bunun yerine dakika dakika olay üretimi:

```
1. Maç 90 dakikaya bölünür, her dakika bir "olay çekilişi" yapılır
2. Top hakimiyeti (possession) her dakika belirlenir
3. Hakimiyeti olan takım için "atak üretme" olasılığı hesaplanır
4. Atak üretilirse → şut kalitesi (xG) hesaplanır → gol/kaçırma/kurtarış
5. Yan olaylar: faul, kart, sakatlık, değişiklik ihtiyacı
6. Anlatım metni üretilir (§11.6)
```

**Adım adım formüller:**

```
── 1. TAKIM GÜCÜ ──────────────────────────────────
AtakGücü = Σ(oyuncu.pozisyonKatkısı × ofansifAğırlık) × formaÇarpanı
DefansGücü = Σ(oyuncu.pozisyonKatkısı × defansifAğırlık) × formaÇarpanı

formaÇarpanı = takımUyumu × moralOrt × fitnessOrt × taktikUyumu
             × evSahibiBonusu × menajerBonusu

evSahibiBonusu = 1.00 + 0.04 + (stadyumSv × 0.012) + (taraftarMemnuniyeti/1000)
                 // Sv5 + %100 memnuniyet → 1.20

── 2. TOP HAKİMİYETİ ──────────────────────────────
possA = (ortaSahaGücüA^1.35) / (ortaSahaGücüA^1.35 + ortaSahaGücüB^1.35)
possA = clamp(possA, 0.22, 0.78)   // aşırı uçları kes

── 3. DAKİKA BAŞINA ATAK OLASILIĞI ────────────────
atakOlasA = possA × 0.155 × tempoÇarpanı(taktik) × yorgunlukÇarpanı(dakika)
yorgunlukÇarpanı(m) = 1.0 - max(0, (m - 60)) × 0.004 × (1 - fitnessOrt/150)

── 4. ŞUT KALİTESİ (xG) ───────────────────────────
xG_ham = 0.085 × (AtakGücüA / DefansGücüB)^0.9
xG = clamp(xG_ham × şutTipiÇarpanı × mentalityÇarpanı, 0.02, 0.62)

şutTipiÇarpanı: kontra 1.35 · organize 1.00 · uzaktan 0.45 · duran top 0.70
mentalityÇarpanı = 0.92 + (şutçu.mentality / 600)   // baskı altında

── 5. GOL KARARI ──────────────────────────────────
kalecıEtkisi = 1 - (kaleci.OVR - 55) × 0.0055
golOlasılık = xG × kalecıEtkisi
if (rng() < golOlasılık) → GOL
else → kurtarış / dışarı / direk (alt dağılım)
```

### 11.3 Taktik Sistemi

**Formasyon (12 adet 🟢):** 4-4-2, 4-3-3, 4-2-3-1, 3-5-2, 4-5-1, 5-3-2, 3-4-3, 4-1-4-1, 4-4-1-1, 5-4-1, 4-2-2-2, 3-4-1-2

**Taktik eksenleri (5 slider, her biri 3 kademe):**

| Eksen | Seçenekler | Etki |
|---|---|---|
| **Tempo** | Yavaş / Dengeli / Hızlı | Atak sıklığı ↑, yorgunluk ↑ |
| **Baskı** | Alçak blok / Orta / Yüksek pres | Top kazanma ↑, kontra riski ↑, fitness ↓↓ |
| **Genişlik** | Dar / Normal / Geniş | Kanat etkinliği, orta saha yoğunluğu |
| **Risk** | Güvenli / Dengeli / Riskli | xG ↑ ama top kaybı ↑ |
| **Sertlik** | Temiz / Normal | Faul, kart, sakatlık riski |

**Taktik uyum:** Her oyuncunun özellikleri seçilen taktiğe uygunsa bonus, değilse ceza.
```
taktikUyumu = 0.90 + Σ(oyuncuUyumSkoru) / (11 × 55)      // 0.90–1.10
Örn: Yüksek pres + düşük Physical kadro → uyum 0.92 (ceza)
```

**Karşı taktik (Analiz Merkezi ile):** Rakibin zayıflığı gösterilir ("Sağ bekleri yavaş"), uygun taktik seçilirse +%6 avantaj. → Analiz Merkezi'ne yatırım anlamlı olur.

### 11.4 Canlı Anlar Modu (90 saniye)

Maç boyunca **4–7 kritik an** seçilir ve oyuncuya sunulur. Her an 8–12 saniyelik bir karar.

```
┌────────────────────────────────────────────┐
│  34'  ●  1 - 1                             │
│                                            │
│  Rakip sol kanattan bastırıyor.            │
│  Sağ bekin Emre nefes nefese (fitness 48). │
│                                            │
│  ⏱ 8                                       │
│                                            │
│  [ Emre'yi çık ]   [ Devam et ]            │
│  [ Bloku geri çek ]                        │
└────────────────────────────────────────────┘
```

**An tipleri:**

| An | Tetik | Seçenekler | Etki |
|---|---|---|---|
| Yorgunluk | Bir oyuncu fitness < 55 | Değiştir / Devam / Rol değiştir | Sakatlık riski, performans |
| Kart riski | Sarı kart görmüş agresif oyuncu | Değiştir / Sakin ol talimatı / Devam | Kırmızı kart riski |
| Geri düşme | 0-1 geride, 60. dk | Hücuma yüklen / Sabırlı ol / Formasyon değiştir | Beraberlik vs kontra riski |
| Öndeyken | 1-0 önde, 75. dk | Kapan / Aynı devam / Öldür maçı | Sonuç varyansı |
| Yıldız formda | Bir oyuncu 8.5+ puan | Ona oynat talimatı / Devam | xG boost, ego riski |
| Sakatlık | Sakatlık gerçekleşti | Riskli devam / Değiştir / Tıbbi ekip | Şiddet farkı |
| Duran top | Kritik serbest vuruş | Kim vuracak (3 aday) | Doğrudan xG |
| Penaltı | Penaltı kazanıldı | Kim atacak | Yüksek gerilim anı |

**Sunum:** 2D üstten görünüm pitch + hareket eden noktalar (Flutter `CustomPainter`, 60fps, çok hafif). Tam 3D **yok** — maliyet/fayda oranı kötü.

### 11.5 Maç Sonrası

```
┌─── MAÇ SONU ────────────────────────────┐
│  ANKARA GÜCÜ  2 - 1  DEMİRSPOR          │
│                                         │
│  ⭐ Maçın Adamı: Arslan Demir (8.4)      │
│     2 gol · 4 şut · 89% pas             │
│                                         │
│  Kasa      +₣18.400  ▲                  │
│  Taraftar  +3        ▲                  │
│  Soyunma   +5        ▲                  │
│  Yönetim   +2        ▲                  │
│                                         │
│  📈 Lig: 8. → 6.                        │
│  [ Devam ]                              │
└─────────────────────────────────────────┘
```
Sonrasında **her zaman** 1–2 karar kartı gelir (maç sonucundan tetiklenmiş: yenilgide basın, galibiyette sponsor, sakatlıkta sağlık).

**Oyuncu maç puanı (1.0–10.0):**
```
puan = 6.0
  + gol × 1.2  + asist × 0.8
  + (pozisyonel katkı skoru: pas isabeti, ikili mücadele, kurtarış)
  − yenilen gol payı (defans oyuncuları için)
  − sarı 0.3 / kırmızı 1.5
  ± consistency bazlı rastgelelik ( ±(100-consistency)/45 )
```

### 11.6 Anlatım Motoru (Commentary)

Metin şablonları + değişken enjeksiyonu. Her olay için 8–15 varyant → tekrar hissi azalır.

```dart
// örnek şablon havuzu
'GOL_KONTRA': [
  '{scorer} kontra atakta boşluğu buldu — {keeper} çaresiz! {scoreline}',
  '{assister} topu {scorer}\'e bıraktı, gerisi kolaydı. {scoreline}',
  'Savunma açık kalmıştı. {scorer} affetmedi. {scoreline}',
],
'KACIRDI_YAKIN': [
  '{shooter} kaleyi bomboş buldu ama topu dışarı attı!',
  'İnanılmaz! {shooter} oradan atamazdı, attı.',
]
```
Lokalizasyonda bu şablonlar **cinsiyet/çekim** farkları için ayrı yazılır (Türkçe ek uyumu: "{scorer}'in" → yazılım tarafında ünlü uyumu helper'ı gerekli, §23.4).

### 11.7 Determinizm ve Doğrulanabilirlik
Simülasyon **saf fonksiyon** olmalı:
```dart
MatchResult simulate(MatchSetup setup, int seed)
```
- Aynı setup + seed → aynı sonuç, her cihazda
- Seed sunucudan gelir (PvP ve lig maçlarında) → istemci hile yapamaz
- Sunucu aynı Dart kodunu (Cloud Function / Dart backend) çalıştırıp sonucu doğrular
- `dart:math Random(seed)` yerine **kendi Xorshift128+ implementasyonun** — platform/versiyon bağımsızlığı garantisi

### 11.8 Sim Dengesi Doğrulama (Zorunlu Test)
Motor yazıldıktan sonra **10.000 maç toplu simülasyonu** çalıştır ve şu bantları doğrula:

| Metrik | Hedef bant | Gerçek futbol referansı |
|---|---|---|
| Ortalama gol/maç | 2.5 – 3.0 | ~2.7 |
| Ev sahibi galibiyet oranı | %42 – %47 | ~%45 |
| Beraberlik oranı | %23 – %28 | ~%25 |
| 0-0 oranı | %6 – %9 | ~%8 |
| 4+ gollü maç oranı | %11 – %16 | ~%13 |
| Favori (10+ OVR fark) galibiyet | %62 – %70 | — |
| Maç başına sarı kart | 3.0 – 4.5 | ~3.8 |
| Sezonluk sakatlık (30 kişilik kadro) | 12 – 22 | — |

> Bu test `test/sim_balance_test.dart` içinde otomatik çalışır ve CI'da bant dışına çıkarsa **build kırılır**.

---

## 12. KARAR KARTLARI SİSTEMİ

> **Bu oyunun kalbi.** Diğer her sistem bu sistemi besler veya bundan beslenir.

### 12.1 Dört Gösterge

| Gösterge | Simge | Ne temsil eder | 0 olursa | 100 olursa |
|---|---|---|---|---|
| **Kasa** | 💰 | Nakit sağlığı | İflas → yönetim seni kovar | Yönetim "neden harcamıyorsun?" (hafif ceza) |
| **Taraftar** | 📣 | Tribün desteği | Protesto → Yönetim güveni −25, gelir −%40 | Tribün 12. adam (+ev sahibi bonusu) |
| **Soyunma Odası** | 👥 | Kadro morali | İsyan → oyuncular performans −%25, transfer talebi | Takım uyumu +10 |
| **Yönetim** | 🏛️ | Başkanın güveni | **GÖREVDEN ALINMA** | Transfer bütçesi +%30 |

**Görsel:** Ekranın üstünde 4 yatay bar. Kart seçilince ilgili barlar animasyonla hareket eder (+haptik +ses). Değişim büyükse ekran hafif titrer.

**Kritik tasarım kararı:** Göstergeler 0'a inince **anında oyun bitmez**. Önce **uyarı aşaması** (kırmızı yanıp söner, "Son uyarı" kartı çıkar), sonra 3 maçlık geri dönüş penceresi. Bu, adaletsizlik hissini önler ve gerilimi maksimize eder (near-miss → §17.5).

### 12.2 Kart Anatomisi

```
┌──────────────────────────────────────────┐
│  💰 ███████░░░  📣 █████░░░░░            │
│  👥 ████████░░  🏛️ ███░░░░░░░  ⚠         │
├──────────────────────────────────────────┤
│  [Yüz görseli]                           │
│  ARSLAN DEMİR · Forvet · Kaptan          │
├──────────────────────────────────────────┤
│  "Hocam, kulüpten üç kat maaş teklifi    │
│   aldım. Gitmek istemiyorum ama          │
│   ailem var. Ne diyorsun?"               │
├──────────────────────────────────────────┤
│  ◀ "Kal, sana söz veriyorum"             │
│    ▶ "Git, seni tutmam"                  │
│  [ Zam teklif et ]   (₣2.400/hafta)      │
└──────────────────────────────────────────┘
```

**Etkileşim:** Kaydırma (sol/sağ) = 2 ana seçenek. Ekstra seçenekler alt butonlar olarak. Kaydırırken **etkilenecek göstergeler önizlemesi** hafif belirir (belirsizlik korunur — sadece hangi gösterge, ne kadar değil).

### 12.3 Kart Kategorileri ve Dağılım

| Kategori | Payı | Örnek | Ana etki |
|---|---|---|---|
| **Kadro / Soyunma Odası** | %22 | Zam talebi, kadro dışı küskünlük, kavga | Soyunma Odası |
| **Basın / Medya** | %14 | Maç sonu röportaj, hakem eleştirisi | Taraftar, Yönetim |
| **Yönetim / Başkan** | %13 | Bütçe kesintisi, hedef değişikliği, akraba oyuncu | Yönetim, Kasa |
| **Taraftar / Ultra** | %11 | Bilet zammı, koreografi desteği, protesto | Taraftar |
| **Transfer / Menajerler** | %12 | Agent teklifi, dedikodu, rakip teklifi | Kasa, Soyunma |
| **Tıbbi / Sakatlık** | %8 | Riskli oyuncu, tedavi kararı | Soyunma, performans |
| **Finans / Sponsorluk** | %8 | Sponsor teklifi, bahis şirketi teklifi (etik!) | Kasa, Taraftar |
| **Altyapı / Gençlik** | %6 | Yetenekli çocuk, aile itirazı | Uzun vade |
| **Kişisel (Menajer RPG)** | %4 | Sağlık, aile, rakip kulüp teklifi | Menajer XP, kariyer |
| **Kriz / Skandal** | %2 | Bahis skandalı, doping, mali denetim | Hepsi, yüksek şiddet |

### 12.4 Kart Seçim Algoritması (En kritik kod)

Rastgele kart **kötü tasarımdır**. Bağlama duyarlı ağırlıklı seçim:

```dart
Card selectNextCard(GameState s) {
  final pool = allCards.where((c) =>
    c.meetsPrerequisites(s) &&          // ön koşullar (lig, sezon, tesis, oyuncu var mı)
    !s.recentCardIds.contains(c.id) &&  // son 40 kartta gösterilmedi
    s.now > c.cooldownUntil             // kart bazlı cooldown
  ).toList();

  // 1) Aktif zincir varsa öncelik (Zeigarnik)
  final chain = s.activeChains.firstWhereOrNull((ch) => ch.readyToAdvance(s.now));
  if (chain != null) return chain.nextCard();

  // 2) Kriz durumu → kurtarma kartı enjekte et
  for (final m in s.meters) {
    if (m.value < 18) {
      final rescue = pool.where((c) => c.canRaise(m.type)).toList();
      if (rescue.isNotEmpty && rng.next() < 0.62) return weightedPick(rescue, s);
    }
  }

  // 3) Ağırlıklı seçim
  return weightedPick(pool, s);
}

double weight(Card c, GameState s) {
  double w = c.baseWeight;                             // 1.0 tipik, nadir kartlar 0.15
  w *= c.categoryWeight(s.categoryFatigue);            // aynı kategori üst üste gelmesin
  w *= c.contextBoost(s);                              // tetikleyici bağlam (maç kaybedildi vs)
  w *= c.meterPressure(s.meters);                      // düşük göstergeye dokunan kartlar ↑
  w *= c.noveltyBonus(s.seenCount[c.id] ?? 0);         // hiç görülmemiş kart ×1.9
  w *= c.seasonRelevance(s.seasonDay);                 // sezon sonu ≠ sezon başı
  return w;
}
```

**Kategori yorgunluğu (fatigue):** Aynı kategoriden kart geldiğinde o kategorinin ağırlığı ×0.35 olur ve her yeni kartta ×1.25 ile toparlanır. Sonuç: çeşitlilik hissi.

### 12.5 Kart Zincirleri (Story Arcs)

Zincir = 2–6 kartlık, günlere yayılan hikâye. **Zeigarnik etkisinin ana motoru.**

**Örnek zincir: "Akademiden Çıkan Çocuk"**

```
KART 1 (Sezon 2, Gün 1) — Altyapı hocası
"16 yaşında bir çocuk var. Hazır değil ama yeteneği var.
 A takıma alalım mı?"
  ▶ Al (Soyunma −4, "yaşlılar homurdanıyor")
  ◀ Bekletsin (çocuğun morali −)

  → Al seçilirse ZİNCİR devam eder, 2 gün sonra:

KART 2 — Çocuk
"Antrenmanda kimse bana pas vermiyor hocam."
  ▶ Kaptanla konuş (Soyunma −2, çocuk +)
  ◀ "Kendini kabul ettir" (çocuk moral −, gelişim +)
  ▶ [Kaptan Sadık kişilikliyse] "Sana emanet" (Soyunma +5)

  → 3 gün sonra:

KART 3 — Maç öncesi
"Sakatlık var, çocuğu ilk 11'e mi koyalım?"
  ▶ Oynat  → maçta özel senaryo: %35 kahraman, %25 felaket
  ◀ Yedek

KART 4 (sonuca göre dallanır) — Basın
Kahraman ise: "Yeni yıldızı keşfettiniz mi?" → Prestij +, Taraftar +8
Felaket ise:   "Çocuğu yaktınız mı?" → Taraftar −5, çocuk potansiyel −6
```

**Zincir kuralları:**
- Aynı anda maks **3 aktif zincir** (bilişsel yük)
- Zincir adımları arasında min 4 saat, maks 3 gün → unutulmaz ama bunaltmaz
- Zincir tamamlanınca kalıcı bir şey bırakır: bir oyuncu, bir rozet, bir kulüp tarihi kaydı, bir ilişki
- Terk edilmiş zincir (7 gün) → nötr kapanışla otomatik sonlanır

### 12.6 Sonuç Sistemi (Effects)

```json
{
  "id": "star_wage_demand_01",
  "category": "squad",
  "trigger": { "playerMoraleBelow": 45, "playerRarityMin": 4 },
  "actor": "{player.topRated}",
  "text": "Hocam, benim maaşım bu takımda üçüncü sırada. Bu doğru mu?",
  "options": [
    {
      "label": "Haklısın, zam yapıyorum",
      "effects": [
        { "meter": "cash", "value": "-{player.wage}*0.35*12" },
        { "meter": "lockerRoom", "value": 6 },
        { "playerEffect": { "morale": 18, "loyalty": 8 } }
      ],
      "requires": { "cashMin": "{player.wage}*0.35*12" }
    },
    {
      "label": "Sahada göster, sonra konuşuruz",
      "effects": [
        { "meter": "lockerRoom", "value": -5 },
        { "playerEffect": { "morale": -12 } },
        { "startChain": "star_unhappy_arc", "delayHours": 48 }
      ]
    },
    {
      "label": "[Motivatör 3] Ona takımın ne kadar ihtiyacı olduğunu anlat",
      "requires": { "managerPerk": "motivator_3" },
      "effects": [
        { "meter": "lockerRoom", "value": 4 },
        { "playerEffect": { "morale": 10 } }
      ]
    }
  ],
  "weight": 1.0,
  "cooldownDays": 6,
  "maxPerSeason": 2
}
```

**Perk-kilitli seçenekler (`[Motivatör 3]`)** çok önemli: kilitli seçenek **görünür ama gri**. Oyuncu ne kaçırdığını görür → yetenek ağacına yatırım isteği (curiosity gap + FOMO, etik biçimde).

### 12.7 Gösterge Matematiği

```
Her kart 1–3 göstergeyi etkiler. Tipik değişim: ±3 ile ±12
Kriz kartları: ±25'e kadar

Doğal drift (her maç sonrası):
  Kasa      : haftalık gelir/gider ile (§15)
  Taraftar  : sonuç bazlı (G +3, B 0, M −3) + sıralama beklentisi farkı
  Soyunma   : oyuncu moral ortalamasından türetilir (bağımsız değil!)
  Yönetim   : sezon hedefine göre haftalık ±2 + kritik olaylar
```

**Yönetim Güveni özel formülü (kovulma motoru):**
```
beklenenSıra = başkanınHedefi          // örn "ilk 5"
gerçekSıra   = mevcut lig sırası
sapma        = beklenenSıra - gerçekSıra

haftalıkYönetimDeğişimi =
    clamp(sapma × 1.8, -14, +10)
  + (kupaGalibiyeti ? +12 : 0)
  + (maliDurumKötü ? -6 : 0)
  + (basınKartlarıToplamı)
  + (transferBaşarısı × 0.5)
```

### 12.8 Görevden Alınma (Sacking)

**Aşamalar:**
1. **Yönetim < 30:** Sarı uyarı. "Başkan seni odasına çağırdı" kartı. Somut hedef verilir: "Önümüzdeki 3 maçta 5 puan."
2. **Yönetim < 15:** Kırmızı alarm. Ekranda geri sayım: "3 maç kaldı."
3. **Yönetim = 0 veya hedef tutmadı:** **Görevden alındın.**

**Görevden alınma sonrası (KESİNLİKLE oyun sonu değil):**
```
┌─── GÖREVDEN ALINDIN ────────────────────────┐
│  Ankara Gücü ile yollarınız ayrıldı.        │
│                                             │
│  Kariyer özeti:                             │
│  47 maç · 18 G · 12 B · 17 M                │
│  1 kupa · 2 terfi                           │
│                                             │
│  Ama menajer itibarın kaldı: 340 puan       │
│  Ve 3 kulüp seni istiyor:                   │
│                                             │
│  ▸ Bursa Yıldızspor  (Lig 14) — İstikrarlı  │
│  ▸ Adana Şimşek      (Lig 9)  — Kriz içinde │
│  ▸ Sivas Kalespor    (Lig 17) — Zengin başkan│
│                                             │
│  [ Kulüp seç ]                              │
└─────────────────────────────────────────────┘
```

**Neden bu tasarım harika:**
- Ceza gerçek (kulübünü, tesislerini, kadronu kaybediyorsun → **loss aversion maksimum**)
- Ama oyun bitmiyor → öfkeyle silme yok
- Menajer seviyesi, yetenekleri, itibarı **kalıcı** → RPG ilerlemesi korunuyor
- Yeni kulüp seçimi = yeni bir başlangıç heyecanı (fresh start effect)
- Bazı oyuncular bunu **kasıtlı** yapar (rich club'a geçmek için) → emergent gameplay

**Denge:** Görevden alınma **oynayan oyuncuların %12–18'inde ilk 30 günde** gerçekleşmeli. Daha fazlası öfke, daha azı gerilimsizlik. Bu oran analytics ile izlenir (`manager_sacked` / `dau`).

### 12.9 Kart İçerik Üretim Hattı

| Aşama | Kim | Çıktı | Hedef hız |
|---|---|---|---|
| 1. Konsept | Designer | Tek satırlık fikir + kategori | 40/gün |
| 2. Yazım | Yazar | Metin + seçenekler + ton | 15/gün |
| 3. Denge | Designer | Effect değerleri | 25/gün |
| 4. JSON | Designer | Şemaya uygun dosya | 30/gün |
| 5. QA | Test | Ön koşul/etki doğrulama | 40/gün |
| 6. Lokalizasyon | Çevirmen | Hedef diller | 30/gün/dil |

**İçerik hedefleri:**
- 🟢 MVP: **200 kart** + 15 zincir (≈ 8 gün oyun, tekrar hissi başlamadan)
- 🟡 v1.2: 450 kart + 40 zincir
- 🔵 6. ay: 900+ kart, ayda 60 yeni kart (live-ops)

> **Tekrar eşiği kuralı:** Bir oyuncu 30 gün oynadığında (≈450 kart görür) hiçbir kartı 3 kereden fazla görmemeli. Bu → min 200 kart + bağlam varyasyonu.

### 12.10 Kart Yazım Kuralları (Yazar Brief'i)

1. **Maks 220 karakter** ana metin. Telefon ekranında kaydırma yok.
2. **Daima bir NPC konuşur.** Anlatıcı sesi değil, karakter sesi.
3. **Her iki seçenek de savunulabilir olmalı.** Test: bir tanesi %85'ten fazla seçiliyorsa kart bozuk → yeniden dengele.
4. **Sonuç metni seçimi yargılamaz.** "Kötü seçim!" yok. Sonucu göster, yorumu oyuncuya bırak.
5. **Kulüp/oyuncu isimleri dinamik enjekte edilir** — kart 100 farklı bağlamda çalışmalı.
6. **Sayı verme, his ver.** "Moral −12" değil, "Soyunma odası buz gibi oldu."
7. **Tekrar eden NPC'ler yarat.** Başkan Recep Vardar, Gazeteci Nihal Aksu, Ultra lideri "Baba" — tanıdıklık = bağlanma.
8. **Etik sınır:** Bahis, doping, şike konuları **eleştirel** çerçevede ele alınır; oyuncu reddedince ödüllendirilir (§24.5).

---
## 13. MENAJER RPG KATMANI

### 13.1 Neden RPG Katmanı Var?
Tycoon oyunlarının en büyük zaafı: **oyuncunun kendisi ilerlemiyor**, sadece sayılar büyüyor. Menajer karakteri, kulüp kaybedilse bile kalıcı olan bir ilerleme ekseni sağlar — bu, görevden alınmayı **oynanabilir** kılan şey.

### 13.2 Menajer Karakteri

```
MENAJER
├── Avatar     : yüz (12 baz + katmanlı özelleştirme), kıyafet (takım elbise/eşofman)
├── Seviye     : 1–60 (XP ile)
├── Yetenek Puanı : her seviyede 1, her 5 seviyede 2
├── Uzmanlık   : 5 daldan seçilir, dallar arası geçiş mümkün (bedelli)
├── İtibar     : 0–2000 (kariyer boyu, sıfırlanmaz)
├── Lisans     : D → C → B → A → Pro (hangi ligde çalışabileceğini belirler)
├── Kariyer    : tüm kulüpler, maçlar, kupalar, rekorlar
└── Özellikler : Taktik, Pazarlık, Motivasyon, Göz (scouting), Medya (0–99)
```

### 13.3 XP Kaynakları

| Eylem | XP | Not |
|---|---|---|
| Maç oynandı | 40 | |
| Galibiyet | +60 | |
| Beraberlik | +25 | |
| Favori olmadığı maçta galibiyet | +80 | upset bonusu |
| Karar kartı çözüldü | 15 | |
| Zincir tamamlandı | 120 | |
| Transfer tamamlandı | 50 | |
| Akademi oyuncusu A takımda 10 maç | 200 | |
| Tesis seviye atladı | 90 | |
| Sezon tamamlandı | 500 | |
| Terfi | 1.200 | |
| Kupa | 2.000 | |
| Günlük görev seti | 100 | |

**Seviye eğrisi:**
```
GerekliXP(n) = 320 × n^1.62
Sv2: 985 · Sv5: 4.100 · Sv10: 13.400 · Sv20: 41.000 · Sv40: 126.000 · Sv60: 250.000
```
Hedef tempo: Sv10 ≈ 3. gün · Sv20 ≈ 12. gün · Sv30 ≈ 30. gün · Sv45 ≈ 90. gün · Sv60 ≈ 200+ gün.

### 13.4 Uzmanlık Dalları ve Yetenek Ağacı

**5 dal, her dalda 12 yetenek, 5 kademe derinlik.**

#### 🎯 TAKTİKÇİ — Maç kazanma
| Yetenek | Kademe | Etki |
|---|---|---|
| Saha Okuma | 1–5 | Canlı Anlar'da +1 karar anı / kademe |
| Devre Arası Konuşması | 1–3 | Devre arası taktik değişimi +%3/kademe |
| Karşı Taktik | 1–5 | Rakip zayıflık raporu doğruluğu |
| Duran Top Ustası | 1–3 | Duran top xG +%12/kademe |
| Kontra Uzmanı | 1–3 | Kontra şut çarpanı 1.35 → 1.55 |
| Baskı Disiplini | 1–4 | Yüksek pres fitness cezası −%40 |
| 12. Adam | 1–3 | Ev sahibi bonusu +%2/kademe |
| Son Dakika | 1–2 | 85+ dakikada xG +%20 |

#### 💼 TÜCCAR — Transfer & ekonomi
| Yetenek | Kademe | Etki |
|---|---|---|
| Sert Pazarlıkçı | 1–5 | Bonservis −%3/kademe |
| Maaş Tavanı | 1–4 | Maaş taleplerini −%4/kademe düşür |
| Satış Ustası | 1–4 | Sattığın oyuncudan +%5/kademe |
| Ağ | 1–3 | AI kulüp ilişkileri hızlı yükselir |
| Serbest Avcısı | 1–3 | Serbest oyuncularda kalite tavanı ↑ |
| Sponsor Sihirbazı | 1–4 | Sponsor gelirleri +%6/kademe |
| Bilet Fiyatlaması | 1–3 | Fiyat artışının taraftar cezası −%30 |
| Mali Disiplin | 1–2 | Bakım maliyetleri −%15 |

#### 🌱 AKADEMİ USTASI — Uzun vade
| Yetenek | Kademe | Etki |
|---|---|---|
| Yetenek Avcısı | 1–5 | Akademi genç potansiyeli +3/kademe |
| Genç Gelişimi | 1–5 | 21 yaş altı gelişim +%8/kademe |
| Sabır | 1–3 | Genç oyuncu moral cezası −%50 |
| Ustalık Aktarımı | 1–3 | Kadroda 30+ yaş varsa gençlere +%10 |
| İkinci Şans | 1–2 | Elenen akademi oyuncusu %30 geri döner |
| Yerel Kahraman | 1–4 | Akademi oyuncusu oynatınca Taraftar +2/maç |

#### 🔥 MOTİVATÖR — İnsan yönetimi
| Yetenek | Kademe | Etki |
|---|---|---|
| Soyunma Odası Hakimi | 1–5 | Soyunma Odası kayıpları −%8/kademe |
| İkna | 1–4 | Kartlarda özel diyalog seçenekleri açılır |
| Kriz Yöneticisi | 1–3 | Gösterge <25 iken toparlanma ×1.5 |
| Kaptan Seçimi | 1–2 | Kaptan bonusu +4 → +10 |
| Baskı Altında | 1–3 | Oyuncuların mentality etkisi +%15 |
| Aile Ortamı | 1–4 | Oyuncu sadakati, transfer talebi −%40 |

#### 🎤 SAHNE İNSANI — Medya, taraftar, prestij
| Yetenek | Kademe | Etki |
|---|---|---|
| Basın Ustası | 1–5 | Basın kartlarında negatif etki −%10/kademe |
| Halkın Adamı | 1–4 | Taraftar kazanımı +%8/kademe |
| Zihin Oyunları | 1–3 | Maç öncesi açıklama ile rakip −%3 |
| Marka Değeri | 1–3 | Sponsor kalitesi ↑, prestij ↑ |
| Kalkan | 1–2 | Kötü sonuçlarda Yönetim cezası −%25 |
| Ultra Dostu | 1–3 | Taraftar Evi etkisi ×1.4 |

**Kurallar:**
- Bir dalda 8 puan harcamadan diğer dalın 4. kademesi açılmaz → uzmanlaşma teşviki
- **Yeniden dağıtım (respec):** Sezon başında 1 bedava, sonrası Altın Rozet veya ₣ ile
- Yetenekler **kart seçeneklerini açar** (§12.6) — sadece sayı değil, içerik kilidi

### 13.5 Menajer İtibarı ve Lisans

```
İtibar = Σ(maç puanları) + kupa×150 + terfi×80 + sezonHedefiTutturma×60
       − görevdenAlınma×120 + akademiBaşarısı×40
```

| Lisans | İtibar gereksinimi | Erişilebilir lig | Nasıl alınır |
|---|---|---|---|
| D | 0 | Lig 20–16 | Başlangıç |
| C | 150 | Lig 15–11 | Otomatik |
| B | 450 | Lig 10–6 | Otomatik + kurs kartı |
| A | 900 | Lig 5–2 | Kurs (7 gün, ₣ maliyeti) |
| Pro | 1.600 | Elit Lig + Milli Takım | Kurs + 1 kupa şartı |

**Neden lisans var:** Görevden alındıktan sonra hangi kulüplerin seni istediğini belirler → kariyer hissi + kalıcı ilerleme kanıtı.

### 13.6 Kariyer Ekranı (Duygusal Yatırım Vitrini)
Menajer profili sayfası oyuncunun **hikâyesini** gösterir:
- Zaman çizelgesi: her kulüp, süre, en iyi sıra, kupalar
- "Efsanelerin": senin kulübünde 100+ maç oynamış oyuncular (yüzleriyle)
- Rekorlar: en büyük galibiyet, en uzun seri, en pahalı transfer, akademiden çıkan en iyi oyuncu
- Rozetler: 60+ rozet (§14.7)
- **Paylaş butonu** → kariyer kartı görseli üretir (organik pazarlama, §27.6)

---

## 14. META İLERLEME

### 14.1 Lig Piramidi (20 Kademe)

| Lig | İsim | Takım | Ort. Rakip OVR | Maç Başı Gelir | Yayın Geliri/Hafta | Tipik Ulaşım Günü |
|---|---|---|---|---|---|---|
| 20 | Amatör Küme | 11 | 38 | ₣2.400 | ₣3.000 | 0 (başlangıç) |
| 19 | Bölgesel D | 11 | 42 | ₣3.600 | ₣4.500 | 7 |
| 18 | Bölgesel C | 11 | 46 | ₣5.400 | ₣7.000 | 12 |
| 17 | Bölgesel B | 11 | 49 | ₣8.000 | ₣10.500 | 17 |
| 16 | Bölgesel A | 11 | 52 | ₣12.000 | ₣16.000 | 22 |
| 15 | 3. Lig C | 11 | 55 | ₣18.000 | ₣24.000 | 28 |
| 14 | 3. Lig B | 11 | 58 | ₣26.000 | ₣35.000 | 34 |
| 13 | 3. Lig A | 11 | 61 | ₣38.000 | ₣52.000 | 41 |
| 12 | 2. Lig C | 11 | 63 | ₣56.000 | ₣76.000 | 49 |
| 11 | 2. Lig B | 11 | 66 | ₣82.000 | ₣110.000 | 58 |
| 10 | 2. Lig A | 11 | 68 | ₣120.000 | ₣160.000 | 68 |
| 9 | 1. Lig D | 11 | 70 | ₣175.000 | ₣235.000 | 80 |
| 8 | 1. Lig C | 11 | 72 | ₣255.000 | ₣340.000 | 94 |
| 7 | 1. Lig B | 11 | 74 | ₣370.000 | ₣495.000 | 110 |
| 6 | 1. Lig A | 11 | 76 | ₣540.000 | ₣720.000 | 130 |
| 5 | Süper Lig D | 11 | 78 | ₣780.000 | ₣1.05M | 155 |
| 4 | Süper Lig C | 11 | 80 | ₣1.13M | ₣1.5M | 185 |
| 3 | Süper Lig B | 11 | 82 | ₣1.65M | ₣2.2M | 220 |
| 2 | Süper Lig A | 11 | 84 | ₣2.4M | ₣3.2M | 265 |
| 1 | **ELİT LİG** | 11 | 87 | ₣3.5M | ₣4.7M | 320 |

**Gelir eğrisi katsayısı: ×1.45/lig.** Maliyet eğrisi ×1.52/lig → yukarı çıktıkça **hafif daralan** ekonomi → sürekli optimizasyon baskısı (sıkılma önleyici).

### 14.2 Terfi ve Küme Düşme

```
11 takımlı lig · 21 maç (çift devre, 1 bay haftası kupaya)

Sıra 1–2  → TERFİ (doğrudan)
Sıra 3–4  → PLAY-OFF (tek maç eleme, sezon sonu bonusu)
Sıra 5–8  → Kalır
Sıra 9–11 → KÜME DÜŞER
```

**Küme düşme yumuşatması (öfke yönetimi):**
- İlk kez düşen oyuncuya **"Yönetim sana bir sezon daha güveniyor"** kartı → görevden alınmaz
- Düşünce kadro kalır, tesisler kalır, sadece gelir düşer
- 🔵 "Düşme Sigortası": Sezon Bileti sahiplerine sezon başında 1 kez otomatik kurtarma (değer algısı)

### 14.3 Sezon Akışı (7 Gün Detaylı)

| Gün | Ana olay | Live-ops kancası |
|---|---|---|
| **Pzt** | Sezon açılışı · Başkan hedefi kartı · Transfer dönemi açılır · Yeni sıralama sıfırlanır | "Yeni sezon" push, sezon teması duyurusu |
| **Sal** | Maç 1–3 · Sponsor görüşmeleri | Günlük görev seti |
| **Çar** | Maç 4–6 · Scout raporları toplu gelir | "Haftanın oyuncusu" oylaması |
| **Per** | Maç 7–9 · Akademi raporu | Rakip lig sıralaması bildirimi |
| **Cum** | Maç 10–12 · Basın günü (kart yoğunluğu ↑) | Hafta sonu etkinliği başlar |
| **Cmt** | Maç 13–15 + **KUPA MAÇI** · Transfer deadline 12:00 | "Deadline Day" indirimleri |
| **Paz** | Maç 16–21 · **SEZON FİNALİ** · Terfi/düşme · Ödül töreni | En yüksek DAU günü, en yüksek IAP |

**Sezon Finali sunumu (peak-end rule için tasarlanır):**
```
1. Son maç canlı oynanır (zorunlu Canlı Anlar)
2. Diğer maçlar eşzamanlı → "Diğer sahalardan haberler" akışı
3. Final lig tablosu animasyonu (takım takım yerleşir)
4. Terfi/kalma/düşme kararı — konfeti veya sessizlik
5. Yıllık ödüller: Sezonun Oyuncusu, En Golcü, Keşif, Sezonun Menajeri
6. Kulüp Tarihi'ne kayıt düşülür
7. Sezon ödülleri açılır (kutu açılışı estetiği ama gambling değil — §16.6)
8. Yeni sezon önizlemesi: "Sezon 4 teması: Genç Kan"
```

### 14.4 Prestij Sistemi (Yeni Kulüp / Dinasti)

Sezon 8+ ve Lig ≤5'e ulaşan oyuncular için: **"Yeni bir hanedan kur."**

```
Bırakırsın: kulüp, kadro, tesisler, kasa, lig konumu
Korursun:  menajer seviyesi, yetenekler, itibar, lisans, rozetler, kozmetikler
Kazanırsın: HANEDAN PUANI (kalıcı bonus para birimi)
```

**Hanedan Puanı hesabı:**
```
HP = (ulaşılanLigKademesiBonusu) + (kupa × 40) + (sezonSayısı × 8)
   + (efsaneOyuncuSayısı × 25) + (maks kulüp değeri / 500.000)

Lig 5 → 200 HP · Lig 3 → 400 HP · Lig 1 → 900 HP · Elit şampiyonluk → 1.500 HP
```

**Hanedan Mağazası (kalıcı bonuslar):**

| Bonus | Maliyet | Etki |
|---|---|---|
| Miras Kasası | 150 HP | Yeni kulüp ₣50.000 ile başlar |
| Ün | 200 HP | Yeni kulüpte prestij +100 |
| Antrenör Ağı | 300 HP | Tüm tesisler Sv.1 yerine Sv.2 |
| Eski Dostlar | 400 HP | Önceki kulübünden 1 oyuncu getir |
| Hızlı Yükseliş | 500 HP | Gelişim hızı kalıcı +%10 |
| İkinci İnşaat Slotu | 600 HP | Kalıcı |
| Efsane Statüsü | 1.000 HP | Lig 15'ten başla |
| Hanedan Arması | 800 HP | Kozmetik: özel arma seti |

**Neden prestij:** D60+ oyuncularda "yapacak bir şey kalmadı" duvarını yıkar. Ama **zorunlu değil** — Elit Lig'de kalıp live-ops içeriği oynamak da geçerli bir yol (özerklik).

### 14.5 Uzun Vadeli İçerik Katmanları (D30+)

| Katman | Açılış | Ne verir |
|---|---|---|
| **Kıta Kupası** | Lig ≤8 | Haftalık ekstra 2 maç, yüksek ödül, farklı rakip havuzu |
| **Rekabet Ligi** (asenkron PvP) | Sezon 2 sonu | 30 kişilik grup, haftalık sıralama, kozmetik ödül |
| **Menajer Ligi** | Sezon 4 | Arkadaşlarla özel lig |
| **Milli Takım Görevi** | Pro lisans | Paralel kısa kampanya (2 hafta) |
| **Efsane Kadro** | Sezon 6 | Emekli olan oyuncularının koleksiyonu |
| **Sezon Teması** | Her sezon | Live-ops: özel kart seti + ödül yolu |
| **Hanedan** | Sezon 8 | Prestij döngüsü |

### 14.6 Rekabet Ligi (Asenkron PvP) 🟡

**Nasıl çalışır:** Gerçek PvP maç değil — haftalık **puan yarışı**.
```
30 oyunculu grup (benzer kulüp gücü + benzer harcama bandı ile eşleştirilir)
Haftalık puan = lig performansı + karar kalitesi + gelişim
İlk 6 → üst lige · Son 6 → alt lige (Bronz → Gümüş → Altın → Elmas → Efsane)
```
**Neden gerçek PvP değil:** Gerçek zamanlı PvP altyapısı pahalı, eşleştirme sorunlu, ödeme baskısı yaratır. Puan yarışı aynı sosyal motivasyonu %15 maliyetle verir.

### 14.7 Rozet / Başarım Sistemi (60+ rozet)

Kategoriler: Kariyer, Transfer, Akademi, Maç, Ekonomi, Drama, Gizli.

Örnekler:
| Rozet | Şart | Nadirlik |
|---|---|---|
| İlk Adım | İlk galibiyet | Yaygın |
| Yükseliş | İlk terfi | Yaygın |
| Cimri | Bir sezonu transfer yapmadan bitir | Nadir |
| Kendi Çocuklarımız | İlk 11'de 6 akademi oyuncusu | Nadir |
| Kılpayı | Yönetim güveni 5'e düşüp toparlan | Nadir |
| Rönesans | Görevden alındıktan sonra terfi | Nadir |
| Milyoner | Bir oyuncuyu ₣1M üstüne sat | Yaygın |
| Yenilmez | 21 maçlık sezonu yenilgisiz bitir | Efsanevi |
| Hanedan | 3 farklı kulüple Elit Lig | Efsanevi |
| ??? | Gizli rozet (10 adet) | — |

Rozetler **kozmetik + küçük kalıcı bonus** verir (asla güç değil, ör. arma çerçevesi + 5 HP).

---
---

# BÖLÜM III — EKONOMİ VE PSİKOLOJİ

## 15. EKONOMİ TASARIMI VE DENGE

### 15.1 Para Birimleri

| Birim | Simge | Tip | Kaynak | Harcanır | Satın alınabilir? |
|---|---|---|---|---|---|
| **Kasa** | ₣ | Soft | Maç geliri, sponsor, satış, yayın | Transfer, maaş, inşa, bakım | Dolaylı (paket içinde) |
| **Altın Rozet** | 🏅 | Hard | IAP, sezon ödülü, başarım, rewarded | Hızlandırma, özel scout, kozmetik, respec | **Evet** |
| **Prestij Puanı** | ⭐ | Orta | Sezon sonu, kupa, hedef tutturma | Tesis kilidi açma, özel personel | Hayır |
| **Scout Bileti** | 🔍 | Bilet | Günlük, görev, rewarded ad | Scout görevi başlatma | Paket içinde |
| **Hanedan Puanı** | 👑 | Meta | Prestij (rebirth) | Kalıcı bonuslar | Hayır |

> **Tasarım kuralı:** 5 para birimi üst sınırdır. Daha fazlası bilişsel yük. `Antrenman Kredisi`, `Enerji` gibi ek birimler **kasıtlı olarak eklenmedi** — enerji sistemi yok (Sütun 2, "no grind walls" vaadi).

**Neden ₣ (jenerik para)?** Gerçek para birimi (₺/€) kullanmak: (a) lokalizasyon karmaşası, (b) enflasyon gerçekliği sorunları, (c) mağaza politikalarında "gerçek para" karışıklığı riski. Jenerik sembol daha temiz.

### 15.2 Gelir Kaynakları (Haftalık)

```
── MAÇ GÜNÜ GELİRİ (iç saha, sezon başına ~10-11 maç) ────────────
biletGeliri = kapasite × doluluk × biletFiyatı

doluluk = clamp(
    0.35
  + (taraftarMemnuniyeti / 220)          // 0 → 0, 100 → +0.45
  + (ligSırasıBonusu: 1. ise +0.15, son ise -0.10)
  + (rakipPrestijBonusu: derbi +0.12)
  - (biletFiyatı / önerilenFiyat - 1) × 0.55   // fiyat esnekliği
  , 0.15, 1.00)

önerilenFiyat = 6 + (21 - ligKademesi) × 2.4      // Lig20: 8₣ · Lig1: 54₣

── VIP LOCA ──────────────────────────────────────────────────────
vipGeliri = vipSeviyeGeliri × doluluk

── YAYIN GELİRİ (haftalık sabit, lige bağlı) ─────────────────────
yayınGeliri = ligYayınTablosu[lig] × (1 + (6 - min(sıra,6)) × 0.04)

── SPONSORLUK (3 slot: forma göğüs, kol, stadyum adı) ────────────
sponsorGeliri = Σ(sponsorTeklifleri)
sponsorKalitesi ~ prestij × medyaMerkeziÇarpanı × ligÇarpanı
Tipik: forma göğüs = haftalık yayın gelirinin %35'i

── ÜRÜN SATIŞI ───────────────────────────────────────────────────
mağazaGeliri = taraftarSayısı × mağazaSeviyeÇarpanı × (memnuniyet/100)

── TRANSFER GELİRİ (düzensiz) ────────────────────────────────────
oyuncu satışı, satıştan pay, kiralık ücreti

── AKADEMİ ───────────────────────────────────────────────────────
Genç oyuncu satışı (yüksek marj, düşük sıklık)
```

### 15.3 Gider Kaynakları (Haftalık)

```
maaşGideri     = Σ(oyuncu.haftalıkMaaş) + personelMaaşları
bakımGideri    = Σ(tesis.bakım)
seyahatGideri  = deplasman maç sayısı × (150 + ligKademesiBonusu)
tıbbiGider     = sakat oyuncu sayısı × 400 × şiddet
bonuslar       = galibiyet primi (opsiyonel, sözleşmeye bağlı)
transferGideri = bonservis + imza bonusu + agent komisyonu (%8)
```

### 15.4 Ekonomi Denge Tablosu — Lig Bazında

| Lig | Haftalık Gelir | Haftalık Gider | Net | Kadro Değeri (tipik) | Transfer Bütçesi |
|---|---|---|---|---|---|
| 20 | ₣28.000 | ₣21.000 | +₣7.000 | ₣60K | ₣15K |
| 18 | ₣48.000 | ₣36.000 | +₣12.000 | ₣130K | ₣35K |
| 16 | ₣95.000 | ₣72.000 | +₣23.000 | ₣310K | ₣85K |
| 14 | ₣190.000 | ₣148.000 | +₣42.000 | ₣720K | ₣190K |
| 12 | ₣380.000 | ₣302.000 | +₣78.000 | ₣1.7M | ₣420K |
| 10 | ₣760.000 | ₣615.000 | +₣145.000 | ₣3.9M | ₣900K |
| 8 | ₣1.52M | ₣1.25M | +₣270.000 | ₣8.5M | ₣1.9M |
| 6 | ₣3.1M | ₣2.58M | +₣520.000 | ₣18M | ₣3.8M |
| 4 | ₣6.2M | ₣5.25M | +₣950.000 | ₣38M | ₣7.5M |
| 2 | ₣12.5M | ₣10.7M | +₣1.8M | ₣78M | ₣14M |
| 1 | ₣19M | ₣16.3M | +₣2.7M | ₣125M | ₣22M |

**Kâr marjı hedefi: %14–20.** Bu dar marj kritik — oyuncu her zaman "biraz daha para lazım" hissetmeli ama asla çaresiz kalmamalı.

### 15.5 Ekonomi Musluk & Lavabo Haritası (Faucets & Sinks)

```
MUSLUKLAR (para girişi)          LAVABOLAR (para çıkışı)
─────────────────────────        ─────────────────────────
Maç geliri          %34   ───►   Maaşlar             %41
Yayın               %26   ───►   Transfer            %28
Sponsor             %18   ───►   Tesis inşa/bakım    %22
Ürün satışı          %9   ───►   Diğer (tıbbi, vs)    %9
Transfer satış       %8
Kupa/ödül            %5
```

**Kural:** Toplam musluk / toplam lavabo = **1.16** (sürekli hafif birikim). Bu oran 1.0'ın altına düşerse oyuncu boğulur, 1.4'ün üstüne çıkarsa ekonomi anlamsızlaşır. Her sürümde telemetriden ölçülür (`economy_net_flow` eventi).

### 15.6 Zaman-Değer Dönüşüm Tablosu

Premium fiyatlamanın temeli: **1 Altın Rozet ≈ 6 dakika beklemeyi atlar veya ≈ ₣X kazanç**.

| Lig bandı | 1 🏅 ≈ ₣ | Gerekçe |
|---|---|---|
| 20–16 | ₣2.500 | Erken oyun, düşük ekonomi |
| 15–11 | ₣12.000 | |
| 10–6 | ₣60.000 | |
| 5–1 | ₣280.000 | Geç oyun |

**Kural:** Doğrudan "para satın al" paketleri, oyuncunun kendi ligindeki **2 haftalık net kârından fazlasını** tek seferde vermemeli → ekonomiyi bozan whale etkisini sınırlar.

### 15.7 Enflasyon ve Ekonomi Sağlığı İzleme

Her sürümde bu metrikler dashboard'da izlenir:

| Metrik | Sağlıklı bant | Sorun sinyali |
|---|---|---|
| Ortalama kasa / haftalık gider | 1.5 – 4.0 | > 8 = enflasyon, < 0.8 = boğulma |
| Kadro değeri / lig ortalaması | 0.9 – 1.6 | > 2.5 = ilerleme çok hızlı |
| Harcanmayan 🏅 stoğu (ort.) | < 400 | > 900 = ödül fazlalığı |
| Tesis Sv.5 ulaşma günü | 90+ | < 45 = içerik tükeniyor |
| Sezon başı transfer bütçesi kullanımı | %60–90 | %100 sürekli = bütçe az |

### 15.8 Denge Ayar Kolları (Live-Ops Tuning Knobs)

Remote Config ile **uygulama güncellemesi olmadan** ayarlanabilir olmalı:

```json
{
  "economy": {
    "income_multiplier": 1.0,
    "wage_multiplier": 1.0,
    "facility_cost_multiplier": 1.0,
    "transfer_fee_multiplier": 1.0,
    "match_reward_multiplier": 1.0
  },
  "progression": {
    "xp_multiplier": 1.0,
    "player_growth_multiplier": 1.0,
    "promotion_difficulty": 1.0
  },
  "cards": {
    "cards_per_session": 2,
    "chain_max_active": 3,
    "meter_change_multiplier": 1.0
  },
  "sacking": {
    "board_decay_rate": 1.0,
    "warning_threshold": 30,
    "grace_matches": 3
  },
  "monetization": {
    "offer_cooldown_hours": 20,
    "rewarded_ad_daily_cap": 8,
    "starter_pack_trigger_day": 2
  }
}
```

> **Zorunlu:** Bu değerlerin hiçbiri koda gömülü olmayacak. Hepsi `RemoteBalanceConfig` üzerinden okunacak, varsayılanları asset içinde JSON olarak bulunacak (offline fallback).

---

## 16. MONETİZASYON

### 16.1 Monetizasyon Felsefesi

> **"Zaman sat, güç satma."**

Ödeme yapan oyuncu **daha hızlı** ilerler ve **daha fazla kozmetik/kolaylık** alır. Ödeme yapmayan oyuncu aynı hedeflere ulaşabilir. Rekabet ligleri harcama bandına göre eşleştirilir, böylece "para ile ezilme" hissi oluşmaz.

**Kırmızı çizgiler (asla yapılmayacaklar):**
- ❌ Enerji/can barı ile oynamayı kısıtlama
- ❌ Sadece parayla alınabilen güç (P2W ekipman/oyuncu)
- ❌ Ödeme yapmadan geçilemeyen ilerleme duvarı
- ❌ Kayıp sonrası "1.99$ ile devam et" teklifi
- ❌ Gerçek para ile doğrudan rastgele kutu (loot box) satışı
- ❌ Reklam izlemeye zorlama (tüm rewarded ad'ler opsiyonel)
- ❌ Kapanması zor / yanıltıcı X butonlu pop-up'lar
- ❌ 18 yaş altı hedefli agresif teklif

### 16.2 Gelir Kırılımı Hedefi

| Kaynak | Gelir payı hedefi | Kullanıcı payı |
|---|---|---|
| Sezon Bileti (abonelik benzeri) | %38 | %2.2 |
| Tek seferlik paketler (starter, bundle) | %27 | %1.8 |
| Altın Rozet paketleri | %19 | %1.1 |
| Kozmetik (arma, forma, stadyum teması) | %6 | %2.5 |
| Rewarded Ads | %10 | %55 |

> Reklamın %10 payı bilinçli — hedef kitle reklamdan çok IAP'ye yatkın, ama rewarded ad **ödeme yapmayanın oyuna katkı yolu** olarak duruyor.

### 16.3 Sezon Bileti (Ana Ürün)

**Fiyat:** $4.99 / ₺129 (sezon = 7 gün) — VEYA aylık $9.99 (4 sezon, %50 tasarruf).

> **Öneri:** Aylık abonelik birincil, tek sezon ikincil. Abonelik LTV'yi %40+ artırır ve mağaza abonelik altyapısı retention'ı otomatik destekler.

**İçerik:**

| Ücretsiz yol | Sezon Bileti yolu |
|---|---|
| 30 kademe ödül | Aynı 30 kademe + premium kademe ödülü |
| ₣ ve küçük ödüller | 🏅, özel oyuncu, kozmetik, tesis indirimi |
| — | 2. inşaat slotu (sezon boyu) |
| — | Günlük +2 scout bileti |
| — | Reklamsız hızlandırma (günde 3 bedava) |
| — | Özel arma çerçevesi + isim rengi |
| — | Düşme sigortası (sezonda 1) |
| — | Detaylı maç istatistikleri |

**Kademe ilerlemesi:** Sezon Puanı ile. Kaynak: maç oynama, kart çözme, görev, hedef. Normal oynayan oyuncu 7 günde ~kademe 26'ya ulaşır → **son 4 kademe hafif zorlayıcı** (goal gradient, ama abartısız).

**Etik kural:** Sezon Bileti alınmadan geçen kademeler **geriye dönük açılır** (sezon içinde alınırsa). Böylece "geç aldım, kaçırdım" cezası yok.

### 16.4 IAP Kataloğu

| Ürün | Fiyat (USD) | İçerik | Hedef persona | Görünürlük |
|---|---|---|---|---|
| **Başlangıç Paketi** | $2.99 | 400🏅 + ₣25K + 5🔍 + arma seti | Kerem | D2, tek seferlik, 72 sa |
| **Menajer Çantası** | $4.99 | 700🏅 + 2. inşaat slotu (kalıcı) | Kerem | D5+ |
| Rozet — Küçük | $1.99 | 200🏅 | Herkes | Mağaza |
| Rozet — Orta | $9.99 | 1.100🏅 (+%10) | Bruno | Mağaza |
| Rozet — Büyük | $24.99 | 3.000🏅 (+%20) | Bruno | Mağaza |
| Rozet — Dev | $49.99 | 6.500🏅 (+%30) | Whale | Mağaza |
| Rozet — Başkan | $99.99 | 14.000🏅 (+%40) | Whale | Mağaza |
| **Sezon Bileti** | $4.99 | §16.3 | Herkes | Sezon başı |
| **Aylık Menajer Kulübü** | $9.99/ay | 4 sezon bileti + günlük 100🏅 | Sadık oyuncu | Sürekli |
| **Transfer Fonu** | $6.99 | Ligine göre ölçekli ₣ + 3🔍 | Transfer dönemi | Cmt 10:00–12:00 |
| **Stadyum Paketi** | $12.99 | Stadyum yükseltme indirimi %50 + kozmetik | İnşaat odaklı | Bağlamsal |
| Kozmetik paketleri | $1.99–$7.99 | Forma, arma, stadyum teması, menajer kıyafeti | Selin | Mağaza |

### 16.5 Rewarded Ads Yerleşimi

| Yer | Ödül | Günlük limit | Doğal mı? |
|---|---|---|---|
| İnşaat hızlandırma | −30 dk | 3 | ✅ "Sponsor devreye girdi" |
| Scout bileti | +1🔍 | 3 | ✅ "Yerel gazete ipucu verdi" |
| Maç geliri ×2 | Maç geliri 2× | 3 | ✅ "Ekstra yayın hakkı" |
| Günlük ödül ×2 | Ödül 2× | 1 | ✅ |
| Transfer pazarı yenile | Liste yenilenir | 2 | ✅ |
| Sakatlık iyileşme hızlandır | −25% süre | 2 | ✅ "Özel klinik" |
| İkinci şans (maç sonrası) | ❌ **YOK** | — | ❌ Sonuç kutsaldır |

**Toplam günlük tavan: 8 reklam** (Remote Config ile ayarlanabilir). Ortalama izleyen kullanıcı 3.2 reklam/gün → ARPDAU katkısı ~$0.012–0.018.

**Format:** Rewarded video (öncelik) + rewarded interstitial. **Zorunlu interstitial YOK** (retention'a zararı gelirinden büyük).

**Aracı (mediation):** AppLovin MAX veya Google AdMob mediation. Waterfall: AppLovin, Unity Ads, Meta, Google, ironSource, Vungle.

### 16.6 "Kutu Açılışı" Estetiği — Kumar Olmadan

Kutu açılışının dopamin etkisini kumar mekaniği olmadan almak:

| Kullandığımız | Kullanmadığımız |
|---|---|
| ✅ Sezon sonu ödül sandığı — **içeriği önceden gösterilir**, sıra rastgele | ❌ Parayla alınan rastgele kutu |
| ✅ Scout raporu açılışı — potansiyel bandı yavaşça belirir | ❌ Oyuncu paketi çekilişi |
| ✅ Akademi genç oyuncu tanıtımı — kart çevirme animasyonu | ❌ %0.5 efsane şansı |
| ✅ Rozet açılışı — başarım kilidi | ❌ Pity timer'lı gacha |

**Kritik:** Herhangi bir rastgelelik **sadece ücretsiz kaynakla** tetiklenir. Gerçek parayla alınan her şeyin içeriği **satın alma öncesi tam olarak bilinir**. Bu hem etik hem hukuki (Belçika/Hollanda loot box yasakları, §24.4).

### 16.7 Teklif Motoru (Offer Engine)

Kişiselleştirilmiş teklifler — ama **saygılı**:

```
Tetikleyiciler:
  · İlerleme takıldı (48 sa'dir tesis yükseltmedi + kasa yetersiz)
  · Sezon başı (transfer bütçesi teklifi)
  · Görevden alınma riski (❌ ASLA teklif verilmez — düşmüş oyuncuyu sömürmek yasak)
  · İlk ödemeden 7 gün sonra (upsell)
  · Uzun süre sonra dönüş (win-back paketi)

Kurallar:
  · Teklifler arası min 20 saat
  · Günde maks 1 pop-up teklif
  · Pop-up X butonu ≥ 44×44 pt, ilk 0.5 sn'de aktif
  · Aynı teklif reddedilirse 5 gün gösterilmez
  · Oturumun ilk 30 saniyesinde asla teklif yok
```

**Harcama bandı eşleştirme:** Oyuncular `spend_tier` (0=hiç, 1=<$10, 2=<$50, 3=$50+) ile etiketlenir. Rekabet Ligi eşleştirmesi %70 ağırlıkla aynı banttan yapılır → adalet algısı.

### 16.8 Fiyatlandırma ve Bölgesel Ayarlama

| Bölge | Fiyat çarpanı | Not |
|---|---|---|
| ABD/UK/DE/Nordik | 1.00 | Referans |
| TR | 0.42 | PPP ayarı — mağaza yerel fiyat katmanı |
| BR/MX/AR | 0.48 | |
| ID/PH/VN/EG | 0.35 | |
| IN | 0.32 | |

Apple/Google'ın kendi fiyat katmanları kullanılır; özel katman tanımlanmaz. TR fiyatları özellikle kritik — TR pazarı yüksek indirme, düşük ARPU; hacim odaklı fiyatlandır.

### 16.9 LTV Modeli (Basitleştirilmiş)

```
LTV(180) = Σ(d=1..180) [ Retention(d) × ARPDAU ]

Retention eğrisi (power-law fit):
  R(d) = R1 × d^(-k)
  R1 = 0.47, k = 0.42  → R7 ≈ 0.22, R30 ≈ 0.11, R90 ≈ 0.066, R180 ≈ 0.049

ARPDAU = $0.115 (hedef)

LTV(180) ≈ 0.115 × Σ R(d) ≈ 0.115 × 27.5 ≈ $3.16
```

**CPI hedefi:** ≤ $1.90 (LTV/CPI ≥ 1.66) → sağlıklı UA. Blended CPI hedefi: TR $0.55, BR $0.70, US $2.80.

**Payback period hedefi:** ≤ 120 gün.

### 16.10 Etik Monetizasyon Kontrol Listesi

Her yeni monetizasyon özelliği bu listeden geçmeli:

- [ ] Ödemeyen oyuncu bu içeriğe başka yolla ulaşabiliyor mu?
- [ ] Satın alma öncesi tam olarak ne alacağı belli mi?
- [ ] Bu teklif oyuncunun bir kaybından/çaresizliğinden mi faydalanıyor?
- [ ] 13–17 yaş bir oyuncuya gösterilse rahatsız edici olur mu?
- [ ] Kapatması kolay mı? (X butonu, geri tuşu, dışına dokunma)
- [ ] Yanlışlıkla satın alma riski var mı? (onay ekranı)
- [ ] Abonelik ise iptal yolu açıkça gösteriliyor mu?
- [ ] Sahte aciliyet ("SON 2 DAKİKA!") var mı? Varsa gerçek mi?
- [ ] Ebeveyn kontrolü/harcama limiti bilgisi erişilebilir mi?

---
## 17. PSİKOLOJİ, HOOK MODELİ VE RETENTION MİMARİSİ

> Bu bölüm oyunun **görünmez mimarisi**. Buradaki her prensip §6–§16'daki somut mekaniklere bağlanır. Psikoloji tek başına bir özellik değildir — mekaniğin içine gömülür.

### 17.1 Temel İlke: Zorlama Değil, Uyum

İki farklı retention felsefesi var:

| ❌ Sömürücü model | ✅ Bizim modelimiz |
|---|---|
| Kaybetme korkusuyla geri getir | Merakla geri getir |
| Zorunlu günlük giriş cezası | Ödüllü ama cezasız devamlılık |
| Kaçırılan içerik geri gelmez | Telafi mekanizmaları var |
| Bitmeyen grind | Doyum noktaları ve doğal duraklar |
| Sonsuz bildirim | Bağlamsal, değerli bildirim |

**Neden:** Sömürücü model kısa vadede D7'yi %3–5 artırır, uzun vadede D90'ı ve mağaza puanını yok eder. Bizim hedefimiz **D180 ve organik büyüme**.

### 17.2 Hook Model (Nir Eyal) — Sistem Sistem Uygulama

Hook Model dört aşamalıdır: **Tetikleyici → Eylem → Değişken Ödül → Yatırım**. Her döngü sonunda oyuncunun oyuna yatırımı artar ve bir sonraki tetikleyiciyi kendisi yaratır.

#### 🔔 AŞAMA 1: TETİKLEYİCİ (Trigger)

**Dış tetikleyiciler:**

| Tetikleyici | Ne zaman | Metin örneği |
|---|---|---|
| Maç saati push | Pencere açıldıktan 15 dk sonra | "Maç başlıyor. Kadro hâlâ dizilmedi." |
| İnşaat bitti | Tamamlanınca | "Antrenman Sahası Sv.3 hazır. Oyuncular şimdiden farkı hissedecek." |
| Scout raporu | Hazır olunca | "Scout'un aradı. 'Bunu görmen lazım.'" |
| Transfer teklifi | AI kulüp teklif verince | "Bursa Yıldızspor, Arslan Demir için ₣180.000 teklif etti." |
| Zincir devamı | 4–24 sa sonra | "Çocuk seni soyunma odasında bekliyor." |
| Sezon finali | Pazar 18:00 | "Son 3 maç. Terfi hâlâ mümkün." |
| Sezon başı | Pazartesi 09:00 | "Sezon 5 başladı. Başkanın yeni bir hedefi var." |
| Yönetim uyarısı | Kritik durumda | "Başkan seni odasına çağırdı." |
| Rakip geçti | Sıralama değişince | "Adana Şimşek seni geçti. 2 puan fark." |
| Sözleşme bitiyor | 1 sezon kala | "Kaptanın sözleşmesi bitiyor. Konuşmalısın." |

**İç tetikleyiciler (asıl hedef — 30. günden sonra dış tetikleyiciye ihtiyaç kalmamalı):**

| Duygu | Oyunun cevabı | Nasıl bağ kurulur |
|---|---|---|
| **Sıkıntı / boş vakit** | 90 saniyelik check-in | Uygulamayı açmak refleks olur (metro, kuyruk) |
| **Merak** ("ne oldu acaba") | Yarım kalan zincir, scout raporu | Zeigarnik |
| **Kontrol arayışı** | Kulübü yönetme fantezisi | Gerçek hayatta kontrol edemediğini burada edersin |
| **Aidiyet** | "Benim kulübüm" | Kişiselleştirme + tarih |
| **Rekabet dürtüsü** | Lig sıralaması | Sosyal karşılaştırma |
| **Kayıp endişesi** | Görevden alınma riski | Loss aversion |

> **Ölçüm:** `session_source` eventi ile organik açılış (push'suz) oranı izlenir. Hedef: D30+ oyuncularda **%65+ organik açılış**. Bu, iç tetikleyicinin kurulduğunun kanıtıdır.

#### 👆 AŞAMA 2: EYLEM (Action) — Fogg Davranış Modeli: B = MAP

Davranış = Motivasyon × Yetenek(Kolaylık) × Tetikleyici. Motivasyon zaten var (futbol tutkusu), o yüzden **kolaylığa** yatırım yaparız.

| Sürtünme kaynağı | Çözümümüz |
|---|---|
| Açılış süresi | Cold start ≤ 2.5 sn, splash'ta veri ön-yüklenir |
| Giriş/hesap | Anonim başlangıç, hesap Sezon 1 sonunda opsiyonel |
| "Ne yapmalıyım?" belirsizliği | Ana ekranda daima 1 net "Sıradaki Adım" kartı |
| Kadro dizme yükü | "Otomatik Diz" tek dokunuş |
| Karmaşık ekonomi | Her sayının yanında doğal dil özeti |
| Uzun maç | Hızlı Sim 8 saniye |
| Menü derinliği | Her ekran ≤ 3 dokunuş |
| Karar yorgunluğu | Seans başına maks 4 kart |

**Ana eylem:** Kart kaydırma. 1 saniye, sıfır bilişsel giriş engeli, anında geri bildirim. Bu, oyunun "atomik eylemi"dir.

#### 🎲 AŞAMA 3: DEĞİŞKEN ÖDÜL (Variable Reward)

Eyal'in üç ödül tipi, üçü de oyunda var:

**a) Kabile Ödülü (Rewards of the Tribe) — sosyal**
- Soyunma odası tepkisi, taraftar tezahüratı, basın manşetleri
- Lig sıralaması, Rekabet Ligi
- Oyuncularının seni sevmesi/sevmemesi
- 🔵 Arkadaş ligleri, kariyer kartı paylaşımı

**b) Av Ödülü (Rewards of the Hunt) — kaynak**
- Scout raporu (ne bulacaksın?) — **en güçlü değişken ödül**
- Maç sonucu (deterministik değil)
- Akademi genç oyuncu üretimi
- Transfer pazarı yenilenmesi
- Sezon ödül sandığı

**c) Benlik Ödülü (Rewards of the Self) — ustalık**
- Tesis yükseltme (görünür ilerleme)
- Menajer seviyesi ve yetenek ağacı
- Rozetler
- Zorlu bir maçı kazanmak
- Bir gencin efsaneye dönüşmesini izlemek

**Değişkenlik dozajı (kritik):**

| Sistem | Rastgelelik | Neden bu seviyede |
|---|---|---|
| Maç sonucu | Orta (favori %65 kazanır) | Çok rastgele = adaletsiz, çok deterministik = sıkıcı |
| Scout raporu | Yüksek | Ana keşif heyecanı burada |
| Kart hangi kart gelecek | Orta-yüksek | Sürpriz ama bağlamlı |
| Kart sonucu | Düşük-orta | Seçimin sonucu tahmin edilebilir olmalı (faillik hissi) |
| Ekonomi | Düşük | Plan yapılabilmeli |
| Oyuncu gelişimi | Orta | Sürpriz patlamalar hikâye yaratır |

> **Altın kural:** Oyuncunun **girdi**si deterministik sonuç vermeli (adalet), **dünya**nın girdisi rastgele olmalı (heyecan).

#### 💎 AŞAMA 4: YATIRIM (Investment)

Yatırım, bir sonraki döngüyü daha değerli yapan şeydir. Oyuncu ne kadar çok yatırırsa o kadar zor bırakır (IKEA etkisi + sunk cost — ama etik sınırda, §17.7).

| Yatırım tipi | Oyunda karşılığı | Sonraki döngüye etkisi |
|---|---|---|
| **Zaman** | Oynanan sezonlar | Kariyer tarihi, rekorlar |
| **Emek** | Kadro kurma, taktik ayarı | "Bu takımı ben yaptım" |
| **Veri** | Kulüp adı, arma, forma, oyuncu isimleri | Kişiselleştirme |
| **Sosyal sermaye** | Lig sıralaması, arkadaşlar | Kaybetmesi zor statü |
| **Beceri** | Öğrenilen sistemler | Yeniden başlama maliyeti |
| **Duygusal** | Akademiden çıkardığın çocuk | Değiştirilemez bağ |
| **Para** | IAP | — (asla tek bağ olmamalı) |

**En güçlü yatırım: Akademi oyuncusu.** 16 yaşında keşfettiğin, geliştirdiğin, ilk golünü attığında sevindiğin oyuncu — 20 sezon sonra kaptanın olur. Bu bağ satın alınamaz ve rakip oyunda yoktur.

**Uygulama direktifi:** Akademi oyuncularının **isimleri prosedürel ama yüzleri, gelişim grafikleri ve kart anları kalıcı olarak kaydedilir**. Menajer profilinde "Yetiştirdiklerin" bölümü.

### 17.3 Retention Mimarisi — Gün Gün Plan

#### 📅 D0 (İlk gün) — Hedef: FTUE tamamlama %72

| Saat | Olay | Psikolojik amaç |
|---|---|---|
| 0:00 | FTUE (§7.2) | Merak → sahiplik → ilk zafer |
| +30 dk | İlk push (izin verildiyse): "Maç 2 saat sonra." | İlk geri dönüş provası |
| +3 sa | 2. maç penceresi | Ritim kurma |
| +6 sa | Günlük görev tamamlanabilir | Tamamlama tatmini |
| Gün sonu | "Bugünün özeti" ekranı + yarın önizlemesi | Peak-end + gelecek vaadi |

**D0'da bilinçli olarak YOK:** Mağaza rozeti, teklif pop-up'ı, abonelik, reklam. **İlk 24 saat tamamen oyun.**

#### 📅 D1 — Hedef: %45–50 dönüş

| Kanca | Mekanik |
|---|---|
| **Bekleyen ödül** | Gece boyunca birikmiş idle gelir (offline earnings, maks 8 sa) |
| **Yarım kalan iş** | Uykudan önce başlattığı inşaat bitmiş |
| **Push (sabah 09:15)** | "Antrenman sahası hazır. Bugün 3 maç var." |
| **Yeni sistem açılışı** | Sözleşme yönetimi + Mağaza açılır (yenilik) |
| **Zincir başlangıcı** | İlk hikâye zinciri kartı |
| **Başlangıç Paketi** | D2'de gösterilir, D1'de değil |

**D1 kayıp analizi:** D1'de dönmeyen oyuncuların %70'i FTUE'yi bitirmemiştir. Yani **D1 problemi aslında D0 problemidir.** Ölçüm: `ftue_complete` → `day1_return` korelasyonu.

#### 📅 D2–D3 — Hedef: D3 %32

| Kanca | Mekanik |
|---|---|
| Alışkanlık kurma | 3 maç penceresi ritmi oturur |
| Sponsorluk + Bilet fiyatlama açılır | Yeni derinlik |
| İlk sakatlık krizi (senaryolu) | İlk gerçek zorluk |
| Başlangıç Paketi teklifi | İlk monetizasyon teması |
| İlk scout keşfi tamamlanır | En güçlü değişken ödül devreye girer |

#### 📅 D4–D6 — Hedef: D5 %27

| Kanca | Mekanik |
|---|---|
| Terfi yarışı ısınır | Hedef netleşir (goal gradient) |
| Yönetim güveni ilk kez sallanır | Gerilim |
| 2–3 aktif zincir | Hikâye bağı |
| Stadyum Sv.2 | İlk büyük görsel değişim |

#### 📅 **D7 — EN KRİTİK GÜN** — Hedef: %22–25

D7 = ilk sezonun finali. Bu gün oyuncunun **tam bir deneyim döngüsü tamamlaması** planlandı.

```
Pazar 09:00 push : "Son gün. 3 maç, 2 puan fark."
Pazar boyunca   : Son 6 maç
Pazar 20:00     : SEZON FİNALİ
                  → Terfi veya kalma veya düşme
                  → Yıllık ödüller, konfeti veya sessizlik
                  → Kulüp tarihine ilk kayıt
                  → Sezon 2 önizlemesi: "Akademi açılıyor"
                  → Sezon Bileti ilk kez teklif edilir
```

**Neden bu gün her şeyi belirler:**
- Peak-end rule: Deneyimin **zirvesi** ve **sonu** hatırlanır. Sezon finali her ikisini de kontrol ediyor.
- Tamamlama tatmini: "Bir sezon bitirdim" → kimlik değişimi ("ben bu oyunu oynuyorum")
- Yeni içerik vaadi: Akademi açılışı = "daha görecek şey var"
- İlk ödeme anı: Duygusal zirvede, baskısız teklif

**Ölçüm:** `season_complete{season:1}` eventini tamamlayan oyuncuların D14 retention'ı, tamamlamayanların **2.6 katı** olmalı. Değilse sezon finali sunumu yeniden tasarlanır.

#### 📅 D8–D13 — "Tehlikeli boşluk"

Yeniliğin bittiği, alışkanlığın henüz oturmadığı bölge. En yüksek terk oranı burada.

| Karşı önlem | Mekanik |
|---|---|
| Sezon 2 = Akademi açılır | Tamamen yeni sistem |
| İlk akademi genci | Duygusal yatırım başlar |
| Rekabet Ligi açılır (S2 sonu) | Sosyal katman |
| Zorluk artışı | Lig 18'de rakipler ciddi |
| Kart zinciri yoğunluğu ↑ | Hikâye derinliği |
| **"Efsane Anı" sistemi** | 90. dakika golü gibi anlar özel kaydedilir ve paylaşılabilir |

#### 📅 **D14** — Hedef: %17

Sosyal kanca burada devreye girmeli. Yalnız oynayan oyuncu D14'te gider.
- Rekabet Ligi ilk terfi/düşme
- Arkadaş ekleme + arkadaş kulübünü ziyaret
- 🔵 Menajer Ligi daveti

#### 📅 **D21** — Hedef: %13–15

3 sezon tamamlandı. Oyuncu artık "kariyer" hissinde.

| Kanca | Mekanik |
|---|---|
| Uluslararası scout açılır | Dünya genişliyor |
| İlk 4★ oyuncu ulaşılabilir | Güç fantezisi |
| Menajer Sv.20 → güçlü yetenekler | RPG derinliği |
| İlk gerçek görevden alınma riski | Gerilim zirvesi |
| Kulüp tarihinde 3 sezon | Geriye bakma tatmini |
| **Sadakat ödülü:** 21 gün rozeti + özel arma | Statü |

> **D21'in özel önemi:** Alışkanlık oluşumu literatüründe davranışın otomatikleşmesi ortalama 20–25 gün sürer (kişiden kişiye 18–250 gün değişir). D21'i geçen oyuncunun D90 retention'ı dramatik biçimde yükselir. Bu yüzden D14–D21 arasına **en yoğun içeriği** koyuyoruz.

#### 📅 **D30** — Hedef: %10–12

| Kanca | Mekanik |
|---|---|
| 4+ sezon, muhtemelen Lig 15–16 | Somut ilerleme kanıtı |
| Kıta Kupası (Lig ≤8'e yakınsa) | Yeni turnuva formatı |
| İlk "efsane" oyuncu (100 maç) | Duygusal doruk |
| Aylık abonelik teklifi | Uzun vadeli ödeme |
| Sezon teması değişimi | Live-ops tazeliği |
| **30 Gün Rozeti + kariyer kartı paylaşımı** | Statü + organik pazarlama |

#### 📅 D31–D90 — Live-Ops Dönemi

Bu noktadan sonra retention **içerik güncelleme hızına** bağlıdır.
- Her sezon (7 gün) yeni tema + yeni kart seti
- Aylık büyük özellik güncellemesi
- Sezonluk etkinlikler (§28)
- Topluluk yarışmaları

#### 📅 D90+ — Prestij Dönemi
- Hanedan sistemi
- Yeni kulüplerle yeni meydan okumalar
- Topluluk lideri statüsü, 🔵 kulüp kurma (guild)

### 17.4 Retention Kanca Tablosu (Özet)

| Gün | Retention hedefi | Ana kanca | Yedek kanca | Riskli mi? |
|---|---|---|---|---|
| D1 | %47 | Idle gelir + inşaat bitti | Push + yeni sistem | 🔴 Kritik |
| D3 | %32 | Scout keşfi | Zincir | 🟠 |
| D7 | %23 | **Sezon finali** | Terfi | 🔴 Kritik |
| D14 | %17 | Sosyal (Rekabet Ligi) | Akademi genci | 🔴 Kritik |
| D21 | %14 | Kariyer hissi + sadakat ödülü | Uluslararası scout | 🟠 |
| D30 | %11 | Efsane oyuncu + kupa | Aylık abonelik | 🟠 |
| D60 | %7.5 | Live-ops etkinlikleri | Yeni içerik | 🟡 |
| D90 | %6.5 | Prestij/Hanedan | Topluluk | 🟡 |
| D180 | %4.9 | Kimlik ("ben bu oyunu oynarım") | — | 🟡 |

### 17.5 Kullanılan Psikolojik Prensipler Kataloğu

Her prensip, **oyundaki somut mekaniğe** bağlı. Prensip tek başına eklenmez.

| # | Prensip | Ne yapar | Bizdeki uygulama | Etik notu |
|---|---|---|---|---|
| 1 | **Zeigarnik Etkisi** | Yarım kalan iş hatırda kalır | Kart zincirleri, inşaat, scout raporu (§6.5) | ✅ Güvenli |
| 2 | **Loss Aversion** | Kayıp, kazançtan ~2× güçlü hissedilir | Görevden alınma, sözleşme bitişi, küme düşme | ⚠ Ceza adil ve öngörülebilir olmalı |
| 3 | **Endowment Effect** | Sahip olduğun şeyi fazla değerli görürsün | Kulüp kişiselleştirme, akademi oyuncuları | ✅ |
| 4 | **IKEA Effect** | Kendi kurduğun şeyi daha çok seversin | Pazarlık mini-oyunu, taktik ayarı, tesis inşası | ✅ |
| 5 | **Goal Gradient** | Hedefe yaklaştıkça çaba artar | İnşaatın son 5 dk bedava, sezon bileti son kademeler, terfi yarışı | ✅ |
| 6 | **Endowed Progress** | Boş başlamak yerine "önceden ilerleme" | Günlük görevlerin 1'i başta tamam, sezon bileti kademe 1 hediye | ✅ |
| 7 | **Variable Ratio Reward** | Değişken ödül en güçlü pekiştirici | Scout raporu, maç sonucu, kart havuzu | ⚠ Parayla tetiklenmiyor |
| 8 | **Near Miss** | Kıl payı kaçırma motivasyonu artırır | Görevden alınma eşiğinde toparlanma, play-off kaçırma | ⚠ Yapay near-miss YOK, sadece doğal |
| 9 | **Sunk Cost** | Yatırım yaptığın şeyi bırakamazsın | Kariyer geçmişi, kulüp tarihi | ⚠ Bunu ASLA teklif metninde kullanma |
| 10 | **Peak-End Rule** | Deneyimin zirvesi ve sonu hatırlanır | Sezon finali sunumu, seans kapanış ekranı | ✅ |
| 11 | **Fresh Start Effect** | Yeni başlangıçlar motivasyon yaratır | Pazartesi sezon başı, prestij, yeni kulüp | ✅ |
| 12 | **Curiosity Gap** | Bilgi boşluğu merakı tetikler | Gizli potansiyel, kilitli perk seçenekleri, "?" scout raporu | ✅ |
| 13 | **Social Proof** | Başkalarının davranışı yönlendirir | "Menajerlerin %68'i bu oyuncuyu izliyor", lig sıralaması | ⚠ Rakamlar gerçek olmalı |
| 14 | **Commitment & Consistency** | Verilen söz tutulmaya çalışılır | Oyuncuya rol vaadi, başkana sezon hedefi taahhüdü | ✅ |
| 15 | **Autonomy (SDT)** | Seçim özgürlüğü içsel motivasyon yaratır | Her kartta gerçek seçenek, oynama tarzı özgürlüğü, hızlı sim opsiyonu | ✅ Temel |
| 16 | **Competence (SDT)** | Yetkinlik hissi | Zorluk eğrisi, yetenek ağacı, ustalaşma | ✅ Temel |
| 17 | **Relatedness (SDT)** | Bağ kurma | NPC'ler, soyunma odası, taraftarlar, arkadaşlar | ✅ Temel |
| 18 | **Flow (Csikszentmihalyi)** | Zorluk = beceri dengesi | Lig kademelerinin kademeli zorluğu | ✅ |
| 19 | **Anchoring** | İlk gördüğün sayı referans olur | Fiyat paketlerinde büyük paket önce | ⚠ Yanıltıcı olmamalı |
| 20 | **Scarcity / FOMO** | Kıtlık değeri artırır | Transfer deadline, sezon teması, sınırlı kart | ⚠ Sahte aciliyet YOK |
| 21 | **Reciprocity** | Verilene karşılık verme | Bedava hediyeler, telafi ödülleri | ✅ |
| 22 | **Von Restorff (İzolasyon)** | Farklı olan hatırlanır | Efsane oyuncu kartı farklı tasarımda | ✅ |
| 23 | **Progress Bar Illusion** | Görünür ilerleme tatmin eder | Menajer XP, tesis, sezon bileti, kulüp seviyesi | ✅ |
| 24 | **Collection Instinct** | Set tamamlama dürtüsü | Rozetler, efsane kadro, kulüp tarihi | ✅ |
| 25 | **Habit Loop (Duhigg)** | İşaret → Rutin → Ödül | Maç penceresi (işaret) → seans (rutin) → sonuç (ödül) | ✅ |
| 26 | **Fogg Behavior Model** | B = MAP | §17.2 Aşama 2 | ✅ |
| 27 | **Identity-Based Habit** | "Ben böyle biriyim" | "Menajer" kimliği, kariyer sayfası, unvanlar | ✅ En güçlü uzun vade |
| 28 | **Narrative Transportation** | Hikâyeye kapılma | Kart zincirleri, tekrar eden NPC'ler | ✅ |
| 29 | **Effort Justification** | Zor kazanılan değerlidir | Zorlu terfi, pazarlıkla alınan oyuncu | ✅ |
| 30 | **Temporal Landmarks** | Takvim işaretleri davranış değiştirir | Pazartesi sezon başı, Pazar final | ✅ |

### 17.6 Alışkanlık Döngüsü — Somut Tasarım

```
İŞARET (Cue)              RUTİN (Routine)           ÖDÜL (Reward)
────────────────          ────────────────          ────────────────
Sabah kahvesi        →    Sabah maçı + 2 kart   →   Skor + gelişme
Öğle arası           →    Öğle maçı + transfer  →   Yeni oyuncu
Akşam kanepe         →    Akşam maçı + inşa     →   Sıralama yükselişi
Pazar akşamı         →    SEZON FİNALİ          →   Terfi/kupa
```

**Uygulama:** Push zamanlaması oyuncunun **gerçek davranış verisinden** öğrenilir. `session_start` saatleri toplanır, kişisel pencere çıkarılır, bildirimler o pencereye kaydırılır (§18.4).

### 17.7 Etik Sınırlar — Kırmızı Çizgiler

Bu oyun psikolojik prensipleri **oyunu daha iyi yapmak için** kullanır, oyuncuyu sömürmek için değil. Bir prensip aşağıdakilerden birine yol açıyorsa kullanılmaz:

| ❌ Yapmayacaklarımız | Neden |
|---|---|
| Bırakmayı zorlaştıran karanlık desenler (gizli çıkış, sahte X butonu) | Güven yıkımı, mağaza politikası ihlali |
| Uyku saatinde bildirim (kişisel pencere dışı) | Sağlık, öfke |
| Kaybettikten hemen sonra ödeme teklifi | Duygusal sömürü |
| Sahte sayaç ("SON 3 DAKİKA" ama aslında değil) | Aldatma |
| Sahte sosyal kanıt ("500 kişi bunu aldı" — uydurma) | Aldatma |
| Sunk cost'u metinde kullanma ("47 gün emeğini boşa harcama!") | Manipülasyon |
| Zorunlu günlük giriş serisi cezası (kaçırınca sıfırlama) | Anksiyete üretimi |
| Rastgele kutu satışı | Kumar benzeri, hukuki risk |
| 13 yaş altı hedefleme | Yasal (COPPA/KVKK) |
| Sonsuz kaydırma / bitmeyen içerik akışı | Sağlıksız kullanım |

**Pozitif yükümlülükler:**
- ✅ Oyun içi **oynama süresi göstergesi** (ayarlarda, opsiyonel)
- ✅ 🔵 "Mola hatırlatıcısı" (90 dakikada bir, kapatılabilir)
- ✅ Harcama özeti ekranı (bu ay ne kadar harcadın)
- ✅ Ebeveyn kontrolü bilgilendirmesi
- ✅ Tüm bildirimler tek yerden kapatılabilir, granüler
- ✅ Hesap ve veri silme talebi 1 ekranda

> **Kurucu direktifi:** "Bir mekaniği açıklarken utanıyorsak, o mekaniği koymuyoruz."

### 17.8 Retention Ölçüm ve Müdahale Protokolü

| Sinyal | Eşik | Müdahale |
|---|---|---|
| D1 < %38 | 3 gün üst üste | FTUE funnel analizi → en büyük düşüş adımını yeniden tasarla |
| D7 < %16 | Haftalık | Sezon finali sunumu + D3–D6 içerik yoğunluğu |
| D14 < %12 | Haftalık | Sosyal özellikleri öne al, Rekabet Ligi açılışını erkene çek |
| D30 < %7 | Aylık | Live-ops kadansı artır, yeni içerik |
| Seans/gün < 2.5 | Haftalık | Push zamanlama optimizasyonu, maç penceresi ayarı |
| Ortalama seans < 3 dk | Haftalık | Seans içi içerik ekle (kart sayısı, hedef netliği) |
| `manager_sacked` > %22 (30 gün) | Haftalık | `board_decay_rate` düşür |
| `manager_sacked` < %7 | Haftalık | Gerilim eksik, decay artır |
| Uninstall D1 > %30 | Günlük | Kritik: performans/crash kontrolü, FTUE |

---

## 18. BİLDİRİM, CRM VE WIN-BACK

### 18.1 Bildirim Felsefesi
> **Her bildirim bir vaattir.** Açtığında vaat edilen değer yoksa, bir sonrakini kapatır.

**Kurallar:**
- Günde maks **3 bildirim** (kritik durumlar hariç, maks 4)
- Her bildirim **spesifik bilgi** taşır — "Oyuna dön!" gibi boş çağrı yasak
- Kişisel aktif saat penceresi dışında gönderilmez
- Sessiz saatler: 23:00–08:00 (kullanıcının yerel saati) — istisna yok
- 3 gün üst üste açılmayan bildirim tipi otomatik durdurulur (adaptive frequency)

### 18.2 Bildirim Kataloğu

| # | Tetik | Zamanlama | Başlık | Gövde | Öncelik |
|---|---|---|---|---|---|
| 1 | Maç penceresi | Pencere +15 dk | ⚽ Maç günü | "Demirspor deplasmanı. Kadro hâlâ dizilmedi." | Yüksek |
| 2 | İnşaat bitti | Anında | 🏗️ Hazır | "Antrenman Sahası Sv.3 tamamlandı." | Orta |
| 3 | Scout raporu | Anında | 🔍 Scout aradı | "'Bunu görmen lazım hocam.'" | Yüksek |
| 4 | Transfer teklifi | Anında | 💰 Teklif var | "Arslan Demir için ₣180.000." | Yüksek |
| 5 | Sözleşme uyarısı | Sezon g.4 | 📝 Sözleşme | "Kaptanın 1 sezonu kaldı." | Orta |
| 6 | Zincir devamı | 6 sa gecikmeli | 💬 Bekliyorlar | "Çocuk soyunma odasında seni bekliyor." | Orta |
| 7 | Sezon finali | Pazar 18:00 | 🏆 Son gün | "3 maç kaldı. Terfi 2 puan uzakta." | Çok yüksek |
| 8 | Sezon başı | Pazartesi 09:00 | 🆕 Sezon 5 | "Başkanın yeni hedefi hazır." | Yüksek |
| 9 | Yönetim uyarısı | Anında | ⚠️ Başkan çağırdı | "Odasına gelmeni istiyor." | Çok yüksek |
| 10 | Rakip geçti | Sıralama değişimi | 📉 Geçildin | "Adana Şimşek 2 puan önde." | Düşük |
| 11 | Sakat döndü | Anında | 🩹 Hazır | "Emre iyileşti, kadroya dönebilir." | Düşük |
| 12 | Günlük ödül | Kişisel pencere | 🎁 Günlük | "Bugünün ödülü bekliyor." | Düşük |
| 13 | Akademi | Sezon başı | 🌱 Akademi | "Yeni bir çocuk dikkat çekiyor." | Orta |
| 14 | Sponsor teklifi | Anında | 🤝 Sponsor | "Yeni bir forma sponsoru masada." | Orta |

### 18.3 Push İzni Stratejisi

**Sorun:** iOS'ta doğrudan sistem izni istenirse kabul oranı %35–45'te kalır ve reddedilirse geri dönüş çok zor.

**Çözüm — Ön izin (soft ask):**
```
FTUE 8:00'de, bağlam içinde:

┌────────────────────────────────────────┐
│  Başkan Recep Vardar:                  │
│  "Maç saatlerini kaçırma. Sana         │
│   haber vereyim mi?"                   │
│                                        │
│  [ Haber ver ]   [ Gerek yok ]         │
└────────────────────────────────────────┘

"Haber ver" → sistem izni gösterilir (kabul %78+)
"Gerek yok" → sistem izni HİÇ gösterilmez, D3'te tekrar sorulur
```
Bu yöntemle sistem izni sadece "evet" diyeceklere gösterilir → sistemde kalıcı "reddedildi" durumu oluşmaz.

### 18.4 Kişiselleştirilmiş Zamanlama

```dart
// Her kullanıcı için aktif saat penceresi öğrenilir
List<int> activeHours = sessionStartTimes
    .map((t) => t.hour)
    .fold(<int,int>{}, count)
    .entries.sorted(byCount).take(3)
    .map((e) => e.key).toList();

// Bildirimler bu saatlere ±30 dk içinde planlanır
// Yeterli veri yoksa (< 5 seans) varsayılan: 09:00, 13:00, 20:00
```

### 18.5 Lifecycle CRM Kampanyaları

| Segment | Tanım | Kampanya | Kanal |
|---|---|---|---|
| **Yeni** | D0–D2 | Onboarding ipuçları, ilk sezon rehberi | In-app |
| **Aktif** | 7 gün içinde ≥4 seans | Normal döngü | Push |
| **Sallanan** | 3–6 gün yok | "Kulübün seni bekliyor" + somut durum | Push + e-posta |
| **Uykuda** | 7–20 gün yok | Win-back paketi: ₣ + 🏅 + "Yokluğunda neler oldu" özeti | Push |
| **Kayıp** | 21+ gün yok | Büyük dönüş teklifi + yeni içerik duyurusu | Push (aylık maks 1) + reengagement ads |
| **Ödeyen** | ≥1 IAP | VIP destek, erken erişim, teşekkür hediyesi | In-app |
| **Ödemeyi bırakan** | 30 gün ödeme yok | Kişiselleştirilmiş değer teklifi | In-app |

### 18.6 Win-Back Ekranı (Dönüş Deneyimi)

7+ gün sonra dönen oyuncu **asla cezalandırılmış hissetmemeli**:

```
┌─── HOŞ GELDİN HOCAM ────────────────────┐
│  9 gün yoktun. Kulüpte neler oldu:      │
│                                         │
│  · Asistan menajer 12 maç yönetti       │
│    (5 G, 3 B, 4 M) — Lig 8. sıra        │
│  · Arslan Demir 6 gol attı              │
│  · Stadyum Sv.2 tamamlandı              │
│  · Akademiden bir çocuk çıktı: Kaan, 16 │
│  · Yönetim güveni biraz düştü (−8)      │
│                                         │
│  Dönüş hediyesi: ₣45.000 + 150🏅 + 3🔍   │
│                                         │
│  [ İşe koyul ]                          │
└─────────────────────────────────────────┘
```

**Kritik:** Kulüp kaybolmamış, biri yönetmiş. Bu "dünya sensiz de yaşadı" hissi (gerçekçilik) + "geri döndüm, düzelteceğim" motivasyonu verir.

### 18.7 Bildirim Performans İzleme

| Metrik | Hedef | Aksiyon eşiği |
|---|---|---|
| Push opt-in oranı (iOS) | ≥ %55 | < %45 → soft ask metni A/B |
| Push açılma oranı | ≥ %8 | < %4 → metin/zamanlama revizyonu |
| Push sonrası seans süresi | ≥ organik seansın %80'i | Düşükse vaat/gerçek uyuşmuyor |
| Bildirim kapatma oranı | ≤ %6/ay | > %10 → frekans düşür |
| Win-back dönüş oranı | ≥ %11 | < %6 → teklif değeri artır |

---
---

# BÖLÜM IV — ÜRETİM

## 19. TEKNİK MİMARİ (FLUTTER)

### 19.1 Teknoloji Yığını

| Katman | Seçim | Gerekçe | Alternatif |
|---|---|---|---|
| Framework | **Flutter 3.3x (stable)** | Tek kod tabanı, güçlü animasyon, Skia/Impeller performansı | React Native (daha zayıf oyun-benzeri UI) |
| Dil | **Dart 3.x** (sound null safety) | Sim motoru saf Dart → sunucuda da çalışır | — |
| State Management | **Riverpod 2.x** | Derleme zamanı güvenliği, test edilebilirlik, global erişim | Bloc (daha çok boilerplate) |
| Navigasyon | **go_router** | Deep link, tip güvenli rota | Navigator 2.0 elle |
| Yerel DB | **Isar 3** veya **Drift** | Isar: hızlı NoSQL, oyun state'e uygun. Drift: SQL, karmaşık sorgu | Hive (daha az özellik) |
| Model üretimi | **freezed** + **json_serializable** | Immutable model, copyWith, union | — |
| Animasyon | **flutter_animate** + **Rive** | Rive: karmaşık karakter/kutlama animasyonu, küçük boyut | Lottie (daha büyük) |
| Maç görselleştirme | **CustomPainter** (saf Flutter) | 60fps, sıfır bağımlılık, tam kontrol | Flame (gereksiz ağır) |
| Backend | **Firebase** (çekirdek) + **Cloud Run/Dart Frog** (sim doğrulama) | Hızlı başlangıç + custom logic esnekliği | Supabase (PostgreSQL sevenlere) |
| Analytics | **Firebase Analytics** + **Amplitude** veya **Mixpanel** | Firebase ücretsiz temel, Amplitude derin funnel | Adjust/AppsFlyer (attribution için ayrıca) |
| Crash | **Firebase Crashlytics** | Standart | Sentry |
| Remote Config | **Firebase Remote Config** | Denge ayarı, A/B, feature flag | — |
| Push | **Firebase Cloud Messaging** | | OneSignal |
| IAP | **in_app_purchase** + sunucu doğrulama | Resmi paket | RevenueCat (abonelik yönetimi kolaylığı — **önerilir**) |
| Reklam | **AppLovin MAX** mediation | En iyi eCPM mediation | AdMob |
| Attribution | **AppsFlyer** veya **Adjust** | UA ölçümü için zorunlu | Firebase (yetersiz) |
| CI/CD | **GitHub Actions** + **Fastlane** + **Codemagic** | Otomatik build/test/deploy | Bitrise |

### 19.2 Klasör Yapısı

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    // MaterialApp, tema, router bağlama
│   ├── router.dart                 // go_router rotaları
│   ├── theme/
│   │   ├── colors.dart             // §2.5 renk tokenları
│   │   ├── typography.dart         // §2.6 tip ölçeği
│   │   ├── spacing.dart            // 4pt grid
│   │   └── app_theme.dart
│   └── bootstrap.dart              // DI, Firebase init, hata yakalama
│
├── core/
│   ├── rng/
│   │   ├── deterministic_rng.dart  // Xorshift128+ (platform bağımsız)
│   │   └── weighted_pick.dart
│   ├── time/
│   │   ├── game_clock.dart         // sezon/gün/pencere hesabı
│   │   └── server_time.dart        // saat manipülasyonu koruması
│   ├── result.dart                 // Result<T, E>
│   ├── extensions/
│   ├── errors/
│   └── logging/
│
├── domain/                          // SAF DART — Flutter'a bağımlılık YOK
│   ├── entities/
│   │   ├── player.dart
│   │   ├── club.dart
│   │   ├── manager.dart
│   │   ├── facility.dart
│   │   ├── contract.dart
│   │   ├── league.dart
│   │   ├── fixture.dart
│   │   ├── card.dart
│   │   ├── meter.dart
│   │   └── game_state.dart
│   ├── sim/                        // ⭐ MAÇ MOTORU (sunucuda da çalışır)
│   │   ├── match_engine.dart
│   │   ├── match_events.dart
│   │   ├── team_strength.dart
│   │   ├── xg_model.dart
│   │   ├── tactic_resolver.dart
│   │   └── commentary_generator.dart
│   ├── cards/
│   │   ├── card_selector.dart      // §12.4 ağırlıklı seçim
│   │   ├── card_effects.dart       // effect DSL yorumlayıcısı
│   │   └── chain_manager.dart
│   ├── economy/
│   │   ├── income_calculator.dart
│   │   ├── expense_calculator.dart
│   │   ├── transfer_valuation.dart
│   │   └── negotiation_model.dart
│   ├── progression/
│   │   ├── player_growth.dart
│   │   ├── manager_xp.dart
│   │   ├── club_level.dart
│   │   └── season_transition.dart
│   └── generation/                 // prosedürel içerik
│       ├── player_generator.dart
│       ├── club_generator.dart
│       ├── name_pools.dart
│       └── face_composer.dart
│
├── data/
│   ├── local/
│   │   ├── isar_schemas.dart
│   │   ├── save_repository.dart
│   │   └── migrations/
│   ├── remote/
│   │   ├── api_client.dart
│   │   ├── league_sync_service.dart
│   │   ├── iap_service.dart
│   │   └── remote_config_service.dart
│   ├── assets/
│   │   ├── card_loader.dart        // JSON kart yükleyici
│   │   └── balance_loader.dart
│   └── repositories/               // domain interface implementasyonları
│
├── application/                    // Riverpod provider + use case
│   ├── providers/
│   │   ├── game_state_provider.dart
│   │   ├── match_provider.dart
│   │   ├── card_provider.dart
│   │   ├── transfer_provider.dart
│   │   └── facility_provider.dart
│   ├── services/
│   │   ├── session_service.dart    // seans yönetimi, SessionEndGuard
│   │   ├── notification_service.dart
│   │   ├── offer_engine.dart
│   │   └── analytics_service.dart
│   └── usecases/
│
├── presentation/
│   ├── screens/
│   │   ├── ftue/
│   │   ├── office/                 // ana ekran
│   │   ├── squad/
│   │   ├── match/
│   │   ├── transfer/
│   │   ├── facilities/
│   │   ├── cards/
│   │   ├── manager/
│   │   ├── league/
│   │   ├── shop/
│   │   └── settings/
│   ├── widgets/
│   │   ├── meters/
│   │   ├── player_card/
│   │   ├── decision_card/
│   │   ├── pitch_painter/          // CustomPainter maç görselleştirme
│   │   └── common/
│   └── animations/
│
└── l10n/
    ├── app_tr.arb
    ├── app_en.arb
    └── ...
```

**Mimari kural:** `domain/` katmanı **hiçbir Flutter paketine bağımlı olamaz** (`import 'package:flutter/...'` yasak). Bu sayede:
1. Aynı kod sunucuda (Dart Frog / Cloud Run) çalışır → hile doğrulama
2. Unit test çok hızlı (widget test gerekmez)
3. Toplu simülasyon araçları (denge testi) CLI'dan çalışır

### 19.3 Sim Motoru — Referans İskelet

```dart
// domain/sim/match_engine.dart
// SAF DART. Deterministik. Yan etkisiz.

class MatchEngine {
  final DeterministicRng _rng;
  final BalanceConfig _cfg;

  MatchEngine(int seed, this._cfg) : _rng = DeterministicRng(seed);

  MatchResult simulate(MatchSetup setup) {
    final home = TeamStrength.from(setup.home, isHome: true, cfg: _cfg);
    final away = TeamStrength.from(setup.away, isHome: false, cfg: _cfg);

    final events = <MatchEvent>[];
    var homeGoals = 0, awayGoals = 0;
    final fitness = <String, double>{ for (final p in setup.allPlayers) p.id: p.fitness.toDouble() };

    for (var minute = 1; minute <= 90; minute++) {
      final possHome = _possession(home, away);
      final attacking = _rng.next() < possHome ? home : away;
      final defending = identical(attacking, home) ? away : home;

      // yorgunluk
      _decayFitness(fitness, minute, attacking, defending);

      final attackChance = _attackChance(attacking, minute, fitness);
      if (_rng.next() < attackChance) {
        final shot = _createShot(attacking, defending, minute);
        events.add(shot.toEvent());
        if (shot.isGoal) {
          identical(attacking, home) ? homeGoals++ : awayGoals++;
          events.add(MatchEvent.goal(minute, shot.shooter, shot.assister,
              homeGoals, awayGoals));
        }
      }

      // yan olaylar
      _maybeFoul(events, minute, attacking, defending);
      _maybeInjury(events, minute, fitness, setup);

      // canlı an tetikleyicisi (UI tarafından tüketilir)
      final moment = _detectKeyMoment(minute, homeGoals, awayGoals, fitness, setup);
      if (moment != null) events.add(moment);
    }

    return MatchResult(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      events: events,
      ratings: _computeRatings(events, setup),
      seed: _rng.seed,
      engineVersion: kEngineVersion,   // sunucu doğrulaması için
    );
  }
}
```

**Canlı Anlar entegrasyonu:** Motor önce **tüm maçı simüle eder**, sonra UI bu olayları zaman içinde oynatır. Oyuncu bir "key moment"ta karar verirse, o noktadan sonrası **yeniden simüle edilir** (kararın etkisi girdi olarak eklenir, seed korunur). Bu, hem determinizmi hem etkileşimi sağlar.

```dart
MatchResult resimulateFrom(MatchResult original, int minute, TacticChange change) {
  final setup = original.setup.applyAt(minute, change);
  final engine = MatchEngine(original.seed, _cfg);
  return engine.simulateFrom(setup, fromMinute: minute, priorEvents: original.eventsBefore(minute));
}
```

### 19.4 Deterministik RNG

```dart
// core/rng/deterministic_rng.dart
// dart:math Random'a GÜVENME — implementasyonu platform/versiyon değişebilir.

class DeterministicRng {
  int _s0, _s1;
  final int seed;

  DeterministicRng(this.seed)
      : _s0 = _splitMix64(seed),
        _s1 = _splitMix64(seed ^ 0x9E3779B97F4A7C15);

  /// [0,1) aralığında double
  double next() {
    // xorshift128+
    var s1 = _s0;
    final s0 = _s1;
    _s0 = s0;
    s1 ^= (s1 << 23) & _mask64;
    s1 ^= (s1 >>> 17);
    s1 ^= s0;
    s1 ^= (s0 >>> 26);
    _s1 = s1;
    final result = (_s0 + _s1) & _mask64;
    return (result >>> 11) / (1 << 53);
  }

  int nextInt(int max) => (next() * max).floor();

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  T weightedPick<T>(List<T> items, double Function(T) weightOf) {
    final total = items.fold<double>(0, (a, b) => a + weightOf(b));
    var r = next() * total;
    for (final it in items) {
      r -= weightOf(it);
      if (r <= 0) return it;
    }
    return items.last;
  }

  static const _mask64 = 0xFFFFFFFFFFFFFFFF;
  static int _splitMix64(int x) { /* ... */ }
}
```

### 19.5 State Yönetimi (Riverpod Deseni)

```dart
// application/providers/game_state_provider.dart

@riverpod
class GameStateNotifier extends _$GameStateNotifier {
  @override
  Future<GameState> build() async {
    final saved = await ref.read(saveRepositoryProvider).load();
    return saved ?? GameState.newGame();
  }

  Future<void> applyCardChoice(GameCard card, CardOption option) async {
    final current = await future;
    final next = CardEffects.apply(current, card, option);

    state = AsyncData(next);
    unawaited(ref.read(saveRepositoryProvider).save(next));      // debounce'lı
    ref.read(analyticsProvider).logCardChoice(card, option, next);
    ref.read(sessionServiceProvider).registerAction();
  }
}
```

**Kayıt (save) stratejisi:**
- Her anlamlı aksiyondan sonra **debounce 400ms** ile yerel kayıt
- Uygulama arka plana geçince **anında** kayıt (`AppLifecycleState.paused`)
- Bulut yedekleme: 5 dakikada bir + her sezon sonu (delta olarak)
- Kayıt formatı: Isar nesneleri + versiyonlu şema
- **Migration:** Her şema değişikliğinde `migrations/vN_to_vN1.dart`, geriye dönük 3 sürüm desteklenir

### 19.6 Backend Mimarisi

```
┌───────────────┐        ┌─────────────────────────────────┐
│   İSTEMCİ     │        │          SUNUCU                 │
│   (Flutter)   │        │                                 │
│               │        │  Firebase Auth (anonim + link)  │
│  Yerel Isar   │◄──────►│  Firestore                      │
│  (tam state)  │  sync  │   ├─ users/{uid}                │
│               │        │   ├─ leagues/{leagueId}         │
│  Sim motoru   │        │   ├─ competitive/{seasonId}     │
│  (offline)    │        │   └─ leaderboards/              │
│               │        │                                 │
│               │        │  Cloud Functions / Cloud Run    │
│               │        │   ├─ validateMatch()  ⭐ aynı   │
│               │        │   │   Dart sim motoru           │
│               │        │   ├─ verifyPurchase()           │
│               │        │   ├─ seasonRollover() (cron)    │
│               │        │   └─ leaderboardUpdate()        │
│               │        │                                 │
│               │        │  Remote Config (denge + A/B)    │
│               │        │  FCM (push)                     │
│               │        │  Analytics + BigQuery export    │
└───────────────┘        └─────────────────────────────────┘
```

**Offline-first prensibi:**
1. Oyun **tamamen offline oynanabilir**. İnternet sadece: bulut kayıt, sıralama, IAP, reklam, remote config için gerekli.
2. Offline yapılan işlemler kuyruğa alınır, bağlantı gelince senkronize edilir.
3. Çakışma çözümü: **sunucu otoritedir** sıralama/PvP için; **istemci otoritedir** tek oyunculu ilerleme için (server sanity check ile).

### 19.7 SessionEndGuard — Yarım İş Garantisi

```dart
// application/services/session_service.dart

class SessionService {
  /// Uygulama arka plana geçerken çağrılır.
  Future<void> onSessionEnd(GameState s) async {
    final openLoops = _countOpenLoops(s);   // §6.5 envanteri
    if (openLoops < 2) {
      // Yapay değil — doğal bir fırsat üret
      final generated = _generateOpenLoop(s);
      // örn: bekleyen sponsor teklifi, scout ipucu, akademi raporu
      await _apply(generated);
      await _scheduleNotification(generated);
    }
    await _scheduleNextMatchNotification(s);
    await _saveNow(s);
    _analytics.logSessionEnd(s, openLoops);
  }

  int _countOpenLoops(GameState s) =>
      (s.activeBuilds.length) +
      (s.activeScouts.length) +
      (s.pendingOffers.length) +
      (s.activeChains.where((c) => !c.isComplete).length) +
      (s.injuredPlayers.length > 0 ? 1 : 0) +
      (s.dailyQuests.where((q) => q.progress > 0 && !q.done).length);
}
```

### 19.8 İçerik Pipeline (Kartlar & Denge)

```
content/
├── cards/
│   ├── squad/*.json
│   ├── press/*.json
│   ├── board/*.json
│   └── ...
├── chains/*.json
├── balance/
│   ├── economy.json
│   ├── progression.json
│   └── sim.json
├── names/
│   ├── tr.json, br.json, es.json, ...
└── clubs/
    └── club_templates.json
```

**Derleme adımı:** `tool/build_content.dart`
1. Tüm JSON'ları okur ve **şemaya karşı doğrular** (Ek B)
2. Referans bütünlüğü kontrolü (zincir → kart id'leri var mı, perk id'leri geçerli mi)
3. Denge kontrolü (bir kart tüm göstergeleri +12 veriyorsa uyarı)
4. Tek bir sıkıştırılmış `content.bin` üretir → uygulama boyutu ↓, yükleme hızı ↑
5. CI'da her PR'da çalışır, hata varsa build kırılır

**Live-ops içerik güncellemesi:** Yeni kartlar **uygulama güncellemesi olmadan** Firebase Storage'dan indirilebilir (versiyonlu, imzalı). Kritik: içerik indirmesi mağaza politikalarına uygun — sadece veri, kod değil.

### 19.9 Hile Önleme (Anti-Cheat)

| Saldırı | Önlem |
|---|---|
| Saat ileri alma (time skip) | Sunucu saati referans (`server_time.dart`), ilk açılışta NTP benzeri senkron; offline'da monotonic clock + son bilinen sunucu saati; ileri sapma tespitinde ödül dondurulur |
| Kayıt dosyası düzenleme | Isar dosyası + HMAC imzası (cihaz anahtarı ile), imza uyuşmazsa buluttan geri yükle |
| Bellek düzenleme (GameGuardian) | Kritik değerler (kasa, rozet) **obfuscated wrapper** içinde tutulur (değer + checksum çifti) |
| Sahte IAP | **Sunucu tarafı makbuz doğrulama zorunlu** (Apple/Google API). İstemci asla tek başına ödül vermez |
| Sahte maç sonucu (PvP/sıralama) | Sunucu aynı Dart motoruyla yeniden simüle eder; sapma varsa sonuç reddedilir + flag |
| Reklam ödülü sahtekârlığı | SSV (Server-Side Verification) — AppLovin/AdMob callback'i sunucuya gelir, ödül orada verilir |
| APK modifikasyonu | Play Integrity API / DeviceCheck (iOS); şüpheli cihazlar sıralamadan çıkarılır (banlanmaz, sadece ayrılır) |

> **Denge:** Tek oyunculu ilerlemede aşırı sıkı anti-cheat **kötü UX** yaratır (yanlış pozitifler). Sert doğrulama sadece **sıralama, PvP ve IAP** için uygulanır.

### 19.10 Performans Hedefleri ve Optimizasyon

| Metrik | Hedef | Ölçüm |
|---|---|---|
| Cold start (uygulama → oynanabilir) | ≤ 2.5 sn | Firebase Performance |
| Warm start | ≤ 0.8 sn | |
| Ana ekran frame time | ≤ 16.6 ms (60fps) | DevTools |
| Jank oranı | < %2 | |
| Maç simülasyonu süresi | < 40 ms (90 dk sim) | Benchmark testi |
| APK boyutu (Android, split ABI) | ≤ 95 MB | |
| IPA boyutu | ≤ 130 MB | |
| Bellek kullanımı (peak) | ≤ 280 MB | |
| Pil (30 dk oyun) | ≤ %5 | |

**Optimizasyon kuralları:**
- `const` widget'lar her yerde; `ListView.builder` zorunlu
- Görseller WebP; oyuncu yüzleri katmanlı sprite atlas
- `RepaintBoundary` maç pitch'i etrafında
- Ağır hesaplama (toplu sim, sezon geçişi) → **Isolate**
- Firebase başlatma deferred (splash arkasında)
- Impeller (iOS varsayılan, Android'de test et)

```dart
// Ağır işlemler için isolate deseni
Future<SeasonResult> rolloverSeason(GameState s) =>
    compute(_rolloverSeasonIsolate, s.toJson());
```

### 19.11 Test Stratejisi

| Test tipi | Kapsam | Araç | Hedef |
|---|---|---|---|
| Unit (domain) | Sim, ekonomi, kart efektleri, gelişim | `test` | ≥ %85 coverage |
| **Denge testi** | 10.000 maç, §11.8 bantları | özel CLI | Bant dışı → CI fail |
| **Ekonomi simülasyonu** | 90 günlük sanal oyuncu, 3 profil (casual/normal/hardcore) | özel CLI | Ekonomi bantları (§15.7) |
| Widget | Kritik ekranlar | `flutter_test` | Ana akışlar |
| Integration | FTUE tam akış, satın alma akışı | `integration_test` | Her sürüm |
| Golden | Kart, oyuncu kartı, gösterge | `golden_toolkit` | Görsel regresyon |
| Manual QA | Cihaz matrisi | — | Sürüm öncesi |

**Cihaz matrisi (minimum):**
- iPhone SE 2020 (küçük ekran), iPhone 13, iPhone 15 Pro Max
- Samsung A14 (düşük-orta, en yaygın), Xiaomi Redmi Note serisi, Pixel 7
- Android tablet + iPad (layout kontrolü)

### 19.12 Sürüm ve Dallanma Stratejisi

```
main          ─────●────────●────────●─────  (production, tag'li)
                    \        \        \
release/1.2   ───────●───●────●             (stabilizasyon, sadece bugfix)
                      \
develop       ──●──●───●──●──●──●──●──●───   (entegrasyon)
                 \        /  \       /
feature/*     ────●──────●    ●─────●        (özellik dalları)
```

- Semantic versioning: `MAJOR.MINOR.PATCH+BUILD`
- Her PR: lint + test + content build + golden test
- Release: Fastlane ile otomatik TestFlight / Play Internal Track
- Kademeli yayın (staged rollout): %5 → %20 → %50 → %100, crash oranı izlenerek

---

## 20. ANALYTICS, KPI VE A/B TEST

### 20.1 Ölçüm Felsefesi
> **Ölçmediğin şeyi düzeltemezsin, ama her şeyi ölçersen hiçbir şeyi göremezsin.**

Event taksonomisi **hipotez odaklı** olmalı. Her event bir soruyu cevaplamalı. Cevaplamıyorsa loglanmaz.

### 20.2 Event Adlandırma Kuralı

```
<alan>_<nesne>_<eylem>

örn: ftue_step_complete
     match_live_start
     transfer_negotiation_end
     card_choice_made
     shop_offer_shown
```
- snake_case, İngilizce, geçmiş zaman fiil
- Parametre sayısı ≤ 12
- Kullanıcı kimliği: `user_id` (anonim uuid) + `install_id`

### 20.3 Kuzey Yıldızı Metrik (North Star)

> **"Haftalık Sezon Tamamlayan Kullanıcı" (Weekly Season Finishers)**
> Bir haftada sezonun ≥18 maçını oynayan tekil kullanıcı sayısı.

**Neden bu:** DAU'dan daha derin (sadece açmak yetmiyor), gelirden daha erken sinyal, oyunun temel vaadini (bir sezon yaşamak) ölçüyor. Bu metrik büyüyorsa her şey büyür.

### 20.4 KPI Ağacı

```
KUZEY YILDIZI: Haftalık Sezon Tamamlayan
├── EDİNME
│   ├── Install
│   ├── CPI (kanal bazında)
│   ├── Organic/Paid oranı
│   └── Store CVR (impression → install)
├── AKTİVASYON
│   ├── FTUE tamamlama %
│   ├── İlk maç tamamlama %
│   └── İlk sezon başlama %
├── RETENTION
│   ├── D1 / D3 / D7 / D14 / D21 / D30 / D60 / D90
│   ├── Seans/gün, seans süresi
│   ├── Organik açılış % (push'suz)
│   └── Sezon tamamlama oranı
├── ENGAGEMENT
│   ├── Kart/seans, karar çeşitliliği
│   ├── Canlı Anlar kullanım oranı
│   ├── Transfer/hafta
│   └── Tesis yükseltme/hafta
├── MONETİZASYON
│   ├── Payer conversion %, ARPPU, ARPDAU
│   ├── Sezon Bileti alım %, yenileme %
│   ├── Rewarded ad izleme/DAU
│   └── LTV(30/90/180)
└── SAĞLIK
    ├── Crash-free %, ANR
    ├── Cold start süresi
    └── Mağaza puanı, yorum duyarlılığı
```

### 20.5 Kritik Funnel'lar

**Funnel 1 — FTUE** (§7.5)

**Funnel 2 — İlk Sezon**
```
season_start(1) → match_complete(×5) → match_complete(×15) → season_complete(1)
Hedef: %58 sezon tamamlama
```

**Funnel 3 — Transfer**
```
transfer_search → player_view → scout_assign → negotiation_start
  → negotiation_offer → transfer_complete
Hedef: search → complete %22
```

**Funnel 4 — Satın Alma**
```
shop_open → offer_view → purchase_initiate → purchase_complete
Hedef: shop_open → complete %4.5
```

**Funnel 5 — Sezon Bileti**
```
battlepass_view → battlepass_purchase → tier_progress(15) → tier_complete(30)
Hedef: view → purchase %6, purchase → tier30 %71
```

### 20.6 Segmentasyon

| Segment ekseni | Değerler | Kullanım |
|---|---|---|
| `spend_tier` | 0 / 1 / 2 / 3 | Monetizasyon analizi, PvP eşleştirme |
| `lifecycle` | new / active / wobbling / dormant / churned | CRM |
| `play_style` | builder / trader / tactician / storyteller | İçerik önceliklendirme |
| `league_tier` | 20–16 / 15–11 / 10–6 / 5–1 | Ekonomi dengesi |
| `session_pattern` | burst / steady / evening_only | Push zamanlaması |
| `device_tier` | low / mid / high | Performans önceliklendirme |
| `acquisition` | organic / ua_channel | ROAS |

**`play_style` tespiti (davranışsal kümeleme):** İlk 7 günün aksiyon dağılımından çıkarılır. Bu segment, hangi içeriğe yatırım yapılacağını belirler — ör. `storyteller` segmenti büyükse kart içeriğine bütçe kaydırılır.

### 20.7 A/B Test Yol Haritası

| Öncelik | Test | Hipotez | Ana metrik | Örneklem |
|---|---|---|---|---|
| 1 | FTUE uzunluğu (8.5 dk vs 5 dk) | Kısa FTUE tamamlamayı artırır ama D7'yi düşürür | `ftue_complete`, D7 | 20K |
| 2 | İlk maç sonucu (yenilgi vs galibiyet) | Planlı yenilgi hikâye motivasyonu yaratır | D1 | 20K |
| 3 | Push izni zamanı (FTUE içi vs S1 sonu) | Geç sorma opt-in oranını artırır | opt-in %, D7 | 30K |
| 4 | Sezon uzunluğu (7 gün vs 5 gün) | Kısa sezon daha çok "tamamlama" verir | D14, sezon tamamlama | 40K |
| 5 | Kart/seans (2 vs 4) | Daha çok kart = daha çok engagement mi, yorgunluk mu | seans süresi, D7 | 25K |
| 6 | Görevden alınma sıkılığı | Yüksek gerilim retention'ı artırır mı düşürür mü | D14, uninstall | 30K |
| 7 | Başlangıç paketi zamanı (D2 vs D4) | Erken teklif dönüşümü artırır | payer conv, D7 | 30K |
| 8 | Sezon Bileti fiyatı ($4.99 vs $6.99) | Fiyat esnekliği | revenue/user | 40K |
| 9 | Gösterge sayısı (4 vs 3) | Daha az gösterge = daha az kafa karışıklığı | FTUE, D3 | 20K |
| 10 | Otomatik Diz varsayılan açık/kapalı | Kolaylık vs sahiplik | seans süresi, D7 | 20K |

**A/B test disiplini:**
- Aynı anda maks 3 test, çakışmayan alanlarda
- Minimum örneklem: metriğe göre power analizi (D7 için grup başına ≥10K)
- Minimum süre: 14 gün (haftalık döngü etkisi)
- Karar kriteri: **p < 0.05 VE pratik anlamlılık** (D7'de ≥ %1.5 mutlak fark)
- Kaybeden varyant hemen kapatılır, kazanan kademeli açılır
- Her test sonucu `docs/experiments/` altında kayıt altına alınır

### 20.8 Dashboard Yapısı

| Dashboard | Kim bakar | Güncellik | İçerik |
|---|---|---|---|
| **Günlük Sağlık** | Herkes | Gerçek zamanlı | DAU, crash, D1, gelir, kritik hatalar |
| **Retention** | Design/Product | Günlük | Kohort tabloları, funnel'lar |
| **Ekonomi** | Design | Günlük | Musluk/lavabo, kasa dağılımı, enflasyon |
| **Monetizasyon** | Business | Günlük | ARPDAU, conv, LTV, ürün bazında gelir |
| **UA / ROAS** | Marketing | Günlük | Kanal CPI, ROAS D7/D30 |
| **İçerik** | Design | Haftalık | Kart seçim dağılımı, hangi kart sıkıcı, hangi zincir terkediliyor |
| **Deney** | Product | Haftalık | Aktif A/B testler ve sonuçlar |

**Kart içerik dashboard'u özellikle kritik:** Her kart için `seçenek A %` / `seçenek B %` dağılımı. %85+ tek yöne giden kartlar **bozuk** işaretlenir ve yeniden dengelenir (§12.10 kural 3).

---
## 21. UI/UX VE TASARIM SİSTEMİ

### 21.1 Navigasyon Yapısı

**Alt sekme çubuğu (5 sekme, sabit):**

```
┌────────┬────────┬────────┬────────┬────────┐
│  OFİS  │ KADRO  │TRANSFER│  KULÜP │  LİG   │
│   🏠   │   👥   │   🔄   │   🏟️   │   📊   │
└────────┴────────┴────────┴────────┴────────┘
```

Mağaza sekmede **değil** — üst barda ikon (agresif olmayan yerleşim).
Menajer profili — üst sol avatar.

**Rota haritası (go_router):**
```
/                          → Ofis (ana ekran)
/squad                     → Kadro listesi
/squad/player/:id          → Oyuncu detay
/squad/tactics             → Taktik
/transfer                  → Transfer merkezi
/transfer/search           → Arama/filtre
/transfer/scout            → Scout yönetimi
/transfer/negotiate/:id    → Pazarlık
/club                      → Kulüp/tesisler
/club/facility/:id         → Tesis detay
/club/finance              → Finans
/club/history              → Kulüp tarihi
/league                    → Lig tablosu
/league/fixtures           → Fikstür
/league/competitive        → Rekabet Ligi
/manager                   → Menajer profili
/manager/skills            → Yetenek ağacı
/match/:id                 → Maç (fullscreen)
/cards                     → Karar kartı (modal/fullscreen)
/shop                      → Mağaza
/settings                  → Ayarlar
```

### 21.2 Ana Ekran (Ofis) — Anatomi

```
┌─────────────────────────────────────────────┐
│ [avatar]  Sv.14        ₣ 284.500   🏅 620  ⚙│  ← üst bar
├─────────────────────────────────────────────┤
│  💰 ████████░░  📣 ██████░░░░                │  ← 4 gösterge
│  👥 ███████░░░  🏛️ █████░░░░░                │
├─────────────────────────────────────────────┤
│                                             │
│   ┌───────────────────────────────────┐     │
│   │   SIRADAKİ ADIM                   │     │  ← tek net CTA
│   │   ⚽ Maç 14:20'de başlıyor         │     │
│   │   Ankara Gücü — Adana Şimşek      │     │
│   │   [ KADROYU HAZIRLA ]             │     │
│   └───────────────────────────────────┘     │
│                                             │
│   [Stadyum illüstrasyonu — Sv.3]            │  ← ilerleme kanıtı
│                                             │
│   ── DEVAM EDENLER ─────────────────        │
│   🏗️ Tıbbi Merkez Sv.2      ⏱ 1s 12dk      │
│   🔍 Scout: Karadeniz       ⏱ 42dk         │
│   💬 "Kaan seni bekliyor"   [ Aç ]          │
│                                             │
│   ── BUGÜN ────────────────────────         │
│   ✅ 1 maç oyna        ✅ 2 kart çöz         │
│   ⬜ 1 transfer yap                          │
│                                             │
├─────────────────────────────────────────────┤
│  OFİS  KADRO  TRANSFER  KULÜP  LİG          │
└─────────────────────────────────────────────┘
```

**Tasarım kuralları:**
1. **Tek birincil CTA.** "Sıradaki Adım" kartı her zaman ne yapılacağını söyler. Belirsizlik = terk.
2. **Stadyum görünür.** İlerlemenin duygusal kanıtı sürekli göz önünde.
3. **Devam edenler listesi** = Zeigarnik motorlarının görünür hâli.
4. **Günlük görevlerin ilki hep tamam** (endowed progress).
5. Rozet/bildirim noktaları **sadece gerçek yeni içerik** için — sahte kırmızı nokta yok.

### 21.3 Ekran Ekran Kısa Brief

| Ekran | Ana amaç | Kritik eleman | Kaçınılacak |
|---|---|---|---|
| **Ofis** | Yönlendirme | Sıradaki Adım kartı | Bilgi kalabalığı |
| **Karar Kartı** | Karar | Kart + göstergeler | Kaydırma gerektiren metin |
| **Kadro** | Genel bakış | OVR, form, fitness, moral tek satırda | Excel tablosu hissi |
| **Oyuncu Detay** | Derinlik | Radar grafik + gelişim çizgisi + hikâye | Sayı duvarı |
| **Taktik** | Kontrol | Görsel formasyon + sürükle-bırak | Karmaşık slider seti |
| **Transfer Ara** | Keşif | Filtre + kart listesi + "izle" | Sonsuz liste |
| **Pazarlık** | Gerilim | Slider + sabır barı + ek maddeler | Tek buton |
| **Maç (Canlı)** | Heyecan | Pitch + skor + karar anları | Uzun bekleme |
| **Maç Sonucu** | Tatmin | Skor + maçın adamı + gösterge deltası | Reklam |
| **Tesisler** | İnşa | İzometrik kulüp haritası + kilit ipuçları | Menü listesi |
| **Lig** | Bağlam | Tablo + senin satırın vurgulu | Küçük font |
| **Menajer** | Kimlik | Kariyer zaman çizelgesi + rozetler | — |
| **Mağaza** | Dönüşüm | Net değer, karşılaştırma | Sahte sayaç |

### 21.4 Oyuncu Kartı Tasarımı

```
┌──────────────────────────────┐
│ ┌────┐  ARSLAN DEMİR      78 │  ← OVR sağ üst, büyük
│ │yüz │  ST · 22 · 🇹🇷        │
│ └────┘  ★★★★☆              │
│                              │
│  HIZ  84 ████████░░          │  ← sadece pozisyona
│  TEK  79 ███████░░░          │     uygun 3-4 özellik
│  ŞUT  81 ████████░░          │     ön planda
│                              │
│  Form ▲▲   Fit 92   Moral 74 │
│  ₣4.200/hf · 3 sezon         │
│                              │
│  "Takımın golcüsü. Son 5     │  ← doğal dil özeti
│   maçta 4 gol."              │
└──────────────────────────────┘
```
Nadirlik rengi kart kenarında; efsane oyuncularda hafif animasyonlu kenar.

### 21.5 Karar Kartı Etkileşimi (Mikro-Etkileşim Detayı)

```
1. Kart aşağıdan yukarı kayarak girer (280ms, easeOutCubic)
2. Metin fade-in (120ms gecikmeli)
3. Kullanıcı kaydırmaya başlar:
   · Kart parmağı takip eder, hafif rotasyon (maks 12°)
   · 30px eşiğinde: ilgili gösterge ikonları hafif parlar (hangi gösterge
     etkilenecek belli olur, MİKTAR belli olmaz)
   · 90px eşiğinde: seçenek metni belirginleşir, haptic light impact
4. Bırakma:
   · Eşik geçildiyse: kart o yöne uçar (200ms), haptic medium
   · Geçilmediyse: yerine döner (spring)
5. Göstergeler animasyonla değişir (450ms, sıralı — hepsi aynı anda değil)
   · Pozitif: yeşil parıltı + yukarı ok
   · Negatif: kırmızı titreşim + aşağı ok
   · Büyük negatif (>10): ekran hafif sarsıntı + düşük frekans ses
6. Sonuç metni belirir (bir NPC repliği)
7. [Devam] veya otomatik olarak sonraki kart (600ms)
```

**Haptic haritası:**
| Olay | Haptic |
|---|---|
| Kaydırma eşiği | `lightImpact` |
| Seçim onayı | `mediumImpact` |
| Gol | `heavyImpact` ×1 |
| Kupa | `heavyImpact` ×3 (ritimli) |
| Kritik uyarı | `vibrate` pattern |
| Buton dokunuş | `selectionClick` |

### 21.6 Animasyon Prensipleri

| Prensip | Uygulama |
|---|---|
| Süre | Mikro 120–200ms · Geçiş 250–350ms · Kutlama 800–1500ms |
| Eğri | Giriş `easeOut`, çıkış `easeIn`, ikisi `easeInOut`, zıplama `elasticOut` |
| Sayı animasyonu | Para/XP daima **sayarak** artar (0.6s), anlık değişmez |
| İlerleme barı | Daima animasyonlu dolar, asla sıçramaz |
| Kutlama | Konfeti sadece gerçek büyük anlarda (terfi, kupa) — enflasyon yaratma |
| Performans | Düşük cihazda animasyon süresi ×0.7, parçacık sayısı ×0.4 |
| Erişilebilirlik | `MediaQuery.disableAnimations` respect edilir |

### 21.7 Tasarım Sistemi Tokenları

```dart
// app/theme/spacing.dart — 4pt grid
class Sp {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0,
               xl = 24.0, xxl = 32.0, xxxl = 48.0;
}

// Köşe yarıçapı
class R {
  static const s = 8.0, m = 12.0, l = 16.0, xl = 24.0, pill = 999.0;
}

// Yükseklik (elevation) — dark temada gölge yerine yüzey açıklığı
class Surface {
  static const l0 = Color(0xFF05120C);  // arka plan
  static const l1 = Color(0xFF0B2E20);  // kart
  static const l2 = Color(0xFF14181B);  // yükseltilmiş kart
  static const l3 = Color(0xFF1E252B);  // modal
}

// Dokunma alanı: minimum 44×44 pt (iOS HIG) / 48×48 dp (Material)
```

### 21.8 Erişilebilirlik (a11y)

| Gereksinim | Uygulama |
|---|---|
| Kontrast | Metin ≥ 4.5:1, büyük metin ≥ 3:1 (WCAG AA) |
| Renk körlüğü | Renk **asla tek başına** anlam taşımaz — ok/işaret/desen eşlik eder |
| Dinamik yazı boyutu | `MediaQuery.textScaler` desteklenir, layout 1.3× ölçekte kırılmaz |
| Ekran okuyucu | Tüm interaktif öğelerde `Semantics` label; kart metni okunabilir |
| Hareket duyarlılığı | Azaltılmış hareket modu (ayarlarda + sistem tercihi) |
| Dokunma alanı | Min 44×44 |
| Ses bağımsızlığı | Sesli bilgi daima görsel karşılığı ile birlikte |
| Renk temaları | 🔵 Renk körlüğü modu (protanopi/deuteranopi paleti) |
| Tek elle kullanım | Kritik butonlar ekranın alt %40'ında |

### 21.9 Boş Durum, Hata ve Yükleme

| Durum | Tasarım |
|---|---|
| Boş kadro | İllüstrasyon + "Hiç oyuncun yok. Transfer pazarına bak." + CTA |
| Ağ hatası | "İnternet yok — offline oynayabilirsin. Sıralamalar sonra güncellenecek." (panik yok) |
| Yükleme | Skeleton (spinner değil), 300ms'den kısa yüklemelerde hiçbir şey gösterme |
| Sunucu hatası | "Bir aksilik oldu. Kaydın güvende." + Tekrar dene |
| Satın alma hatası | Net hata + destek linki + otomatik makbuz kurtarma |
| Uzun işlem | İlerleme + iptal seçeneği |

### 21.10 Onboarding UI Deseni
- Coach mark (spot ışığı) yerine **NPC diyalogu** kullan → kurgu bozulmuyor
- "Buraya dokun" yerine "Başkan: 'Kadronu göster bakalım.'" + hedef parlıyor
- Atlanabilir mi? İlk 5 dakika hayır, sonrası evet (`Ayarlar > İpuçlarını kapat`)

---

## 22. SES VE MÜZİK

### 22.1 Ses Tasarımı Felsefesi
Oyun **sessiz oynanabilir olmalı** (metro, iş yeri). Ses bir katman, gereklilik değil. Ama sesli oynayan için stadyum atmosferi duygusal bağı çok güçlendiriyor.

### 22.2 Ses Katmanları

| Katman | İçerik | Kullanım |
|---|---|---|
| **Ortam (ambience)** | Stadyum uğultusu, ofis sessizliği, yağmur | Ekrana göre değişir, döngüsel, düşük ses |
| **Müzik** | 6 parça: menü, maç öncesi gerginlik, kutlama, hüzün, transfer, sezon finali | Adaptif — duruma göre geçiş |
| **UI SFX** | Dokunuş, kaydırma, onay, iptal, hata | Kısa, tok, tekrar edilebilir |
| **Oyun SFX** | Gol, düdük, kalabalık tepkisi, para, seviye atlama, kart kaydırma | Duygusal işaret |
| **Tepki (stinger)** | 1–3 sn kısa müzikal vurgu | Kupa, terfi, görevden alınma |

### 22.3 Ses Listesi (MVP)

```
ui/
  tap.wav, swipe_start.wav, swipe_commit.wav, cancel.wav,
  error.wav, unlock.wav, coin.wav, level_up.wav
match/
  whistle_start.wav, whistle_end.wav, whistle_half.wav,
  crowd_low_loop.wav, crowd_build.wav, crowd_goal.wav,
  crowd_disappointed.wav, crowd_ooh.wav, post_hit.wav,
  save.wav, kick.wav
meters/
  meter_up.wav, meter_down.wav, meter_critical.wav
stingers/
  promotion.wav, trophy.wav, relegation.wav, sacked.wav,
  signing.wav, season_start.wav
music/
  menu_loop.ogg, tension_loop.ogg, celebration.ogg,
  melancholy.ogg, transfer_market.ogg, season_final.ogg
brand/
  mnemonic.wav (1.2 sn)
```

### 22.4 Adaptif Müzik Kuralları
- Maç 80. dakika + skor farkı ≤1 → `tension_loop` katmanı devreye girer
- Gösterge < 20 → müzik tonu düşer (low-pass filtre)
- Sezon finali → özel parça
- Geçişler crossfade 800ms

### 22.5 Teknik
- Format: `.ogg` (Android) / `.m4a` (iOS) — veya evrensel `.mp3` basitlik için
- Paket: `just_audio` (müzik) + `soundpool`/`audioplayers` (SFX, düşük gecikme)
- SFX ≤ 40 KB, müzik ≤ 1.2 MB/parça
- Ses ayarları: Müzik / SFX / Titreşim ayrı slider'lar
- **Varsayılan:** Müzik açık %60, SFX açık %80 — ama ilk açılışta "Sessiz oynamak ister misin?" sorulmaz (sürtünme)
- Sistem sessiz modunda SFX çalmaz (iOS `AVAudioSession` doğru kategori)
- Arka plan müziği başka uygulama çalıyorsa **duck** edilir, kesilmez

### 22.6 Marka Mnemonic'i
1.2 saniye: alçak bir davul vuruşu → yükselen iki nota (5. aralık) → stadyum uğultusu kuyruğu. Splash'te, kupa kutlamasında ve reklam videolarının sonunda kullanılır. Bu ses, marka tanınırlığının en ucuz ve en etkili aracı.

---

## 23. İÇERİK ÜRETİMİ VE LOKALİZASYON

### 23.1 Prosedürel İçerik Stratejisi

Gerçek oyuncu/kulüp lisansı **almıyoruz** (§24.2). Bunun yerine yüksek kaliteli prosedürel üretim:

| İçerik | Yöntem | Hacim |
|---|---|---|
| Oyuncu isimleri | Ülke bazlı ad + soyad havuzu, ağırlıklı kombinasyon | 4.000+ benzersiz |
| Oyuncu yüzleri | Katmanlı sprite (kafa şekli ×8, saç ×24, ten ×6, göz ×10, ağız ×8, sakal ×12, aksesuar ×6) | ~9.9M kombinasyon |
| Kulüp isimleri | Şehir + ek ("spor", "Gücü", "FK", "Birlik") | 220 kulüp |
| Kulüp armaları | Şablon ×12 × renk kombinasyonu × simge ×20 | Yeterli çeşitlilik |
| Stadyum isimleri | Şehir/sponsor/kişi şablonları | 220 |
| Şehirler | Kurgusal ama tanıdık ses | 60 |
| NPC'ler | El yazımı ana karakterler (12) + prosedürel yan | — |

### 23.2 Oyuncu Üretim Algoritması

```dart
Player generatePlayer({
  required int leagueTier,     // 1-20
  required DeterministicRng rng,
  Position? forcedPosition,
  int? forcedAge,
}) {
  final position = forcedPosition ?? rng.weightedPick(positions, positionWeight);
  final age = forcedAge ?? _sampleAge(rng);        // 16-36, normal dağılım μ=25

  // Lig kademesine göre baz kalite
  final baseQuality = 38 + (20 - leagueTier) * 2.6 + rng.gaussian(0, 5.5);

  // Yaşa göre mevcut/potansiyel ayrımı
  final potential = clamp(baseQuality + _potentialBonus(age, rng), 30, 99);
  final current   = age < 24
      ? potential - rng.range(6, 22) * ((24 - age) / 8)
      : potential - rng.range(0, 4);

  // Pozisyona göre özellik dağılımı (ağırlıklı gürültü)
  final attrs = _distributeAttributes(current, position, rng);

  return Player(
    firstName: rng.pick(namePool(country).first),
    lastName:  rng.pick(namePool(country).last),
    ...
    personality: rng.weightedPick(personalities, personalityWeight),
    consistency: clamp(50 + rng.gaussian(0, 18), 15, 95),
    injuryProneness: clamp(35 + rng.gaussian(0, 20), 5, 95),
  );
}
```

**Kalite kontrol:** Üretilen 4.000 oyuncunun OVR dağılımı normal olmalı (μ ≈ 58, σ ≈ 12), pozisyon dağılımı gerçekçi olmalı (her takımda 2-3 kaleci, 6-8 defans...). Test: `test/generation_distribution_test.dart`.

### 23.3 Desteklenen Diller

| Faz | Diller | Gerekçe |
|---|---|---|
| 🟢 MVP | TR, EN | Soft launch pazarları |
| 🟡 v1.1 | PT-BR, ES, ID | En büyük futbol + mobil pazarlar |
| 🔵 v1.3 | DE, FR, IT, AR, RU | Avrupa + MENA |
| ⚫ Sonra | JA, KO, TH, VI, PL, NL | Ölçüme göre |

### 23.4 Lokalizasyon Teknik Notları

**Türkçe özel zorluklar (dikkat!):**
```dart
// Ünlü uyumu ve ek getirme — dinamik isim enjeksiyonunda kritik
// "Arslan" + "'in" ama "Kaan" + "'ın", "Emre" + "'nin"

String possessive(String name) {
  final lastVowel = _lastVowel(name);
  final isConsonantEnd = !_vowels.contains(name.characters.last);
  // kalın/ince, düz/yuvarlak matrisine göre ek seç
  ...
}
```
- **Zorunlu:** `lib/l10n/turkish_grammar.dart` yardımcı sınıfı — ek getirme, çoğul, sayı+isim
- Kart metinlerinde ek gerektiren yerler `{player.name|gen}` gibi filtre sözdizimiyle işaretlenir
- Türkçe metinler İngilizce'den **%15–25 uzun** → UI'da taşma testi zorunlu

**Genel kurallar:**
- Hiçbir metin koda gömülü olmayacak (`.arb` dosyaları)
- Sayı/tarih/para formatı `intl` ile locale-aware
- RTL (Arapça) desteği: `Directionality`, ikon aynalama, layout testi
- Metin uzunluğu varyasyonu için: sabit genişlik yerine `FittedBox` / esnek layout
- Çeviri sürecinde **bağlam ekran görüntüsü** verilir (yoksa çeviri kalitesi çöker)

### 23.5 İçerik Üretim Kapasitesi Planı

| İçerik | MVP | 3. ay | 6. ay | 12. ay |
|---|---|---|---|---|
| Karar kartı | 200 | 320 | 550 | 1.000 |
| Kart zinciri | 15 | 28 | 50 | 95 |
| Oyuncu yüzü katmanı | Temel set | +2 etnik varyasyon | +yaş varyasyonu | +stil |
| Kulüp arma şablonu | 12 | 18 | 26 | 40 |
| Stadyum varyantı | 5 seviye × 1 stil | ×2 stil | ×3 stil | ×4 |
| Kozmetik (forma/arma) | 20 | 45 | 90 | 180 |
| Sezon teması | — | 4 | 12 | 26 |

---

## 24. HUKUK, UYUMLULUK VE MAĞAZA POLİTİKALARI

### 24.1 Şirket ve Yayın Yapısı

| Konu | Öneri |
|---|---|
| Tüzel kişilik | Limited şirket (TR) veya Estonya/Delaware (global ödeme kolaylığı) |
| Geliştirici hesabı | Apple Developer Program ($99/yıl, tüzel kişilik ile — D-U-N-S numarası gerekli) + Google Play Console ($25 tek seferlik) |
| Vergi | Apple/Google gelir kesintisi %15–30; dijital hizmet vergisi bölgesel |
| Banka | Uluslararası ödeme alabilen hesap (Wise/Payoneer alternatif) |

### 24.2 Fikri Mülkiyet — Kritik Kararlar

**❌ Gerçek oyuncu isimleri KULLANILMAZ.**
Oyuncu isimleri ve görüntüleri FIFPro / bireysel imaj hakları kapsamında. Lisans maliyeti indie için erişilemez ve ihlal doğrudan mağaza kaldırması + dava riski.

**❌ Gerçek kulüp isimleri, armaları, formaları KULLANILMAZ.**
Kulüp isimleri tescilli marka. "Galatasaray", "Real Madrid" vb. kullanımı marka ihlali.

**❌ Lig isimleri KULLANILMAZ** ("Premier League", "Süper Lig" tescilli).

**❌ Stadyum isimleri, sponsor logoları KULLANILMAZ.**

**✅ Kullanılabilir:**
- Tamamen kurgusal isimler (prosedürel üretim)
- Jenerik şehir isimleri (kurgusal varyasyonlar tercih edilir: "Ankara Gücü" yerine daha güvenli "Angora FK" gibi)
- Genel futbol terimleri ("lig", "kupa", "transfer")
- Kullanıcının kendi girdiği kulüp adı — **ama** kullanıcı gerçek kulüp adı girerse bu kullanıcının sorumluluğu; yine de bir **kelime filtresi** ile popüler marka isimleri engellenmeli (mağaza şikâyeti riski)

> ⚠ **Kullanıcı üretimi içerik riski:** Oyuncular kulüplerine küfür/nefret söylemi veya marka ismi verebilir. Zorunlu: (a) kelime filtresi, (b) sadece kendi görebileceği isimler ile başkalarının görebileceği isimler ayrımı, (c) şikâyet mekanizması, (d) moderasyon kuyruğu.

### 24.3 Yaş Sınırı ve Derecelendirme

| Sistem | Hedef derece | Gereklilik |
|---|---|---|
| App Store | **12+** | Simüle kumar yok, hafif tematik içerik |
| Google Play (IARC) | **PEGI 3 / ESRB E** — ama IAP nedeniyle "In-app purchases" etiketi | Anket doğru doldurulmalı |
| PEGI | 3 veya 7 | Şiddet yok |
| USK (DE) | 0 veya 6 | |

⚠ **Kritik:** Oyunda **bahis teması** karar kartlarında geçiyorsa (§12.10 kural 8) yaş derecesi yükselebilir. Öneri: bahis konulu kartlar **açıkça reddedilmesi ödüllendirilen** bir çerçevede yazılsın, "bahis oynama" mekaniği asla olmasın. Bu, hem etik hem derecelendirme açısından güvenli.

### 24.4 Loot Box / Rastgele Ödül Mevzuatı

| Ülke | Durum | Bizim uyumumuz |
|---|---|---|
| Belçika | Ücretli rastgele kutu **yasak** | ✅ Yok |
| Hollanda | Sıkı düzenleme | ✅ Yok |
| Çin | Olasılık açıklama zorunlu | ✅ N/A |
| UK/EU | Şeffaflık baskısı artıyor | ✅ Tüm içerik satın alma öncesi bilinir |
| Apple 3.1.1 | Olasılık açıklama zorunlu | ✅ N/A |
| Google | Olasılık açıklama zorunlu | ✅ N/A |

> Tasarım kararımız (§16.6) sayesinde bu mevzuatların hiçbiri bizi kısıtlamıyor. Bu **stratejik bir avantaj** — ileride kural sıkılaşırsa yeniden tasarım gerekmiyor.

### 24.5 Bahis, Doping, Şike Temaları
Bu temalar futbol dünyasının gerçeği ve karar kartlarında dramatik potansiyeli yüksek. Ama:
- Oyuncu **bahis oynayamaz** (mekanik yok)
- Kartlarda bu teklifleri **reddetmek** her zaman geçerli ve genellikle uzun vadede daha iyi
- Kabul edilirse kısa vadeli kazanç + yüksek risk (skandal zinciri) → gerçekçi ve öğretici
- Metin dili asla teşvik edici değil

### 24.6 Veri Koruma

| Mevzuat | Bölge | Gereklilik |
|---|---|---|
| **KVKK** | TR | Aydınlatma metni, açık rıza, veri sorumlusu kaydı (VERBİS) |
| **GDPR** | EU/UK | Yasal dayanak, rıza yönetimi (CMP), veri taşınabilirliği, silme hakkı, DPA'lar |
| **CCPA/CPRA** | California | "Do Not Sell" seçeneği |
| **COPPA** | ABD | 13 yaş altı veri toplama yasağı |
| **App Store Privacy Nutrition Labels** | iOS | Doğru beyan zorunlu |
| **Play Data Safety** | Android | Doğru beyan zorunlu |

**Uygulama gereklilikleri:**
- İlk açılışta **rıza ekranı** (EU/UK için CMP — Google UMP SDK veya benzeri)
- Kişiselleştirilmiş reklam rızası ayrı sorulur
- iOS **ATT (App Tracking Transparency)** prompt'u — bağlamsal ön-izin ile (§18.3 mantığı)
- Ayarlar > Gizlilik: veri indirme, hesap silme, rıza değiştirme
- Gizlilik Politikası + Kullanım Koşulları URL'leri (mağaza zorunlu)
- Analytics'te **PII toplanmaz** (isim, e-posta event'e girmez)
- Çocuk kitle hedeflenmiyor beyanı (Play "Target Audience" anketi)

### 24.7 Mağaza Politika Kontrol Listesi

**Apple App Store Review Guidelines — riskli maddeler:**
- [ ] 3.1.1 — Tüm dijital içerik IAP ile satılıyor (harici ödeme linki yok)
- [ ] 3.1.2 — Abonelik varsa: süre, fiyat, yenileme açıkça yazılı + iptal bilgisi
- [ ] 2.3 — Ekran görüntüleri gerçek oyunu gösteriyor (yanıltıcı değil)
- [ ] 4.2 — Yeterli işlevsellik (basit web sarmalayıcı değil)
- [ ] 5.1.1 — Gizlilik politikası, veri toplama beyanı doğru
- [ ] 5.1.2 — İzinler bağlamda isteniyor, `NSUserTrackingUsageDescription` net
- [ ] 1.4.3 — Yanıltıcı sağlık/finans iddiası yok
- [ ] IAP restore (satın alımları geri yükle) butonu var

**Google Play Policy — riskli maddeler:**
- [ ] Play Billing kullanılıyor (dijital içerik için)
- [ ] Data Safety formu doğru
- [ ] Target API level güncel (her yıl artıyor)
- [ ] Reklam politikası: yanıltıcı reklam yok, kapatılabilir
- [ ] Yanıltıcı iddia yok, ASO'da anahtar kelime spam'i yok
- [ ] Families Policy — çocuk hedefliyorsak (hayır)

### 24.8 Kullanıcı Sözleşmeleri (Hazırlanacak Belgeler)
1. **Kullanım Koşulları (EULA)** — hesap, sanal para, iade politikası, yasaklı davranışlar
2. **Gizlilik Politikası** — hangi veri, neden, kimlerle paylaşılıyor, ne kadar saklanıyor
3. **Çerez/İzleme Politikası**
4. **Sanal Para Politikası** — Altın Rozet'in gerçek değeri yoktur, geri ödeme yoktur (yasal koruma)
5. **Topluluk Kuralları** — kullanıcı üretimi isimler için

> 💡 İlk sürüm için hukuki maliyeti azaltmak: mobil oyunlara özel şablon setleri kullanılabilir, ancak **KVKK ve GDPR bölümleri mutlaka bir hukukçuya kontrol ettirilmeli.** Bu doküman hukuki tavsiye değildir.

### 24.9 Üçüncü Parti Lisanslar
- Font lisansları (Barlow, Inter — SIL OFL, ticari serbest) ✅
- Ses/müzik lisansları — telifsiz kütüphane veya besteci sözleşmesi (buyout tercih)
- Açık kaynak paket lisansları — `flutter pub deps` çıktısı gözden geçirilmeli; **GPL/AGPL paketler kullanılamaz** (mağaza dağıtımıyla uyumsuz)
- Uygulama içinde "Açık Kaynak Lisansları" ekranı (`showLicensePage`)

---
## 25. PRODÜKSİYON PLANI, EKİP, BÜTÇE

### 25.1 Faz Planı (12 Ay)

```
AY  1  2  3  4  5  6  7  8  9  10 11 12
    │──PROTOTİP──│
             │────VERTICAL SLICE────│
                          │──SOFT LAUNCH──│
                                      │──GLOBAL + LIVE-OPS──►
```

#### 🔹 FAZ 0 — Prototip (Ay 1–2)
**Hedef:** Çekirdek eğlence kanıtlanır. "Bu oyun eğlenceli mi?"

| Teslim | Detay |
|---|---|
| Kart mekaniği çalışır | 30 kart, 4 gösterge, kaydırma |
| Maç motoru v1 | Hızlı sim, temel formüller |
| Kadro ekranı | Basit liste |
| Bir sezon oynanabilir | 21 maç, terfi/düşme |
| Denge testi altyapısı | 10K maç toplu sim |

**Kapı kriteri (Gate):** 10 kişilik test grubunda **7/10 kişi "bir sezon daha oynamak istiyorum"** demeli. Değilse çekirdek yeniden tasarlanır — **ilerlenmez.**

#### 🔹 FAZ 1 — Vertical Slice (Ay 3–5)
**Hedef:** Oyunun 30 dakikası **son kalitede**. Yatırımcı/publisher gösterimi için hazır.

| Teslim | Detay |
|---|---|
| FTUE tam | §7.2 akışı, son sanat |
| 3 sezon oynanabilir | Tam ilerleme eğrisi |
| 120 kart + 8 zincir | |
| Tesis sistemi | 6 tesis × 3 seviye |
| Transfer + scouting + pazarlık | Tam akış |
| Canlı Anlar modu | |
| UI son kalite | Tasarım sistemi uygulanmış |
| Ses | Temel set |
| Analytics | Tüm kritik eventler |

**Kapı kriteri:** 100 kişilik kapalı testte **D7 ≥ %20**, ortalama seans ≥ 4 dk.

#### 🔹 FAZ 2 — Soft Launch (Ay 6–8)
**Hedef:** Gerçek kullanıcıyla metrik doğrulama ve dengeleme.

| Teslim | Detay |
|---|---|
| MVP kapsamı tam (§1.6) | |
| Monetizasyon aktif | IAP + sezon bileti + reklam |
| Backend + anti-cheat | |
| 2 dil (TR, EN) | |
| Remote Config denge | |
| A/B test altyapısı | |
| Store sayfası | ASO optimize |

**Soft launch pazarları:** Filipinler, Malezya, Peru, Romanya (düşük CPI, İngilizce/İspanyolca) + **Türkiye** (ana pazarımız, gerçek sinyal).

**Kapı kriteri (global lansman için):** D1 ≥ %38, D7 ≥ %16, D30 ≥ %7, crash-free ≥ %99.2, LTV(30)/CPI ≥ 0.55.

#### 🔹 FAZ 3 — Global Lansman + Live-Ops (Ay 9–12+)
| Teslim | Detay |
|---|---|
| 5+ dil | |
| Tam içerik (450 kart) | |
| Akademi, Kıta Kupası, Rekabet Ligi | |
| UA kampanyası | Ölçekli |
| Aylık içerik kadansı kuruldu | |
| Prestij sistemi | |

### 25.2 Ekip Yapısı

#### Minimum Ekip (Solo/İkili — "lean" senaryo)

| Rol | Kim | Süre |
|---|---|---|
| Game Design + Prodüksiyon | Kurucu | Tam zamanlı |
| Flutter Development | Kurucu veya 1 dev | Tam zamanlı |
| UI/UX + İllüstrasyon | Freelance | Proje bazlı |
| Yazarlık (kartlar) | Freelance | Proje bazlı |
| Ses | Freelance | Tek seferlik |
| QA | Freelance / topluluk | Sürüm bazlı |

> Bu senaryoda 12 ay yerine **16–20 ay** planla. Kapsamı §1.6'dan da kısarak başla: 100 kart, 8 tesis, 3 dal yerine 2 dal.

#### İdeal Ekip (6 kişi)

| Rol | FTE | Ana sorumluluk |
|---|---|---|
| Game Director / Designer | 1.0 | Vizyon, denge, kart tasarımı |
| Lead Flutter Dev | 1.0 | Mimari, sim motoru, performans |
| Flutter Dev | 1.0 | UI, ekranlar, entegrasyonlar |
| Backend Dev | 0.5 | Firebase, doğrulama, live-ops |
| UI/UX Designer + Artist | 1.0 | Tasarım sistemi, illüstrasyon |
| Yazar / İçerik Designer | 0.5 | Kartlar, zincirler, lokalizasyon koordinasyonu |
| Data / Live-Ops | 0.5 | Analytics, A/B, dengeleme |
| QA | 0.5 | Test |

### 25.3 Araç Yığını

| Alan | Araç | Maliyet |
|---|---|---|
| Kod | VS Code / Android Studio, GitHub | Ücretsiz / $4-21/ay |
| CI/CD | GitHub Actions + Codemagic | Ücretsiz kota + $30-100/ay |
| Tasarım | Figma | $12-15/ay/kişi |
| İllüstrasyon | Procreate / Affinity / Illustrator | Tek seferlik / abonelik |
| Animasyon | Rive | $14-28/ay |
| Proje yönetimi | Linear / Notion / Jira | $8-15/ay/kişi |
| Analytics | Firebase (ücretsiz) + Amplitude | Ücretsiz kota → $$ |
| Attribution | AppsFlyer / Adjust | $0.05-0.08/install |
| Abonelik yönetimi | RevenueCat | Ücretsiz < $10K/ay MTR |
| Lokalizasyon | Lokalise / Crowdin | $120+/ay |
| Ses | Freesound/Epidemic + freelance besteci | $200-3.000 |
| Destek | Helpshift / Zendesk / basit e-posta | $0-50/ay |

### 25.4 Bütçe Tahmini (12 Ay, İdeal Ekip)

> Aşağıdaki rakamlar **büyüklük mertebesi** göstergesidir; bölgesel maliyetlere göre ciddi değişir.

| Kalem | Düşük senaryo | Yüksek senaryo |
|---|---|---|
| Geliştirme (ekip maliyeti) | Ekip yapısına bağlı — en büyük kalem | |
| Sanat & animasyon (freelance) | $8.000 | $30.000 |
| Ses & müzik | $1.500 | $8.000 |
| Yazarlık (200→450 kart) | $2.000 | $9.000 |
| Lokalizasyon (5 dil) | $2.500 | $10.000 |
| Araçlar & altyapı (yıllık) | $2.000 | $8.000 |
| Sunucu maliyeti (ilk yıl) | $600 | $6.000 |
| Hukuk (sözleşmeler, marka) | $1.500 | $8.000 |
| Soft launch UA | $5.000 | $20.000 |
| Global lansman UA | $20.000 | $250.000+ |
| **Toplam (UA hariç, ekip hariç)** | **~$18.000** | **~$79.000** |

**Öneri:** Soft launch metrikleri kapı kriterlerini geçmeden global UA'ya **tek dolar harcanmaz**. Kötü retention'a reklam harcaması sermayeyi yakar.

### 25.5 Sprint Yapısı
- 2 haftalık sprint
- Sprint başı: planlama (2 sa), sprint sonu: demo + retro (2 sa)
- Her sprint sonunda **oynanabilir build** (TestFlight/Internal)
- Haftalık: 1 saat "playtest cuması" — tüm ekip kendi oyununu oynar
- Aylık: metrik değerlendirme + backlog önceliklendirme

### 25.6 Definition of Done (DoD)

Bir özellik "bitti" sayılır ancak ve ancak:
- [ ] Kod yazıldı, PR onaylandı, testler geçti
- [ ] Unit test yazıldı (domain katmanı için zorunlu)
- [ ] Analytics eventleri eklendi ve doğrulandı
- [ ] Lokalize edildi (en az TR + EN)
- [ ] Düşük segment cihazda test edildi
- [ ] Erişilebilirlik kontrolü yapıldı (kontrast, dokunma alanı, semantics)
- [ ] Remote Config ile ayarlanabilir parametreler dışarı çıkarıldı
- [ ] Boş/hata/yükleme durumları tasarlandı
- [ ] Tasarım gözden geçirmesinden geçti
- [ ] Dokümantasyon güncellendi (bu dosya dahil)

---

## 26. RİSK KAYDI

| # | Risk | Olasılık | Etki | Erken uyarı sinyali | Azaltma planı |
|---|---|---|---|---|---|
| R1 | **Çekirdek eğlenceli değil** | Orta | Kritik | Prototip testinde <5/10 | Faz 0 kapı kriteri; geçemezse pivot (kart mekaniğini derinleştir veya tycoon'a ağırlık ver) |
| R2 | **D7 hedefin altında** | Yüksek | Kritik | Soft launch D7 < %13 | Sezon uzunluğu A/B, D3–D6 içerik yoğunluğu, FTUE revizyonu |
| R3 | Kart içeriği hızla tükeniyor | Yüksek | Yüksek | Aynı kart 3+ kez şikâyeti | İçerik pipeline'ı erken kur, bağlamsal varyasyon, live-ops kadansı |
| R4 | Ekonomi enflasyonu | Orta | Yüksek | Ortalama kasa/gider > 8 | §15.7 izleme, Remote Config ayarı |
| R5 | Sim motoru gerçekçi değil | Orta | Yüksek | Denge testi bant dışı | §11.8 CI testi, gerçek lig verisiyle kalibrasyon |
| R6 | CPI çok yüksek, UA sürdürülemez | Yüksek | Yüksek | CPI > $2.5, LTV/CPI < 1 | Creative testi, organik/ASO'ya ağırlık, viral özellikler |
| R7 | Flutter performansı düşük cihazlarda yetersiz | Orta | Orta | Jank > %5, ANR | Erken cihaz testi, Impeller, isolate, animasyon ölçekleme |
| R8 | Mağaza reddi (IP/politika) | Düşük | Kritik | — | §24 kontrol listeleri, review öncesi hukuki gözden geçirme |
| R9 | Solo/küçük ekip tükenmesi | Yüksek | Yüksek | Sprint hızı düşüşü | Kapsam disiplini, MVP'ye sadık kal, dış kaynak |
| R10 | Rakip benzer oyun çıkarır | Düşük | Orta | — | Hız avantajı, içerik derinliği ile savun |
| R11 | Backend maliyeti öngörülemez artar | Düşük | Orta | Firebase faturası | Offline-first mimari zaten maliyeti düşük tutuyor; kota alarmı kur |
| R12 | Kullanıcı üretimi içerik (kulüp adı) skandalı | Orta | Orta | Şikâyet | Kelime filtresi, moderasyon, sadece-kendine-görünür mod |
| R13 | Görevden alınma mekaniği öfke yaratır | Orta | Yüksek | Uninstall spike + 1★ yorumlar | Uyarı aşamaları, geri dönüş penceresi, oran izleme (%12–18 bandı) |
| R14 | IAP dönüşümü çok düşük | Orta | Yüksek | conv < %1.2 | Teklif motoru optimizasyonu, sezon bileti değer artışı, fiyat A/B |
| R15 | Lokalizasyon kalitesi kötü | Orta | Orta | Bölgesel retention düşük | Native çevirmen, bağlam ekran görüntüsü, topluluk geri bildirimi |

**Risk gözden geçirme kadansı:** Her sprint sonunda R1–R5, aylık tüm liste.

---

## 27. SOFT LAUNCH VE GLOBAL LANSMAN

### 27.1 Soft Launch Stratejisi

**Amaç:** Metrikleri gerçek kullanıcıyla doğrulamak ve dengelemek. **Gelir amacı değildir.**

| Pazar | Neden | Hedef kullanıcı |
|---|---|---|
| **Türkiye** | Ana hedef pazarımız, gerçek kültürel sinyal, düşük CPI | 8.000 |
| Filipinler | Düşük CPI, İngilizce, mobil-first | 5.000 |
| Romanya | EU davranışı, düşük CPI, futbol kültürü | 3.000 |
| Peru | LATAM sinyali, İspanyolca hazırlık | 3.000 |

**Toplam hedef: 15.000–20.000 kullanıcı, 8–10 hafta.**

**Soft launch aşamaları:**
```
Hafta 1-2 : 2.000 kullanıcı — teknik stabilite, crash, FTUE funnel
Hafta 3-4 : 6.000 kullanıcı — retention ölçümü, ilk denge ayarları
Hafta 5-6 : 12.000 kullanıcı — monetizasyon açılır, IAP testi
Hafta 7-8 : 20.000 kullanıcı — A/B testler, LTV projeksiyonu
```

**Her hafta yapılacak:**
- Pazartesi: Metrik incelemesi
- Salı: Denge ayarı (Remote Config, uygulama güncellemesi olmadan)
- Çarşamba: Kullanıcı yorumu/destek analizi
- Perşembe: A/B test kararları
- Cuma: Sürüm (gerekirse)

### 27.2 Global Lansman Kontrol Listesi

**Teknik:**
- [ ] Crash-free ≥ %99.5 son 2 hafta
- [ ] Tüm hedef diller tam çevrilmiş ve QA'dan geçmiş
- [ ] Sunucu yük testi (10× beklenen pik)
- [ ] Rollback planı hazır
- [ ] Remote Config kill-switch'ler (özellik bazında kapatma)
- [ ] Destek altyapısı (SSS + iletişim kanalı)

**Mağaza:**
- [ ] ASO paketi tüm dillerde (§2.7)
- [ ] Ekran görüntüleri A/B test edilmiş (Play Custom Store Listing)
- [ ] Video preview hazır
- [ ] Yaş derecelendirmesi tamamlanmış
- [ ] Privacy labels doğru
- [ ] Pre-registration kampanyası (Play) — ödül vaadi ile

**Pazarlama:**
- [ ] UA kampanya yapısı hazır (kanal, kreatif, bütçe)
- [ ] 15+ kreatif varyantı (video, playable, statik)
- [ ] Influencer listesi (futbol + mobil oyun içerik üreticileri)
- [ ] Basın kiti (press kit): logo, ekran görüntüleri, açıklama, iletişim
- [ ] Sosyal medya hesapları aktif, içerik takvimi
- [ ] Discord/Reddit topluluğu kurulmuş
- [ ] Lansman günü push kampanyası (mevcut kullanıcılar)

### 27.3 UA (Kullanıcı Edinme) Stratejisi

| Kanal | Öncelik | Neden |
|---|---|---|
| **Meta (FB/IG)** | 1 | En iyi hedefleme, futbol ilgi alanı |
| **TikTok** | 1 | Genç kitle, düşük CPI, viral potansiyel |
| **Google App Campaigns** | 2 | Ölçek, arama niyeti |
| **Unity Ads / AppLovin** | 2 | Oyun içi trafik, oyuncu kitlesi |
| **Apple Search Ads** | 3 | Yüksek niyet, yüksek CPI ama yüksek LTV |
| **Influencer** | 2 | Güvenilirlik, organik kuyruk |
| **ASO (organik)** | 1 | Sürekli, bedava |

**Kreatif stratejisi (en kritik UA değişkeni):**

| Kreatif konsepti | Hipotez |
|---|---|
| "Yıldızın zam istiyor" kart kaydırma | Mekanik özgünlüğü ilgi çeker |
| "8 haftan var yoksa kovulacaksın" | Gerilim/merak |
| Stadyum 1→5 seviye dönüşümü (timelapse) | İlerleme fantezisi |
| "20. ligden Elit Lig'e" | Underdog hikâyesi |
| Gerçek oyuncu tepkisi / UGC tarzı | Otantiklik |
| Playable ad (kart kaydırma demosu) | En yüksek dönüşüm |

**Kural:** Kreatifler oyunu **doğru** temsil etmeli. Yanıltıcı reklam (oyunda olmayan mekanik göstermek) kısa vadede install getirir, D1'i öldürür ve mağaza cezası riski taşır.

### 27.4 Lansman Sonrası İlk 30 Gün

| Gün | Aksiyon |
|---|---|
| 0 | Lansman, tüm ekip nöbette, gerçek zamanlı izleme |
| 1–3 | Kritik bug hotfix döngüsü, crash izleme |
| 3–7 | İlk retention kohortu, UA kanal performansı |
| 7 | İlk büyük metrik incelemesi, bütçe yeniden dağıtımı |
| 7–14 | Denge ayarları, yorum yanıtlama |
| 14 | İlk içerik güncellemesi (yeni kartlar) |
| 21 | İlk etkinlik (live-ops) |
| 30 | Tam retrospektif, 90 günlük plan |

### 27.5 Mağaza Puanı Yönetimi

Mağaza puanı organik indirmelerin en büyük belirleyicisi.

**In-app rating prompt stratejisi:**
```
Tetikleyici: Oyuncu bir ZAFER anı yaşadıktan hemen sonra
  · Terfi kazandı, VEYA
  · Kupa kazandı, VEYA
  · 5 maçlık galibiyet serisi
VE
  · En az 3 gün oynamış
  · Daha önce sorulmamış (veya 120 gün geçmiş)
  · Son 24 saatte crash yaşamamış

Yöntem: Native review prompt (iOS SKStoreReviewController / Play In-App Review)
```
**Asla:** Kayıptan sonra, görevden alınmadan sonra, hata sonrası sorma.

**Yorum yanıtlama:** Tüm 1–3★ yorumlara 48 saat içinde yanıt. Türkçe yorumlara Türkçe.

### 27.6 Organik Büyüme Mekanikleri

| Mekanik | Nasıl çalışır |
|---|---|
| **Kariyer kartı paylaşımı** | Menajer profilinden görsel üretilir, sosyal medyada paylaşılır |
| **Efsane an paylaşımı** | 90. dk golü, imkânsız terfi → paylaşılabilir kart |
| **Arkadaş daveti** | Davet eden ve edilen ödül alır (etik: spam yok, sadece 5 davet/hafta) |
| **Menajer Ligi** | Arkadaşlarla özel lig → doğal davet |
| **Topluluk yarışmaları** | Discord/sosyal medyada "en iyi akademi oyuncusu" yarışması |
| **Keşif hikâyeleri** | Gizli yetenek bulan oyuncular bunu paylaşır (Reddit/forum kültürü) |

---

## 28. LIVE-OPS TAKVİMİ

### 28.1 Live-Ops Felsefesi
7 günlük sezon yapısı live-ops için **hazır bir iskelet** sunuyor. Her sezon bir tema, her ay bir büyük etkinlik.

### 28.2 Sezon Temaları (Rotasyon)

| Tema | İçerik | Süre |
|---|---|---|
| **Genç Kan** | Akademi bonusları, genç oyuncu kart seti, U21 turnuvası | 7 gün |
| **Transfer Çılgınlığı** | İndirimli bonservis, ekstra scout, transfer görevleri | 7 gün |
| **Kupa Haftası** | Ekstra kupa turnuvası, yüksek ödül | 7 gün |
| **Kriz Yönetimi** | Zor kart havuzu, yüksek risk-yüksek ödül | 7 gün |
| **Efsaneler** | Emekli oyuncular geri döner (özel kart zinciri) | 7 gün |
| **Derbi Sezonu** | Rakip kulüp sistemi, derbi maçları çift puan | 7 gün |
| **Altyapı Devrimi** | Tesis inşa indirimi, hızlı inşaat | 7 gün |
| **Taraftar Ayaklanması** | Taraftar odaklı kartlar ve ödüller | 7 gün |

### 28.3 Yıllık Takvim (Gerçek Dünya Bağlantılı)

| Dönem | Etkinlik | Neden |
|---|---|---|
| Ağustos | "Yeni Sezon" büyük etkinlik | Gerçek liglerin başlangıcı, futbol ilgisi zirvede |
| Eylül–Ekim | Milli takım arası temalar | Gerçek dünya senkronu |
| Kasım | "Transfer Hazırlığı" | Ocak transfer dönemi beklentisi |
| Aralık | Yılbaşı etkinliği, hediye takvimi | Mevsimsel, yüksek harcama dönemi |
| Ocak | "Transfer Dönemi" büyük etkinlik | Gerçek transfer dönemi hype'ı |
| Şubat–Mart | Kıta kupası temaları | Gerçek Avrupa kupaları |
| Nisan–Mayıs | "Şampiyonluk Yarışı" | Gerçek lig finalleri |
| Haziran–Temmuz | Büyük turnuva etkinliği (yıla göre) | Dünya Kupası/Avrupa Şampiyonası yıllarında zirve |

### 28.4 Haftalık Live-Ops Kadansı

| Gün | Aktivite |
|---|---|
| Pazartesi | Yeni sezon + tema duyurusu, sıralamalar sıfırlanır |
| Salı | Günlük görev seti yenilenir |
| Çarşamba | "Haftanın Oyuncusu" topluluk oylaması |
| Perşembe | Ara ödül (mid-season reward) |
| Cuma | Hafta sonu etkinliği başlar (çift XP veya çift gelir) |
| Cumartesi | Deadline Day (transfer indirimleri) |
| Pazar | Sezon finali, ödül dağıtımı |

### 28.5 Aylık İçerik Güncellemesi (Minimum)
- 40–60 yeni karar kartı
- 3–5 yeni kart zinciri
- 1 yeni tesis veya sistem genişletmesi
- 8–12 yeni kozmetik
- Denge ayarları
- 1 topluluk etkinliği

### 28.6 Live-Ops Ölçüm
Her etkinlik sonrası ölçülür:
- Katılım oranı (DAU'nun %'si)
- DAU artışı (etkinlik öncesi/sonrası)
- Gelir etkisi
- Retention etkisi (etkinlik katılanların D+7 retention'ı)
- Tamamlama oranı

**Kural:** Katılım < %35 olan etkinlik formatı tekrarlanmaz.

---
---

# EKLER

## EK A — KARAR KARTI KÜTÜPHANESİ

50 örnek kart. Bunlar hem içerik hem **yazım standardı referansı**. Her kart §12.10 kurallarına uygun.

> Format: **[Kategori]** Konuşan · "Metin" → Seçenekler (etkiler)

### A.1 Kadro / Soyunma Odası

**1. [Kadro] Yıldız oyuncu, zam talebi**
"Hocam, ben bu takımda en çok koşan adamım ama maaşta üçüncü sıradayım. Bu doğru mu?"
- ◀ *"Haklısın, düzeltiyorum"* → Kasa −(maaş×0.35×12), Soyunma +6, oyuncu moral +18, sadakat +8
- ▶ *"Sahada göster, sonra konuşuruz"* → Soyunma −5, oyuncu moral −12, **zincir başlar:** `star_unhappy_arc`
- 🔒 *[Motivatör 3] "Bu takım sensiz olmaz, biliyorsun"* → Soyunma +4, moral +10, para yok

**2. [Kadro] Kadro dışı kalan tecrübeli**
"Üç maçtır kulübedeyim. Ben burada ne yapıyorum?"
- ◀ *"Sıran gelecek"* → moral −4, 3 maç sonra tekrar sorar
- ▶ *"Formunu kaybettin"* → moral −14, Soyunma −3, ama diğer oyuncular "adaletli" görür → Soyunma +5 (net +2)
- ▶ *"Seni satılık listesine koyuyorum"* → moral −20, transfer değeri −%15, kadro yeri açılır

**3. [Kadro] İki oyuncu antrenmanda kavga etti**
Yardımcı antrenör: "Osman'la Kaan birbirine girdi. Ayırdık ama ortalık gergin."
- ◀ *İkisini de cezalandır* → ikisinin morali −10, Soyunma +4 (disiplin), Taraftar +2
- ▶ *Sadece başlatanı cezalandır* → başlatan −16, diğeri +6, Soyunma +2
- ▶ *Kapat gitsin* → Soyunma −6, %30 ihtimalle tekrar olur (zincir)

**4. [Kadro] Kaptan seçimi**
"Kaptanlık pazubandı boşta. Kimin kolunda görmek istersin?"
- Seçenekler: kadrodan 3 aday (en tecrübeli / en yüksek moral / en genç yetenek)
- Her seçim farklı: tecrübeli → Soyunma +6; genç → uzun vadeli gelişim +, kısa vadede Soyunma −3

**5. [Kadro] Yedek kalecinin isyanı**
"Bir sezondur oynamadım. Kariyerim bitiyor."
- ◀ *Kupa maçlarında oynat sözü ver* → moral +12, **söz tutulmazsa** Soyunma −10 (commitment)
- ▶ *"Kabullen"* → moral −18, transfer talebi olasılığı ↑

**6. [Kadro] Genç oyuncu gece hayatı**
Basın: "18 yaşındaki Kaan gece kulübünde görüntülendi."
- ◀ *Cezalandır, kadro dışı* → çocuk moral −15, Soyunma +5, Taraftar +3
- ▶ *Özel konuş, kamuoyuna savun* → Taraftar −4, çocuk sadakat +20, Soyunma +3
- ▶ *Görmezden gel* → Soyunma −5, tekrar olma ihtimali %55

**7. [Kadro] Emekliliğe yaklaşan efsane**
38 yaşındaki Osman: "Bu benim son sezonum. Bir maç daha oynayabilir miyim?"
- ◀ *Son maçta 11'e koy* → Taraftar +12, Soyunma +8, o maçta performans riski
- ▶ *"Takımı düşünmeliyim"* → Taraftar −6, Soyunma −4, ama sportif doğru

**8. [Kadro] Takım içi klik**
"Yabancı oyuncular ayrı, yerliler ayrı oturuyor yemekhanede."
- ◀ *Takım aktivitesi düzenle (₣15K)* → Kasa −15K, Takım Uyumu +8
- ▶ *Kaptana havale et* → Kaptan kişiliğine göre %60 çözülür
- ▶ *Görmezden gel* → Takım Uyumu −6

### A.2 Basın / Medya

**9. [Basın] Ağır yenilgi sonrası**
Gazeteci Nihal Aksu: "5-0. Bu takımın bu ligde işi var mı gerçekten?"
- ◀ *"Sorumluluk bende"* → Soyunma +8, Yönetim −3, Taraftar +2
- ▶ *"Oyuncularım yeterince istekli değildi"* → Soyunma −12, Yönetim +2, Taraftar +4
- ▶ *"Hakem maçı katletti"* → Taraftar +8, Yönetim −5, **disiplin cezası riski %35**

**10. [Basın] Rakip teknik direktör laf attı**
"Rakibiniz 'onlar bu ligde misafir' dedi. Cevabınız?"
- ◀ *Sert cevap ver* → Taraftar +7, sonraki maçta rakip motivasyonu +, kaybedersen Taraftar −12
- ▶ *"Sahada konuşuruz"* → nötr, Yönetim +2
- 🔒 *[Zihin Oyunları 2] Zekice bir alay* → Taraftar +10, rakip −%3

**11. [Basın] Transfer dedikodusu**
"Yıldız oyuncunuzun büyük bir kulüple görüştüğü konuşuluyor. Doğru mu?"
- ◀ *"Satılık değil"* → oyuncu moral +6, teklif gelirse pazarlık gücü −
- ▶ *"Her oyuncunun bir fiyatı var"* → oyuncu moral −8, gelen teklifler +%20

**12. [Basın] Kişisel saldırı**
"Bir yorumcu 'bu adam bu işi bilmiyor' dedi."
- ◀ *Cevap ver* → Taraftar +3, Yönetim −4, basın ilişkisi −
- ▶ *Sessiz kal* → nötr, Menajer XP +30 ("olgunluk")

### A.3 Yönetim / Başkan

**13. [Yönetim] Başkanın akrabası**
Başkan Recep Vardar: "Yeğenim futbol oynuyor. Bir bak istersen. İyi çocuktur."
- ◀ *Kadroya al* → Yönetim +12, Soyunma −8, kadroya 1★ oyuncu eklenir
- ▶ *"Deneme yapalım"* → Yönetim +4, çocuğun gerçek yeteneği %20 ihtimalle iyi çıkar
- ▶ *Reddet* → Yönetim −10, Soyunma +6

**14. [Yönetim] Bütçe kesintisi**
"Bu sezon transfer bütçen %40 azaldı. İdare et."
- ◀ *"Anlıyorum"* → Yönetim +5, bütçe −%40
- ▶ *"Bu şartlarda hedef tutmam"* → Yönetim −6, bütçe −%20 (pazarlık başarılı)
- 🔒 *[Sponsor Sihirbazı 3] "Ben sponsor bulurum"* → bütçe korunur, Kasa +

**15. [Yönetim] Hedef değişikliği**
"Beklentimiz artıyor. Bu sezon şampiyonluk istiyoruz."
- ◀ *Kabul et* → Yönetim +8, ama sezon hedefi zorlaşır (tutmazsa −20)
- ▶ *"İlk 3 gerçekçi"* → Yönetim −3, hedef makul kalır

**16. [Yönetim] Stadyum satışı teklifi**
"Bir yatırımcı stadyum isim hakkını satın almak istiyor. ₣400.000."
- ◀ *Kabul* → Kasa +400K, Taraftar −15 ("stadımızın adı satıldı")
- ▶ *Reddet* → Taraftar +8, Yönetim −5

### A.4 Taraftar / Ultra

**17. [Taraftar] Bilet zammı**
Yönetim: "Bilet fiyatlarını %20 artırmayı düşünüyoruz."
- ◀ *Onayla* → Kasa geliri +%18, Taraftar −12
- ▶ *Karşı çık* → Kasa aynı, Taraftar +8, Yönetim −4

**18. [Taraftar] Ultra grubu ziyaret**
"Baba" (ultra lideri): "Hocam bize bir söz ver. Ne olursa olsun savaşacak mısınız?"
- ◀ *Söz ver* → Taraftar +10, kaybederseniz Taraftar −8 ekstra
- ▶ *"Söz vermem, çalışırız"* → Taraftar +2, dürüstlük → uzun vadede +

**19. [Taraftar] Protesto**
"Taraftarlar antrenman tesisinin önünde toplandı."
- ◀ *Dışarı çık, konuş* → Taraftar +12, Soyunma −3, %20 riskli olay
- ▶ *Polis çağır* → Taraftar −20, Yönetim +5
- ▶ *Bekle geçsin* → Taraftar −6

**20. [Taraftar] Efsane oyuncunun forması**
"Emekli olan Osman'ın 10 numarasını emekliye ayıralım mı?"
- ◀ *Evet* → Taraftar +8, 10 numara bir daha kullanılamaz
- ▶ *Hayır* → nötr

### A.5 Transfer / Menajerler

**21. [Transfer] Agent baskısı**
Oyuncu menajeri: "Müvekkilim için başka teklifler var. 48 saatiniz var."
- ◀ *Teklifi artır* → Kasa −, transfer tamamlanır
- ▶ *Blöf gör* → %45 ihtimalle oyuncu gider, %55 fiyat düşer

**22. [Transfer] Komisyon isteği**
Agent: "Anlaşma olursa bana %10 komisyon lazım. Kayıt dışı."
- ◀ *Kabul* → transfer ucuzlar ama **skandal zinciri riski %25**
- ▶ *Reddet* → transfer +%8 pahalı, temiz kalırsın, Yönetim +3

**23. [Transfer] Bedava oyuncu**
"33 yaşında ama hâlâ kaliteli bir 10 numara serbest kaldı."
- ◀ *İmzala* → Kadroya güçlü ama yaşlı oyuncu, maaş yükü
- ▶ *Geç* → gençlere yer kalır

**24. [Transfer] Rakip kulüpten teklif**
"Rakibiniz yıldızınız için ₣2.4M teklif etti. Piyasa değerinin %140'ı."
- ◀ *Sat* → Kasa +2.4M, Taraftar −18, Soyunma −8
- ▶ *Reddet* → Taraftar +10, oyuncu moral −10 (kariyer fırsatı kaçtı)

### A.6 Tıbbi

**25. [Tıbbi] Riskli oyuncu**
Doktor: "Kaptanın kası tam iyileşmedi. Oynarsa %40 sakatlanır ama derbi var."
- ◀ *Oynat* → %40 sakatlık (4–8 hafta), oynarsa performans +
- ▶ *Dinlendir* → güvenli, Soyunma +2, maç gücü −
- 🔒 *[Tıbbi Merkez Sv.4] Özel program* → risk %15'e düşer

**26. [Tıbbi] Ağır sakatlık**
"Genç yıldızın çapraz bağları koptu. 6 ay yok."
- ◀ *Özel tedavi (₣80K)* → süre −%30, oyuncu sadakat +25
- ▶ *Standart tedavi* → normal süre
- ▶ *Sözleşmesini feshet* → Kasa tasarrufu, Soyunma −20, Taraftar −10

### A.7 Finans / Sponsorluk

**27. [Finans] Bahis şirketi sponsorluğu**
"Bir bahis şirketi forma göğsü için üç katı ödemek istiyor."
- ◀ *Kabul* → Kasa gelir ×3, Taraftar −10, **sonraki bahis kartlarında risk ↑**
- ▶ *Reddet* → normal sponsor, Taraftar +6, Menajer XP +50

**28. [Finans] Mali denetim**
"Federasyon mali kayıtlarınızı inceliyor."
- ◀ *Tam şeffaflık* → temizsen Yönetim +8; değilse ceza
- ▶ *Avukat tut (₣50K)* → risk azalır

**29. [Finans] Kredi teklifi**
"Banka ₣500.000 kredi veriyor. Haftalık ₣12.000 geri ödeme, 50 hafta."
- ◀ *Al* → Kasa +500K, 50 hafta borç yükü
- ▶ *Alma* → nötr

### A.8 Altyapı / Gençlik

**30. [Altyapı] Yetenekli çocuk, zor aile**
"14 yaşında müthiş bir çocuk var ama babası 'okulunu bitirsin' diyor."
- ◀ *Aileyi ikna et (₣20K burs)* → çocuk akademiye katılır, potansiyel yüksek
- ▶ *Bekle* → %40 ihtimalle rakip kulüp alır

**31. [Altyapı] Akademi mezunu ilk 11'de**
"Bizim çocuk ilk kez 11'de. Tribün deli oluyor."
- ◀ *Oynat* → Taraftar +8, çocuk gelişim ×1.5, performans riski
- ▶ *Yedek başlat* → güvenli

### A.9 Kişisel (Menajer RPG)

**32. [Kişisel] Rakip kulüpten teklif**
"Lig 6'daki bir kulüp seni istiyor. Maaş 3 katı."
- ◀ *Git* → **kulüp değişir**, kadro/tesis kalır, yeni başlangıç
- ▶ *Kal* → Taraftar +15, Yönetim +10, oyuncu sadakati +

**33. [Kişisel] Sağlık uyarısı**
Doktor: "Tansiyonun yüksek. Biraz yavaşlamalısın."
- ◀ *Dinlen (1 maç asistan yönetsin)* → o maçta −%10, sonraki 5 maçta +%3
- ▶ *Devam* → %15 ihtimalle daha ciddi olay (zincir)

**34. [Kişisel] Aile**
"Kızının doğum günü, maçla aynı gün."
- ◀ *Maça git* → nötr sportif, Menajer "denge" istatistiği −
- ▶ *Doğum gününe git* → o maç asistan yönetir, Menajer XP +100, kişisel zincir +

### A.10 Kriz

**35. [Kriz] Şike iddiası**
"Bir oyuncunuzun bahis sitesinde hesabı olduğu ortaya çıktı."
- ◀ *Kendi soruşturmanı yap* → 3 gün sonra sonuç zinciri
- ▶ *Federasyona bildir* → Yönetim +10, Taraftar −5, oyuncu ceza alır
- ▶ *Ört bas* → **%40 ihtimalle patlar:** Yönetim −30, Taraftar −25

**36. [Kriz] Taraftar olayı**
"Deplasmanda taraftarlarımız olay çıkardı. Federasyon ceza kesecek."
- ◀ *Taraftarı savun* → Taraftar +12, Yönetim −8, ceza ağırlaşır
- ▶ *Kınama açıkla* → Taraftar −10, Yönetim +6, ceza hafifler

### A.11 Ek Kart Fikirleri (Kısa Liste — Geliştirilecek)

37. Yeni transferin uyum sorunu
38. Antrenör kadrosunda çatışma
39. Yağmur nedeniyle saha bozuk — maç ertelensin mi
40. Bir oyuncu dini/kültürel izin istiyor
41. Sosyal medyada oyuncunun paylaşımı tartışma yarattı
42. Rakip scout'u antrenmanınızı izliyor
43. Eski oyuncunuz rakip takıma transfer oldu — açıklama
44. Yerel bir hayır kurumu destek istiyor
45. Formaların tedarikçisi değişiyor — tasarım seçimi
46. Belediye stadyum kirasını artırdı
47. Bir taraftar grubu forma tasarımına karşı çıkıyor
48. Kaleci ile defans arasında iletişim sorunu
49. Bir oyuncu askerlik/vize sorunu yaşıyor
50. Sezon sonu kutlama bütçesi

> Bu 50 kart MVP'nin **%25'i**. Kalan 150 kart bu şablonların bağlamsal varyasyonları ve yeni fikirlerle üretilir.

---
## EK B — VERİ ŞEMALARI

### B.1 Karar Kartı JSON Şeması

```json
{
  "$schema": "dynastyxi/card/v1",
  "id": "string (unique, snake_case)",
  "category": "squad|press|board|fans|transfer|medical|finance|youth|personal|crisis",
  "weight": 1.0,
  "rarity": "common|uncommon|rare|epic",
  "actor": {
    "type": "player|npc|staff|generic",
    "selector": "topRated|lowestMorale|captain|youngest|random|npc:president",
    "filters": { "minRating": 0, "maxAge": 99, "position": "ST" }
  },
  "prerequisites": {
    "minSeason": 1,
    "maxSeason": 99,
    "leagueTierMax": 20,
    "leagueTierMin": 1,
    "requiresFacility": { "id": "academy", "minLevel": 2 },
    "requiresMeter": { "board": { "max": 40 } },
    "requiresSquad": { "minPlayers": 16, "hasPersonality": "ego" },
    "requiresFlag": ["signed_star_player"],
    "excludesFlag": ["already_fired_once"]
  },
  "trigger": {
    "event": "match_lost|match_won|season_start|transfer_window|injury|none",
    "chance": 0.35
  },
  "title": "l10n.card.star_wage.title",
  "text": "l10n.card.star_wage.text",
  "image": "portraits/dynamic",
  "options": [
    {
      "id": "accept",
      "label": "l10n.card.star_wage.opt_accept",
      "requires": { "cashMin": 25000, "managerPerk": null },
      "effects": [
        { "type": "meter", "target": "cash",       "value": -25000 },
        { "type": "meter", "target": "lockerRoom", "value": 6 },
        { "type": "player", "target": "{actor}", "field": "morale", "value": 18 },
        { "type": "flag", "set": "gave_raise_to_star" },
        { "type": "chain", "start": "star_loyalty_arc", "delayHours": 72 }
      ],
      "resultText": "l10n.card.star_wage.result_accept"
    }
  ],
  "cooldownDays": 6,
  "maxPerSeason": 2,
  "maxLifetime": 0,
  "tags": ["wage", "star", "morale"]
}
```

### B.2 Zincir (Chain) Şeması

```json
{
  "id": "academy_kid_arc",
  "title": "l10n.chain.academy_kid.title",
  "steps": [
    { "cardId": "academy_kid_01", "delayHours": 0 },
    { "cardId": "academy_kid_02", "delayHours": 48, "requiresChoice": "accept" },
    { "cardId": "academy_kid_03", "delayHours": 72 },
    {
      "branch": {
        "condition": "chainVar.kidPerformance > 7.0",
        "ifTrue":  "academy_kid_04a",
        "ifFalse": "academy_kid_04b"
      },
      "delayHours": 24
    }
  ],
  "variables": { "kidPlayerId": null, "kidPerformance": 0 },
  "abandonAfterDays": 7,
  "abandonCard": "academy_kid_abandon",
  "rewards": { "managerXp": 120, "flag": "raised_a_kid" }
}
```

### B.3 Denge Konfigürasyonu Şeması

```json
{
  "version": 12,
  "sim": {
    "baseAttackChance": 0.155,
    "baseXg": 0.085,
    "possessionExponent": 1.35,
    "possessionClamp": [0.22, 0.78],
    "homeAdvantageBase": 0.04,
    "fatigueStartMinute": 60,
    "fatiguePerMinute": 0.004
  },
  "economy": {
    "facilityCostGrowth": 3.9,
    "facilityTimeGrowth": 2.7,
    "maintenanceRate": 0.0085,
    "wageToValueRatio": 0.0038,
    "agentFeeRate": 0.08,
    "targetProfitMargin": [0.14, 0.20]
  },
  "growth": {
    "baseGrowthRate": 0.18,
    "ageMultipliers": { "15": 1.6, "18": 1.3, "23": 0.6, "27": -0.3, "31": -0.9 },
    "minutesFullEffect": 1200
  },
  "meters": {
    "warningThreshold": 30,
    "criticalThreshold": 15,
    "graceMatches": 3,
    "boardDecayRate": 1.0
  },
  "cards": {
    "perSession": 2,
    "maxActiveChains": 3,
    "recentMemory": 40,
    "categoryFatigueFactor": 0.35,
    "categoryRecoveryFactor": 1.25,
    "noveltyBonus": 1.9
  }
}
```

### B.4 Oyuncu Kayıt Şeması (Isar)

```dart
@collection
class PlayerEntity {
  Id id = Isar.autoIncrement;
  @Index(unique: true) late String uid;

  late String firstName, lastName, countryCode;
  late int birthSeason;
  @enumerated late Position position;
  late List<int> altPositions;

  late int pace, technique, shooting, passing, defending, physical, mentality;
  late int potential, consistency, injuryProneness, growthCurve;
  @enumerated late PersonalityType personality;

  late int morale, fitness, form, sharpness;
  int? injuryDaysLeft;
  @enumerated InjurySeverity? injurySeverity;

  late int weeklyWage, contractSeasonsLeft, releaseClause;
  late bool isYouthProduct, isTransferListed;
  late int appearances, goals, assists, cleanSheets;
  late List<int> seasonRatings;

  late String faceSeed;   // yüz kompozisyonu için deterministik seed
}
```

### B.5 Kayıt Dosyası Sürümleme

```dart
class SaveMeta {
  final int schemaVersion;     // artan tamsayı
  final String engineVersion;  // sim motoru sürümü
  final String appVersion;
  final int savedAtEpochMs;
  final String hmac;           // bütünlük imzası
}

// Migration zinciri
final migrations = <int, Migration>{
  1: V1ToV2(),   // örn: "sharpness" alanı eklendi, varsayılan 100
  2: V2ToV3(),   // örn: tesis id'leri yeniden adlandırıldı
};
```
**Kural:** Şema değişikliği asla veri silmez. Yeni alanlar varsayılan değerle gelir. Geriye dönük 3 sürüm desteklenir; daha eskisi buluttan yeniden oluşturulur.

---

## EK C — FORMÜL SAYFASI

Tüm kritik formüller tek yerde. Denge ayarı yaparken buraya bak.

### C.1 Oyuncu
```
OVR              = Σ(özellik_i × pozisyonAğırlığı_i)
Yıldız           = OVR bandına göre 1★–5★+
Değer            = 1.35^((OVR-40)/4.2) × 1000 × yaşÇ × potansiyelÇ × sözleşmeÇ × formÇ × ligÇ
BeklenenMaaş     = Değer × 0.0038 × egoÇ × ligÇ
SezonGelişimi    = (Pot−OVR)×0.18 × yaşÇ × tesisÇ × oynamaÇ × moralÇ × rastgele(0.80–1.25)
SakatlıkOlasılığı= 0.030 × (1+prone/100) × (2−fit/100) × tıbbiÇ × taktikÇ × yaşÇ
MaçPuanı         = 6.0 + katkılar − cezalar ± (100−consistency)/45
```

### C.2 Takım
```
AtakGücü      = Σ(oyuncuKatkı × ofansifAğırlık) × formaÇ
DefansGücü    = Σ(oyuncuKatkı × defansifAğırlık) × formaÇ
formaÇ        = takımUyumu × moralOrt × fitnessOrt × taktikUyumu × evSahibi × menajer
TakımUyumu    = 100 − cezalar + bonuslar          → çarpan 0.88–1.08
evSahibiBonusu= 1.00 + 0.04 + stadyumSv×0.012 + memnuniyet/1000
```

### C.3 Maç
```
possA         = ortaA^1.35 / (ortaA^1.35 + ortaB^1.35), clamp(0.22, 0.78)
atakOlasılık  = poss × 0.155 × tempoÇ × yorgunlukÇ
yorgunlukÇ(m) = 1 − max(0, m−60) × 0.004 × (1 − fitOrt/150)
xG            = clamp(0.085 × (Atak/Defans)^0.9 × şutTipiÇ × mentalityÇ, 0.02, 0.62)
golOlasılık   = xG × (1 − (kaleci.OVR − 55) × 0.0055)
```

### C.4 Ekonomi
```
biletGeliri     = kapasite × doluluk × biletFiyatı
doluluk         = clamp(0.35 + memnuniyet/220 + sıraBonusu − fiyatEsnekliği, 0.15, 1.00)
önerilenFiyat   = 6 + (21 − ligKademesi) × 2.4
yayınGeliri     = ligTablosu[lig] × (1 + (6 − min(sıra,6)) × 0.04)
mağazaGeliri    = taraftarSayısı × mağazaSvÇ × (memnuniyet/100)
tesisMaliyet    = tabanMaliyet × 3.9^(sv−1) × bölgeÇ
tesisSüre       = tabanSüre × 2.7^(sv−1), maks 48 sa
bakım           = maliyet × 0.0085 (haftalık)
```

### C.5 İlerleme
```
KulüpXP    = Σ(tesisSv × 100) + galibiyet×25 + kupa×2000 + terfi×5000
KulüpSv    = floor(sqrt(KulüpXP / 180)) + 1, maks 50
MenajerXP  = eylem tablosu (§13.3)
GerekliXP(n)= 320 × n^1.62
İtibar     = Σ(maçPuanları) + kupa×150 + terfi×80 + hedef×60 − kovulma×120 + akademi×40
HanedanPuanı= ligBonusu + kupa×40 + sezon×8 + efsane×25 + maksDeğer/500000
```

### C.6 Kartlar
```
kartAğırlığı = taban × kategoriYorgunluğu × bağlamBoost × göstergeBaskısı
               × yenilikBonusu × sezonUygunluğu
kategoriYorgunluğu: seçilince ×0.35, her yeni kartta ×1.25 (maks 1.0)
yenilikBonusu: hiç görülmemiş ×1.9, 1 kez ×1.3, 2+ ×1.0
YönetimDeğişimi = clamp(sapma×1.8, −14, +10) + kupa + mali + basın + transfer
```

### C.7 Pazarlık
```
kabulOlasılığı = clamp((teklif/istenen)^2.4 × prestijÇ × ilişkiÇ, 0.02, 0.97)
sabırDüşüşü    = (1 − teklif/istenen) × 45
```

### C.8 Retention Modeli
```
R(d)     = R1 × d^(−k)          [power-law]
LTV(N)   = ARPDAU × Σ(d=1..N) R(d)
Payback  = CPI / (ARPDAU × ortalama günlük aktif oran)
```

---

## EK D — İSİM VE İÇERİK HAVUZLARI

### D.1 Türkçe İsim Havuzu (örneklem)

**Erkek adları (200+ hedef, örnek 40):**
Ahmet, Mehmet, Mustafa, Emre, Burak, Kaan, Arda, Cem, Deniz, Efe, Ege, Eren, Furkan, Hakan, Halil, İbrahim, Kerem, Koray, Levent, Mert, Murat, Onur, Ozan, Özgür, Sercan, Serkan, Sinan, Taner, Tolga, Uğur, Ümit, Volkan, Yiğit, Yusuf, Barış, Berk, Can, Doruk, Gökhan, Alper

**Soyadları (300+ hedef, örnek 40):**
Yılmaz, Demir, Kaya, Şahin, Çelik, Yıldız, Yıldırım, Öztürk, Aydın, Özdemir, Arslan, Doğan, Kılıç, Aslan, Çetin, Kara, Koç, Kurt, Özkan, Şimşek, Polat, Korkmaz, Erdoğan, Bulut, Güneş, Karaca, Aksoy, Turan, Sarı, Ateş, Bozkurt, Çakır, Duman, Ekinci, Gül, Işık, Kaplan, Mert, Sönmez, Tekin

**Kulüp adı şablonları:**
```
{şehir}spor           → Angoraspor, Bursaspor benzeri (kurgusal şehir kullan)
{şehir} Gücü          → Selçuk Gücü
{şehir} FK            → Meriç FK
{şehir} Birlik        → Karadeniz Birlik
{şehir} {simge}spor   → Karşıyakaspor benzeri
{simge} {şehir}       → Şimşek Adana
```
**⚠ Uyarı:** Gerçek kulüp isimleriyle **çakışmayan** kombinasyonlar üretilmeli. Üretim sonrası bir "yasaklı isim listesi" (dünya çapında ilk 500 kulüp) ile filtrelenmeli.

**Kurgusal şehir havuzu (TR bölgesi, 60 hedef, örnek 15):**
Angora, Meriç, Selçuk, Karaköy, Yeşilova, Akdeniz, Toros, Sakarya, Fırat, Dicle, Ege, Marmara, Anadolu, Çukurova, Karadeniz

### D.2 Uluslararası Havuzlar
Aynı yapı 20 ülke için: BR, AR, ES, FR, IT, DE, EN, PT, NL, BE, RS, HR, RU, UA, PL, NG, GH, SN, MA, JP, KR

Her ülke dosyası:
```json
{
  "code": "BR",
  "displayName": "Brezilya",
  "firstNames": ["Gabriel", "Lucas", "Matheus", "..."],
  "lastNames": ["Silva", "Santos", "Oliveira", "..."],
  "nicknameChance": 0.45,
  "nicknames": ["Ronaldinho benzeri kurgusal takma adlar"],
  "attributeBias": { "technique": 4, "pace": 2, "physical": -2 },
  "commonPositions": { "ST": 1.2, "AM": 1.3, "CB": 0.9 }
}
```
**Ülke bias'ı** dünyayı canlı hissettirir — Brezilya'dan teknik, Almanya'dan disiplinli, Afrika'dan fiziksel oyuncular çıkması, oyuncunun scout stratejisi kurmasını sağlar (ve stereotip riskini yönetmek için **hafif** tutulmalı: maks ±4 puan).

### D.3 Tekrar Eden NPC Kadrosu (El Yazımı, 12 Karakter)

| NPC | Rol | Kişilik | Fonksiyon |
|---|---|---|---|
| **Recep Vardar** | Başkan | Duygusal, popülist, sabırsız | Yönetim kartları, hedefler |
| **Nihal Aksu** | Baş gazeteci | Keskin, adil ama acımasız | Basın kartları |
| **"Baba" Kadir** | Ultra lideri | Sadık, tehditkâr, samimi | Taraftar kartları |
| **Ayşe Tanrıkulu** | Kulüp doktoru | Titiz, uyarıcı | Tıbbi kartlar |
| **Selim Aydoğan** | Asistan menajer | Sadık, gerçekçi | Tavsiye, sen yokken yönetir |
| **Hatice Ergin** | Baş scout | Sezgisel, gizemli | Scout raporları |
| **Nazım Bey** | Altyapı hocası | Sabırlı, idealist | Akademi kartları |
| **Serdar Koçak** | Mali müşavir | Soğuk, sayısal | Finans kartları |
| **Bülent Tosun** | Oyuncu menajeri (agent) | Kurnaz, ısrarcı | Transfer kartları |
| **Zeynep Arık** | Sponsorluk direktörü | Profesyonel, hırslı | Sponsor kartları |
| **Cemal Usta** | Saha bakım sorumlusu | Yaşlı, bilge, kulüp hafızası | Nostalji/moral kartları |
| **Deniz Aktaş** | Sosyal medya sorumlusu | Genç, panik | Modern kriz kartları |

> Bu NPC'ler oyunun **duygusal omurgasıdır**. Aynı yüzleri 100 sezon boyunca görmek, kulübü "ev" hissettirir.

---

## EK E — ANALYTICS EVENT SÖZLÜĞÜ

### E.1 Yaşam Döngüsü
| Event | Parametreler |
|---|---|
| `app_first_open` | `install_source`, `device_tier`, `os` |
| `session_start` | `source` (organic/push/deeplink), `session_number` |
| `session_end` | `duration_sec`, `actions_count`, `open_loops` |
| `day1_return` … `day30_return` | `days_since_install` |

### E.2 FTUE
| Event | Parametreler |
|---|---|
| `ftue_step_complete` | `step_index`, `step_name`, `time_sec` |
| `ftue_club_created` | `club_name_custom` (bool), `color_choice` |
| `ftue_first_match_end` | `result`, `mode` |
| `ftue_first_signing` | `player_ovr`, `method` |
| `ftue_first_build` | `facility_id` |
| `ftue_complete` | `total_time_sec`, `skipped` |
| `ftue_abandon` | `last_step`, `time_sec` |

### E.3 Çekirdek Oyun
| Event | Parametreler |
|---|---|
| `match_start` | `mode` (fast/live), `league_tier`, `opponent_ovr_diff`, `season`, `matchday` |
| `match_end` | `result`, `score_home`, `score_away`, `xg_home`, `xg_away`, `duration_sec` |
| `match_live_decision` | `moment_type`, `option_chosen`, `time_to_decide_ms` |
| `match_skipped` | `reason` (window_missed/auto) |
| `card_shown` | `card_id`, `category`, `chain_id`, `is_first_time` |
| `card_choice_made` | `card_id`, `option_id`, `time_to_decide_ms`, `meter_deltas` |
| `chain_start` / `chain_complete` / `chain_abandon` | `chain_id`, `steps_completed` |
| `meter_critical` | `meter`, `value` |
| `manager_warned` | `board_value`, `matches_remaining` |
| `manager_sacked` | `season`, `league_tier`, `days_played`, `matches` |
| `manager_rehired` | `new_club_tier`, `offers_shown` |

### E.4 İlerleme
| Event | Parametreler |
|---|---|
| `season_start` | `season_number`, `league_tier`, `board_target` |
| `season_complete` | `season_number`, `final_position`, `promoted`, `relegated`, `target_met` |
| `promotion` / `relegation` | `from_tier`, `to_tier` |
| `facility_upgrade_start` | `facility_id`, `to_level`, `cost`, `duration_sec` |
| `facility_upgrade_complete` | `facility_id`, `level`, `speedup_used` |
| `manager_level_up` | `new_level`, `days_since_install` |
| `skill_unlocked` | `skill_id`, `branch`, `tier` |
| `prestige_start` | `seasons_played`, `dynasty_points_earned` |

### E.5 Transfer
| Event | Parametreler |
|---|---|
| `transfer_search` | `filters_used`, `results_count` |
| `scout_assign` | `region`, `focus`, `duration_h` |
| `scout_report` | `player_ovr_est`, `potential_range`, `is_hidden_gem` |
| `negotiation_start` | `player_id`, `asking_price`, `player_ovr` |
| `negotiation_offer` | `round`, `offer_ratio`, `clauses_used` |
| `negotiation_end` | `outcome` (accepted/rejected/walked), `rounds`, `final_price` |
| `transfer_complete` | `direction` (in/out), `fee`, `player_ovr`, `player_age`, `channel` |
| `contract_renewed` / `contract_expired` | `player_id`, `wage_change_pct` |

### E.6 Ekonomi
| Event | Parametreler |
|---|---|
| `currency_earned` | `currency`, `amount`, `source`, `balance_after` |
| `currency_spent` | `currency`, `amount`, `sink`, `balance_after` |
| `economy_snapshot` (günlük) | `cash`, `weekly_income`, `weekly_expense`, `squad_value`, `league_tier` |

### E.7 Monetizasyon
| Event | Parametreler |
|---|---|
| `shop_open` | `entry_point` |
| `offer_shown` | `offer_id`, `trigger`, `price_usd`, `personalized` |
| `offer_dismissed` | `offer_id`, `time_shown_ms` |
| `purchase_initiate` | `product_id`, `price_usd`, `context` |
| `purchase_complete` | `product_id`, `price_usd`, `is_first_purchase`, `days_since_install` |
| `purchase_failed` | `product_id`, `error_code` |
| `subscription_start` / `renew` / `cancel` | `product_id`, `period` |
| `battlepass_purchase` | `season_number`, `tier_at_purchase` |
| `battlepass_tier_complete` | `tier`, `is_premium` |
| `ad_request` / `ad_shown` / `ad_completed` / `ad_failed` | `placement`, `network`, `reward_type` |

### E.8 Teknik
| Event | Parametreler |
|---|---|
| `app_crash` | (Crashlytics otomatik) |
| `performance_frame_drop` | `screen`, `dropped_frames`, `device_tier` |
| `load_time` | `screen`, `duration_ms` |
| `sync_conflict` | `resolution` |
| `cheat_detected` | `type`, `action_taken` |

### E.9 Event Hijyeni Kuralları
- Toplam event tipi ≤ 80 (fazlası analiz edilemez)
- Her event'in bir "sahibi" var (kim bu veriye bakacak?)
- 90 gün kullanılmayan event kaldırılır
- Yüksek hacimli eventler (`card_shown`) örneklenebilir (%25 sampling)
- PII asla parametre olamaz

---

## EK F — SSS

### 🎮 Oyun Tasarımı

**S: Neden 7 günlük sezon? 30 günlük sezon daha gerçekçi olmaz mı?**
C: Gerçekçilik değil, ritim aradık. 7 gün = takvimle senkron, D7 retention noktası tam bir sezon tamamlanmasına denk geliyor ve haftalık live-ops iskeleti bedava geliyor. 30 günlük sezonda oyuncu D7'de hiçbir şey tamamlamamış olur — retention açısından felaket. (§6.2)

**S: Enerji sistemi olmadan oyuncular içeriği çok hızlı tüketmez mi?**
C: Tüketim hızını enerji yerine **maç penceresi** sınırlıyor (günde 3 maç). Bu daha az can sıkıcı çünkü doğal ve tematik: gerçekte de günde 3 maç oynanmaz. Ayrıca "grind duvarı yok" vaadi bizim ana pazarlama farkımız. (§6.2, §16.1)

**S: Görevden alınma oyuncuları kızdırmaz mı?**
C: Kızdırır — kontrolsüz bırakılırsa. Bu yüzden üç aşamalı uyarı, somut kurtarma hedefi ve **oyun sonu olmayan** bir sonuç tasarladık. Görevden alındığında kariyerin devam ediyor, hatta bazen daha iyi bir kulübe geçiyorsun. Hedef oran %12–18/30 gün; analytics ile sürekli izlenir. (§12.8)

**S: Maç 90 saniye çok kısa değil mi? Futbolseverler daha uzun ister.**
C: İsteyene Canlı Anlar var (75–110 sn) ve o modda gerçek taktik kararları veriliyor. İstemeyen 8 saniyede geçiyor. İkisi de geçerli. Uzun maç izleme mobilde ölü bir format — Top Eleven'ın en çok şikâyet edilen yanı bu.

**S: Neden gerçek 3D maç yok?**
C: Maliyet/fayda. 3D maç motoru ekibin %40'ını yer ve bizim farkımız orada değil. 2D üstten görünüm + iyi anlatım + iyi ses, duygusal etkinin %80'ini %10 maliyetle veriyor.

**S: Oyuncular kartları çok hızlı tüketip tekrar görmeye başlarsa?**
C: MVP'de 200 kart + bağlamsal varyasyon (aynı kart farklı oyuncu/durumla farklı hissettiriyor) + kategori yorgunluğu algoritması + yenilik bonusu. 30 günde hiçbir kart 3 kereden fazla görülmemeli. Live-ops'ta ayda 40–60 yeni kart. (§12.9)

**S: PvP olmadan rekabet duygusu eksik kalmaz mı?**
C: Rekabet Ligi (asenkron puan yarışı) bu ihtiyacı %85 karşılıyor, gerçek zamanlı PvP maliyetinin %15'i ile. Gerçek PvP ayrıca "ödeyen ezer" algısı yaratıyor — bizim adalet sütunumuza aykırı. (§14.6)

**S: 4 gösterge çok mu az / çok mu?**
C: 3 çok az (ödünleşimler sığ kalır), 5+ takip edilemez. 4 gösterge Reigns'ta kanıtlanmış bir sayı. Yine de A/B test kuyruğunda 3 vs 4 testi var. (§20.7)

**S: Oyuncu kulübünü kişiselleştirebiliyor mu?**
C: Evet — ad, arma, forma rengi, stadyum adı. Bu FTUE'nin ilk 90 saniyesinde yapılıyor çünkü sahiplik duygusu (endowment + IKEA etkisi) mümkün olduğunca erken kurulmalı. (§7.2)

### 🧠 Psikoloji & Retention

**S: "Hook Model" tam olarak nerede uygulanıyor?**
C: §17.2'de dört aşamanın her biri somut sistemlere eşlendi. Özet: Tetikleyici = maç saati/push/yarım iş, Eylem = kart kaydırma, Değişken Ödül = scout/maç/kart sonucu, Yatırım = kadro/tesis/kariyer. Kritik nokta: hedefimiz **dış tetikleyiciden iç tetikleyiciye geçiş** — D30+ oyuncularda %65 organik açılış hedefi.

**S: D21 neden ayrı bir hedef olarak duruyor?**
C: Alışkanlık literatüründe davranışın otomatikleşmesi ortalama 20–25 günü buluyor. D21'i geçen oyuncunun D90 retention'ı dramatik yükseliyor. Bu yüzden D14–D21 arasına en yoğun yeni içeriği koyuyoruz (uluslararası scout, güçlü perkler, kariyer hissi). (§17.3)

**S: Bu kadar psikolojik teknik kullanmak manipülatif değil mi?**
C: Sınır şu: teknik **oyunu daha iyi yapıyorsa** meşru, sadece **daha fazla harcatıyorsa** değil. §17.7'de 10 maddelik kırmızı çizgi listesi var — sahte aciliyet, sunk cost metinleri, uyku saatinde bildirim, kaybettikten sonra teklif, hepsi yasak. Kurucu direktifi: "Bir mekaniği açıklarken utanıyorsak, koymuyoruz."

**S: Günlük giriş serisi (login streak) neden yok?**
C: Kaçırınca sıfırlanan seriler anksiyete üretiyor ve tatil/hastalık gibi normal hayat olaylarını cezalandırıyor. Bunun yerine kümülatif ödüller ve telafi mekanizmaları var (maç biriktirme, win-back paketi). Retention farkı ihmal edilebilir, kullanıcı memnuniyeti farkı büyük.

**S: D1'i artırmak için ne yapmalıyım (tek bir şey)?**
C: FTUE'yi düzelt. D1'de dönmeyenlerin %70'i FTUE'yi bitirmemiştir. D1 problemi neredeyse her zaman D0 problemidir. Funnel'daki en büyük düşüş adımını bul ve onu yeniden tasarla. (§7.5)

**S: Oyuncular 30. günde sıkılırsa ne yapacağız?**
C: Üç katman: (a) Live-ops kadansı — her hafta yeni tema, ayda 40-60 yeni kart, (b) yeni sistemler açılmaya devam ediyor (Kıta Kupası, efsane kadro), (c) Prestij/Hanedan döngüsü. Ama en güçlüsü **kimlik**: "ben bu oyunu oynayan biriyim" hissi. Kariyer sayfası, rekorlar, efsaneler bunu besliyor.

### 💰 Monetizasyon

**S: Neden loot box yok? Gelirin en büyük kaynağı değil mi?**
C: Kısa vadede evet, uzun vadede hayır. Belçika/Hollanda'da yasak, EU/UK'de düzenleme sıkılaşıyor, mağaza politikaları sertleşiyor, oyuncu tepkisi büyüyor. Loot box'sız tasarım = gelecekteki regülasyona bağışıklık + daha iyi mağaza puanı. Boşluğu Sezon Bileti ve kozmetiklerle dolduruyoruz.

**S: Ücretsiz oyuncu gerçekten Elit Lig'e çıkabilir mi?**
C: Evet, tasarım gereği. Ödeme **hız** veriyor (yaklaşık %35–50 daha hızlı ilerleme), **tavan** vermiyor. Bu, ekonomi denge testlerinde 3 profille (casual/normal/hardcore) doğrulanıyor. (§19.11)

**S: Sezon Bileti mi aylık abonelik mi?**
C: İkisi de olsun, ama **aylık abonelik birincil**. Abonelik LTV'yi %40+ artırıyor ve mağaza altyapısı retention'ı otomatik destekliyor (yenileme hatırlatmaları). Tek sezon bileti giriş ürünü olarak kalsın.

**S: Reklam koyarsak oyun ucuz mu görünür?**
C: Zorunlu interstitial koyarsak evet. Sadece **rewarded** ve tematik çerçeveli ("sponsor devreye girdi") reklamlar oyunu ucuzlatmıyor, hatta ödemeyen oyuncuya katkı yolu veriyor. Toplam gelirin %10'u hedef.

**S: İlk ödeme teklifini ne zaman göstermeliyim?**
C: D2. D0'da mağaza rozeti bile yanmıyor. İlk 24 saat tamamen oyun — bu, güven inşasının en kârlı yatırımı. A/B test kuyruğunda D2 vs D4 var.

**S: Fiyatları Türkiye için nasıl ayarlamalıyım?**
C: Apple/Google'ın yerel fiyat katmanlarını kullan, ~0.42 PPP çarpanı hedefle. TR yüksek hacim/düşük ARPU pazarı — hacim odaklı fiyatla, whale beklemeyin. (§16.8)

### ⚙️ Teknik

**S: Flutter oyun için yeterli mi?**
C: Bu oyun için fazlasıyla. Ağır 3D veya fizik yok; UI-yoğun, animasyon-yoğun bir uygulama. Flutter'ın güçlü olduğu alan tam burası. Maç görselleştirmesi `CustomPainter` ile 60fps rahat çalışıyor. Flame gibi bir oyun motoruna gerek yok.

**S: Neden Riverpod, Bloc değil?**
C: Riverpod derleme zamanı güvenliği, daha az boilerplate ve provider'ları test etmede kolaylık sağlıyor. Bloc'ta bu oyun için gereksiz event/state ceremony oluşur. Ekip Bloc'a hakimse Bloc da geçerli — mimarinin geri kalanı değişmiyor.

**S: Isar mı Drift mi?**
C: Isar — oyun state'i doküman-benzeri ve ilişkisel sorgu ihtiyacı düşük, Isar çok daha hızlı. Karmaşık lig istatistikleri sorguları planlanıyorsa Drift (SQL) tercih edilebilir.

**S: Sim motorunu neden saf Dart tutmalıyım?**
C: Üç sebep: (1) sunucuda aynı kodu çalıştırıp hile doğrulaması yapabilirsin, (2) unit testler milisaniyelerde koşar, (3) 10.000 maçlık denge testlerini CLI'dan çalıştırabilirsin. Bu üçü olmadan denge yapamazsın. (§19.2)

**S: Offline oynanabilir olmalı mı?**
C: Evet, zorunlu. Hedef pazarlarımızda (TR, BR, ID) bağlantı kalitesi değişken ve oyuncular metro/otobüste oynuyor. Offline-first mimari ayrıca sunucu maliyetini radikal düşürüyor. Sadece sıralama/PvP/IAP internet ister.

**S: Determinizm neden bu kadar önemli?**
C: (a) Sunucu doğrulaması ancak deterministik motorla mümkün, (b) bug reprodüksiyonu seed ile birebir yapılabiliyor, (c) Canlı Anlar modunda karar sonrası yeniden simülasyon tutarlı oluyor. `dart:math Random` kullanma — kendi Xorshift'ini yaz. (§19.4)

**S: Hile (cheat) beni ne kadar ilgilendirmeli?**
C: Tek oyunculu ilerlemede az (oyuncu kendi oyununu bozuyorsa bu onun seçimi ve aşırı koruma yanlış pozitiflerle iyi niyetli oyuncuları cezalandırır). Sıralama, PvP ve IAP'de çok — orada sunucu otoritesi ve makbuz doğrulaması **zorunlu**. (§19.9)

**S: Uygulama boyutu ne olmalı?**
C: Android ≤95 MB (split ABI ile), iOS ≤130 MB. 150 MB üstü indirme oranını düşürür (mobil veri uyarısı). Görselleri WebP, sesleri sıkıştırılmış tut, oyuncu yüzlerini katmanlı sprite yap.

### 🚀 Prodüksiyon & İş

**S: Solo geliştiriciysem bu kapsam gerçekçi mi?**
C: 12 ayda değil. Solo için: MVP'yi daha da kıs (100 kart, 8 tesis, 2 uzmanlık dalı, tek dil), 16–20 ay planla, sanat ve yazarlığı dışarıdan al. Ama **Faz 0 prototipini asla atlama** — 2 ayda çekirdek eğlenceyi kanıtlamak, 18 ay boş yere çalışmaktan iyidir.

**S: Nereden başlamalıyım? İlk hafta ne yapacağım?**
C: (1) Kart mekaniğinin kağıt prototipi — 30 kart yaz, arkadaşınla oyna, eğlenceli mi bak. (2) Flutter'da kart kaydırma + 4 gösterge çalışan bir ekran. (3) Basit maç simülatörü + denge testi altyapısı. Bu üçü çalışıyorsa oyunun var demektir; gerisi içerik ve cila.

**S: Publisher ile mi çalışmalıyım?**
C: Vertical slice'a kadar bekle. İyi bir vertical slice + D7 %20 verisi ile pazarlık gücün çok yükselir. Publisher UA sermayesi ve live-ops deneyimi getiriyor ama gelirin %30–50'sini alıyor. Kendi UA'nı finanse edebiliyorsan bağımsız kal.

**S: Hangi metrik kapı kriteri olmalı?**
C: Faz 0: 7/10 test kullanıcısı "devam etmek istiyorum" demeli. Faz 1: D7 ≥ %20 (kapalı test). Faz 2 (global geçiş): D1 ≥ %38, D7 ≥ %16, D30 ≥ %7, crash-free ≥ %99.2. Bunlar geçilmeden UA'ya para harcanmaz.

**S: Gerçek oyuncu isimlerini kullanabilir miyim?**
C: Hayır. FIFPro/imaj hakları ve kulüp marka hakları indie için erişilemez maliyetli ve ihlal doğrudan mağaza kaldırması + dava riski. Prosedürel üretim hem yasal hem de aslında **daha iyi** — oyuncu kendi keşfettiği isimlere daha çok bağlanıyor. (§24.2)

**S: Türkiye'de mi yoksa yurtdışında mı yayınlamalıyım?**
C: İkisi. Soft launch'ta TR **mutlaka** olsun — ana pazarın ve kültürel sinyal orada en net. Ama global lansmanda BR/MX/ID gibi büyük futbol+mobil pazarlarını hedefle. Tek pazara bağımlılık risk.

**S: Kaç kart ile başlamalıyım?**
C: MVP için 200. Altında tekrar hissi 10. günde başlıyor. Prototip için 30 yeterli (mekaniği test etmek için).

**S: Lansmanı ne zaman yapmalıyım?**
C: Ağustos–Eylül (Avrupa ligleri başlarken) veya Ocak (transfer dönemi) — futbol ilgisinin zirvede olduğu dönemler. Aralık ortası ve Temmuz ortasından kaçın.

**S: Bu doküman ne sıklıkla güncellenmeli?**
C: Her sprint sonunda değişen tasarım kararları, her ay metrik hedefleri, her büyük özellikte ilgili bölüm. DoD listesinde "dokümantasyon güncellendi" maddesi var (§25.6). Güncellenmeyen doküman zararlıdır — yanlış bilgi hiç bilgi olmamasından kötüdür.

---

## EK G — TERİM SÖZLÜĞÜ

| Terim | Anlamı |
|---|---|
| **ARPDAU** | Average Revenue Per Daily Active User — günlük aktif kullanıcı başına gelir |
| **ARPPU** | Average Revenue Per Paying User — ödeme yapan kullanıcı başına gelir |
| **ASO** | App Store Optimization — mağaza sıralama optimizasyonu |
| **ATT** | App Tracking Transparency — iOS izleme izni |
| **Core Loop** | Oyunun tekrar eden temel eylem döngüsü |
| **CPI** | Cost Per Install — kurulum başına maliyet |
| **CVR** | Conversion Rate — dönüşüm oranı |
| **DAU/MAU** | Günlük/Aylık aktif kullanıcı |
| **DoD** | Definition of Done — bitmiş sayılma kriterleri |
| **Endowed Progress** | Boş başlamak yerine kısmi ilerleme ile başlatma etkisi |
| **Faucet/Sink** | Ekonomiye para giren/çıkan noktalar |
| **FTUE** | First Time User Experience — ilk kullanıcı deneyimi |
| **Goal Gradient** | Hedefe yaklaştıkça çabanın artması |
| **Hook Model** | Tetikleyici→Eylem→Değişken Ödül→Yatırım döngüsü (Nir Eyal) |
| **IAP** | In-App Purchase — uygulama içi satın alma |
| **IKEA Etkisi** | Kendi emek verdiğin şeye fazla değer atfetme |
| **Kohort** | Aynı gün edinilen kullanıcı grubu |
| **Live-Ops** | Lansman sonrası sürekli içerik/etkinlik operasyonu |
| **Loss Aversion** | Kaybın kazançtan daha güçlü hissedilmesi |
| **LTV** | Lifetime Value — kullanıcı yaşam boyu değeri |
| **MVP** | Minimum Viable Product — en küçük yaşayabilir ürün |
| **North Star Metric** | Ürünün başarısını en iyi temsil eden tek metrik |
| **OVR** | Overall — oyuncunun genel gücü |
| **Peak-End Rule** | Deneyimin zirvesi ve sonunun hatırlanması |
| **P2W** | Pay-to-Win — parayla güç satın alma |
| **Payer Conversion** | Ödeme yapan kullanıcı oranı |
| **Progressive Disclosure** | Sistemlerin kademeli açılması |
| **Retention (D1/D7/D30)** | Kurulumdan N gün sonra dönen kullanıcı oranı |
| **ROAS** | Return On Ad Spend — reklam harcaması getirisi |
| **Rewarded Ad** | Ödüllü, opsiyonel reklam |
| **Rebirth/Prestige** | İlerlemeyi sıfırlayıp kalıcı bonus kazanma |
| **SDT** | Self-Determination Theory — Özerklik/Yetkinlik/Bağ kuramı |
| **Session** | Tek bir oyun oturumu |
| **Sink** | Kaynak tüketen mekanik |
| **Soft Launch** | Sınırlı pazarda test amaçlı yayın |
| **SSV** | Server-Side Verification — sunucu tarafı doğrulama |
| **Sunk Cost** | Batık maliyet yanılgısı |
| **UA** | User Acquisition — kullanıcı edinme |
| **Vertical Slice** | Oyunun küçük ama son kalitede bir dilimi |
| **Whale** | Yüksek harcama yapan kullanıcı |
| **xG** | Expected Goals — beklenen gol değeri |
| **Zeigarnik Etkisi** | Yarım kalan işlerin akılda kalması |

---

## EK H — KONTROL LİSTELERİ

### H.1 Yeni Özellik Tasarım Kontrolü
- [ ] Hangi tasarım sütununu (§5) güçlendiriyor?
- [ ] Core loop'un hangi katmanına (§6.3) giriyor?
- [ ] Hangi Hook aşamasını besliyor?
- [ ] Hangi retention gününü hedefliyor?
- [ ] Ekonomiye musluk mu lavabo mu? Denge tablosuna etkisi?
- [ ] Yeni bir para birimi/kaynak gerektiriyor mu? (Gerektiriyorsa gerçekten şart mı?)
- [ ] Kaç dokunuşla ulaşılıyor? (≤3 olmalı)
- [ ] 3 dakikalık seansa sığıyor mu?
- [ ] Ölçüm için hangi eventler gerekli?
- [ ] Remote Config ile ayarlanabilir parametreleri neler?
- [ ] Ödemeyen oyuncu için değeri ne?
- [ ] Bu özelliği kesip MVP'yi çıkarabilir miyim? (Cevap evetse kes.)

### H.2 Sürüm Yayın Kontrolü
- [ ] Tüm testler geçti (unit + denge + integration)
- [ ] Denge testi bantları içinde (§11.8)
- [ ] Ekonomi simülasyonu bantları içinde (§15.7)
- [ ] Crash-free ≥ %99.5 (önceki sürüm)
- [ ] Yeni eventler analytics'te doğrulandı
- [ ] Lokalizasyon tamamlandı, taşma testi yapıldı
- [ ] Düşük segment cihaz testi yapıldı
- [ ] Kayıt migration'ı test edildi (eski kayıtla açılıyor mu)
- [ ] Remote Config varsayılanları güncel
- [ ] Kill-switch'ler çalışıyor
- [ ] Store metinleri/görselleri güncel
- [ ] Rollback planı hazır
- [ ] Kademeli yayın planı (%5→%20→%50→%100)

### H.3 Lansman Öncesi Araştırma Kontrolü
- [ ] Marka adı: TÜRKPATENT + EUIPO + USPTO araması
- [ ] Mağaza isim çakışması kontrolü
- [ ] Domain + sosyal handle rezervasyonu
- [ ] Rakip listesi güncel indirme/gelir verisi (Sensor Tower/AppMagic)
- [ ] Hedef pazarlarda CPI benchmark'ı
- [ ] Anahtar kelime hacim araştırması (AppTweak/AppFollow)
- [ ] Yaş derecelendirme anketleri tamamlandı
- [ ] Gizlilik politikası + KOŞULLAR hazır ve yayında
- [ ] Hukuki gözden geçirme yapıldı

### H.4 Kart Yazım Kontrolü
- [ ] ≤220 karakter
- [ ] Bir NPC konuşuyor (anlatıcı değil)
- [ ] Her seçenek savunulabilir (hiçbiri açıkça "doğru" değil)
- [ ] Sonuç metni yargılamıyor
- [ ] Sayı değil his veriyor
- [ ] Dinamik değişkenler doğru ({player.name} vb.)
- [ ] Ön koşullar tanımlı
- [ ] Cooldown ve maxPerSeason ayarlı
- [ ] Etkiler denge aralığında (±3 ile ±12, kriz ±25)
- [ ] En az bir perk-kilitli seçenek düşünüldü mü?
- [ ] Türkçe ek uyumu test edildi
- [ ] Bu kart 100 farklı bağlamda çalışıyor mu?

### H.5 Haftalık Live-Ops Kontrolü
- [ ] Sezon teması yayınlandı
- [ ] Günlük görevler yenilendi
- [ ] Sıralamalar sıfırlandı ve ödüller dağıtıldı
- [ ] Geçen haftanın metrikleri incelendi
- [ ] Denge ayarları uygulandı (gerekirse)
- [ ] Aktif A/B testler kontrol edildi
- [ ] Mağaza yorumları yanıtlandı
- [ ] Topluluk kanallarında duyuru yapıldı
- [ ] Sonraki hafta içeriği hazır

### H.6 Aylık Sağlık Kontrolü
- [ ] Retention kohort tablosu (D1/D7/D30) trend analizi
- [ ] Ekonomi sağlık metrikleri (§15.7)
- [ ] Görevden alınma oranı bandda mı (%12–18)
- [ ] Kart seçim dağılımları (bozuk kart var mı)
- [ ] LTV/CPI oranı
- [ ] Mağaza puanı ve yorum duyarlılığı
- [ ] Crash/ANR trendi
- [ ] Risk kaydı gözden geçirildi (§26)
- [ ] Bir sonraki ayın içerik planı onaylandı
- [ ] Bu doküman güncellendi

---

## KAPANIŞ NOTU

Bu doküman bir **harita**, bir sözleşme değil. En değerli kısmı §5'teki beş tasarım sütunu ve §17'deki etik çerçeve — geri kalan her şey ölçüm sonuçlarına göre değişebilir ve değişmeli.

**Üç şeyi asla değiştirme:**
1. Her kararın bir bedeli olduğu ilkesi
2. Ödemeyenin de her yere ulaşabileceği vaadi
3. "Açıklarken utanacağımız mekaniği koymayız" kuralı

**İlk yapılacak üç şey:**
1. 30 kartlık kağıt prototip — bu hafta
2. Flutter'da kart kaydırma + 4 gösterge ekranı — 2. hafta
3. Maç simülatörü + 10.000 maçlık denge testi — 4. hafta

Faz 0 kapısını (7/10 test kullanıcısı "devam etmek istiyorum") geçemezsen, bu dokümanın geri kalanı hiçbir işe yaramaz. Geçersen, geri kalanı yol haritan.

---

*Doküman sonu · v1.0 · Dynasty XI Üretim Dokümanı*

