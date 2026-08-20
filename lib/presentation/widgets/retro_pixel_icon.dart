// presentation/widgets/retro_pixel_icon.dart
// Zero-dependency, hardware-accelerated 16-Bit Neo-Brutalist Pixel Iconography Engine.
// Renders crisp pixel-art vectors with configurable size, primary/secondary colors, borders, and neon glow.

import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Desteklenen 16-Bit Neo-Brutalist İkon Tipleri
enum RetroPixelIconType {
  cart,
  tag,
  handshake,
  cash,
  megaphone,
  shirt,
  capitol,
  crown,
  suit,
  tacticsBoard,
  stadium,
  trophy,
  newspaper,
  lightning,
  shield,
  star,
  bench,
  whistle,
  chat,
  flame,
  scales,
  pen,
  sprout,
  plane,
  satellite,
  briefcase,
  gavel,
  tv,
  safe,
  vip,
  lock,
  unlock,
  clock,
  target,
  filter,
  chart,
  ball,
  check,
  cross,
  arrowUp,
  arrowDown,
  user,
  users;

  /// String veya emoji girdisini en uygun RetroPixelIconType'a dönüştürür.
  static RetroPixelIconType fromString(String input) {
    final clean = input.trim();
    switch (clean) {
      case '🛒':
      case 'cart':
      case 'market':
        return RetroPixelIconType.cart;
      case '🏷️':
      case '🏷':
      case 'tag':
      case 'sale':
        return RetroPixelIconType.tag;
      case '🤝':
      case 'handshake':
      case 'loan':
        return RetroPixelIconType.handshake;
      case '💰':
      case '💵':
      case '₣':
      case 'cash':
      case 'money':
        return RetroPixelIconType.cash;
      case '📢':
      case '📣':
      case 'fan':
      case 'fans':
      case 'megaphone':
        return RetroPixelIconType.megaphone;
      case '👕':
      case 'shirt':
      case 'jersey':
      case 'locker':
        return RetroPixelIconType.shirt;
      case '🏛️':
      case '🏛':
      case 'capitol':
      case 'board':
      case 'bank':
        return RetroPixelIconType.capitol;
      case '👑':
      case 'crown':
      case 'president':
        return RetroPixelIconType.crown;
      case '👔':
      case 'suit':
      case 'coach':
      case 'staff':
        return RetroPixelIconType.suit;
      case '📋':
      case 'tactics':
      case 'lineup':
        return RetroPixelIconType.tacticsBoard;
      case '🏟️':
      case '🏟':
      case 'stadium':
      case 'facility':
        return RetroPixelIconType.stadium;
      case '🏆':
      case 'trophy':
      case 'cup':
        return RetroPixelIconType.trophy;
      case '📰':
      case 'newspaper':
      case 'press':
        return RetroPixelIconType.newspaper;
      case '⚡':
      case 'lightning':
      case 'power':
        return RetroPixelIconType.lightning;
      case '🛡️':
      case '🛡':
      case 'shield':
      case 'club':
        return RetroPixelIconType.shield;
      case '⭐':
      case 'star':
      case 'pot':
        return RetroPixelIconType.star;
      case '🪑':
      case 'bench':
      case 'sub':
        return RetroPixelIconType.bench;
      case '📯':
      case 'whistle':
      case 'ref':
        return RetroPixelIconType.whistle;
      case '💬':
      case 'chat':
      case 'dialogue':
        return RetroPixelIconType.chat;
      case '🔥':
      case 'flame':
      case 'form':
        return RetroPixelIconType.flame;
      case '⚖️':
      case '⚖':
      case 'scales':
      case 'compare':
        return RetroPixelIconType.scales;
      case '📝':
      case '✍️':
      case 'pen':
      case 'contract':
        return RetroPixelIconType.pen;
      case '🌱':
      case 'sprout':
      case 'youth':
      case 'academy':
        return RetroPixelIconType.sprout;
      case '✈️':
      case '✈':
      case 'plane':
      case 'hijack':
        return RetroPixelIconType.plane;
      case '📡':
      case '🛰️':
      case 'satellite':
      case 'scout':
        return RetroPixelIconType.satellite;
      case '💼':
      case 'briefcase':
      case 'agent':
        return RetroPixelIconType.briefcase;
      case '⚖':
      case 'gavel':
      case 'legal':
        return RetroPixelIconType.gavel;
      case '📺':
      case 'tv':
      case 'debate':
        return RetroPixelIconType.tv;
      case '🔒':
      case 'lock':
        return RetroPixelIconType.lock;
      case '🔓':
      case 'unlock':
        return RetroPixelIconType.unlock;
      case '🎯':
      case 'target':
        return RetroPixelIconType.target;
      case '📊':
      case 'chart':
      case 'stats':
        return RetroPixelIconType.chart;
      case '⚽':
      case 'ball':
        return RetroPixelIconType.ball;
      case '👤':
      case 'user':
        return RetroPixelIconType.user;
      case '👥':
      case 'users':
        return RetroPixelIconType.users;
      default:
        return RetroPixelIconType.lightning;
    }
  }
}

/// 16-Bit Neo-Brutalist Piksel İkon Bileşeni
class RetroPixelIcon extends StatelessWidget {
  final RetroPixelIconType type;
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final bool hasGlow;
  final Color? glowColor;

  const RetroPixelIcon({
    super.key,
    required this.type,
    this.size = 20.0,
    this.color,
    this.secondaryColor,
    this.hasGlow = false,
    this.glowColor,
  });

  /// Emoji veya anahtar kelimeden otomatik eşleme ile ikon oluşturur
  factory RetroPixelIcon.fromEmoji(
    String emojiOrKeyword, {
    Key? key,
    double size = 18.0,
    Color? color,
    Color? secondaryColor,
    bool hasGlow = false,
    Color? glowColor,
  }) {
    return RetroPixelIcon(
      key: key,
      type: RetroPixelIconType.fromString(emojiOrKeyword),
      size: size,
      color: color,
      secondaryColor: secondaryColor,
      hasGlow: hasGlow,
      glowColor: glowColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.neonLime;
    final effectiveSecondary = secondaryColor ?? Colors.black;

    Widget iconWidget = CustomPaint(
      size: Size(size, size),
      painter: _RetroPixelIconPainter(
        type: type,
        primaryColor: effectiveColor,
        secondaryColor: effectiveSecondary,
      ),
    );

    if (hasGlow) {
      iconWidget = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (glowColor ?? effectiveColor).withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: iconWidget,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: iconWidget),
    );
  }
}

/// 16x16 / 24x24 Piksel Izgara Çizim Motoru
class _RetroPixelIconPainter extends CustomPainter {
  final RetroPixelIconType type;
  final Color primaryColor;
  final Color secondaryColor;

  _RetroPixelIconPainter({
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // 16x16 Standart Piksel Izgara Oranlayıcı
    final pixelSize = size.width / 16.0;

    void drawPixel(int x, int y, [Color? customColor]) {
      final p = customColor != null ? (Paint()..color = customColor) : paint;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        p,
      );
    }

    void drawBlock(int x, int y, int w, int h, [Color? customColor]) {
      final p = customColor != null ? (Paint()..color = customColor) : paint;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, w * pixelSize, h * pixelSize),
        p,
      );
    }

    switch (type) {
      case RetroPixelIconType.cart:
        // Market / Transfer Arabası
        drawBlock(1, 2, 3, 2); // Tutma kolu
        drawBlock(3, 4, 2, 7); // Ön gövde bağlantı
        drawBlock(5, 4, 9, 2); // Üst sepet kenarı
        drawBlock(5, 6, 8, 2); // Orta sepet
        drawBlock(6, 8, 6, 2); // Alt taban
        drawBlock(3, 10, 8, 1); // Tekerlek dingili
        drawBlock(4, 12, 2, 2); // Sol tekerlek
        drawBlock(10, 12, 2, 2); // Sağ tekerlek
        break;

      case RetroPixelIconType.tag:
        // Fiyat / Satış Etiketi
        drawBlock(7, 1, 6, 2); // Üst köşe
        drawBlock(5, 3, 9, 2);
        drawBlock(3, 5, 11, 2);
        drawBlock(1, 7, 13, 2);
        drawBlock(2, 9, 12, 2);
        drawBlock(4, 11, 10, 2);
        drawBlock(6, 13, 6, 2);
        // Delik noktası (arkaplan rengi)
        drawPixel(10, 3, secondaryColor);
        drawPixel(11, 3, secondaryColor);
        break;

      case RetroPixelIconType.handshake:
        // El Sıkışma / Kiralık Anlaşma
        drawBlock(0, 5, 5, 3); // Sol kol
        drawBlock(11, 5, 5, 3); // Sağ kol
        drawBlock(4, 4, 3, 3); // Sol bilek
        drawBlock(9, 4, 3, 3); // Sağ bilek
        drawBlock(5, 6, 6, 4); // Kilitlenen parmaklar
        drawBlock(6, 10, 4, 2); // Başparmak bağı
        break;

      case RetroPixelIconType.cash:
        // Para / Kasa Destesi
        drawBlock(1, 3, 14, 10); // Ana banknot
        // İç çerçeve ve ₣ sembolü
        drawBlock(3, 5, 10, 6, secondaryColor);
        drawBlock(5, 6, 6, 4, primaryColor);
        drawBlock(6, 7, 4, 2, secondaryColor);
        drawPixel(7, 7, primaryColor);
        break;

      case RetroPixelIconType.megaphone:
        // Taraftar Megafonu
        drawBlock(1, 6, 3, 4); // Ağızlık
        drawBlock(4, 5, 3, 6); // Boğaz
        drawBlock(7, 4, 4, 8); // Gövde
        drawBlock(11, 2, 3, 12); // Açılan huni
        drawBlock(3, 10, 3, 4); // Tutma kabzası
        break;

      case RetroPixelIconType.shirt:
        // Forma / Soyunma Odası
        drawBlock(5, 1, 6, 2); // Yaka
        drawBlock(2, 3, 12, 3); // Omuzlar
        drawBlock(0, 5, 4, 4); // Sol kol
        drawBlock(12, 5, 4, 4); // Sağ kol
        drawBlock(4, 6, 8, 9); // Gövde
        drawBlock(6, 3, 4, 2, secondaryColor); // V-yaka boşluğu
        break;

      case RetroPixelIconType.capitol:
        // Yönetim Binası / Kulüp Kurulu
        drawBlock(1, 1, 14, 2); // Çatı tepesi üçgen tabanı
        drawBlock(7, 0, 2, 2); // Tepe ucu
        drawBlock(2, 3, 12, 2); // Saçak
        drawBlock(3, 5, 2, 7); // Sütun 1
        drawBlock(7, 5, 2, 7); // Sütun 2
        drawBlock(11, 5, 2, 7); // Sütun 3
        drawBlock(1, 12, 14, 3); // Kaide / Merdiven
        break;

      case RetroPixelIconType.crown:
        // Başkanlık Tacı
        drawBlock(1, 12, 14, 3); // Taç tabanı
        drawBlock(1, 5, 2, 7); // Sol kule
        drawBlock(7, 3, 2, 9); // Orta yüksek kule
        drawBlock(13, 5, 2, 7); // Sağ kule
        drawBlock(3, 8, 4, 4); // Sol iç dolgu
        drawBlock(9, 8, 4, 4); // Sağ iç dolgu
        drawPixel(2, 4); // Mücevher sol
        drawPixel(7, 2); // Mücevher orta
        drawPixel(13, 4); // Mücevher sağ
        break;

      case RetroPixelIconType.suit:
        // Teknik Direktör / Takım Elbise
        drawBlock(4, 1, 8, 3); // Yaka
        drawBlock(2, 4, 12, 11); // Ceket
        drawBlock(7, 4, 2, 8, secondaryColor); // Kravat gövdesi
        drawBlock(6, 11, 4, 2, secondaryColor); // Kravat ucu
        drawBlock(5, 4, 2, 3, Colors.white); // Beyaz gömlek sol
        drawBlock(9, 4, 2, 3, Colors.white); // Beyaz gömlek sağ
        break;

      case RetroPixelIconType.tacticsBoard:
        // Taktik Tahtası / Kadro
        drawBlock(2, 1, 12, 14); // Tahta
        drawBlock(4, 3, 8, 10, secondaryColor); // Yeşil saha alanı
        drawBlock(7, 1, 2, 2, primaryColor); // Klips
        // Oyuncu noktaları
        drawPixel(5, 5, primaryColor);
        drawPixel(9, 5, primaryColor);
        drawPixel(7, 8, primaryColor);
        drawPixel(5, 10, primaryColor);
        drawPixel(9, 10, primaryColor);
        break;

      case RetroPixelIconType.stadium:
        // Stadyum / Tesis
        drawBlock(2, 5, 12, 8); // Stadyum ovali
        drawBlock(4, 7, 8, 4, secondaryColor); // Çim zemin
        drawBlock(0, 2, 2, 7); // Sol ışık direği
        drawBlock(14, 2, 2, 7); // Sağ ışık direği
        drawBlock(0, 1, 3, 2); // Sol projektör
        drawBlock(13, 1, 3, 2); // Sağ projektör
        break;

      case RetroPixelIconType.trophy:
        // Kupa
        drawBlock(4, 1, 8, 6); // Kupa kasesi
        drawBlock(1, 2, 3, 4); // Sol kulp
        drawBlock(12, 2, 3, 4); // Sağ kulp
        drawBlock(6, 7, 4, 4); // Kupa sapı
        drawBlock(3, 11, 10, 4); // Alt kaide
        drawBlock(5, 3, 6, 3, secondaryColor); // Kase içi parlama
        break;

      case RetroPixelIconType.newspaper:
        // Basın Gazetesi
        drawBlock(2, 2, 12, 12); // Gazete sayfası
        drawBlock(4, 4, 8, 3, secondaryColor); // Manşet görseli
        drawBlock(4, 8, 8, 1, secondaryColor); // Metin satırı 1
        drawBlock(4, 10, 6, 1, secondaryColor); // Metin satırı 2
        drawBlock(4, 12, 7, 1, secondaryColor); // Metin satırı 3
        break;

      case RetroPixelIconType.lightning:
        // Yıldırım / Enerji
        drawBlock(8, 0, 4, 3);
        drawBlock(6, 3, 4, 3);
        drawBlock(4, 6, 8, 2);
        drawBlock(2, 8, 5, 3);
        drawBlock(4, 11, 3, 3);
        drawBlock(6, 14, 2, 2);
        break;

      case RetroPixelIconType.shield:
        // Kalkan / Kulüp Arması
        drawBlock(2, 1, 12, 7);
        drawBlock(3, 8, 10, 3);
        drawBlock(4, 11, 8, 2);
        drawBlock(6, 13, 4, 2);
        drawBlock(7, 15, 2, 1);
        drawBlock(4, 3, 8, 6, secondaryColor);
        break;

      case RetroPixelIconType.star:
        // Yıldız
        drawBlock(7, 1, 2, 3); // Tepe
        drawBlock(1, 5, 14, 3); // Yatay kollar
        drawBlock(3, 8, 10, 3); // Gövde
        drawBlock(2, 11, 4, 4); // Sol bacak
        drawBlock(10, 11, 4, 4); // Sağ bacak
        break;

      case RetroPixelIconType.bench:
        // Yedek Kulübesi
        drawBlock(1, 3, 14, 2); // Gölgelik tavanı
        drawBlock(1, 5, 2, 8); // Sol destek
        drawBlock(13, 5, 2, 8); // Sağ destek
        drawBlock(3, 8, 10, 2); // Oturak minderi
        drawBlock(3, 10, 2, 4); // Ayak 1
        drawBlock(11, 10, 2, 4); // Ayak 2
        break;

      case RetroPixelIconType.whistle:
        // Düdük
        drawBlock(1, 5, 4, 4); // Ağızlık borusu
        drawBlock(5, 3, 8, 8); // Düdük gövdesi
        drawBlock(13, 5, 2, 4); // Askı halkası
        drawBlock(7, 5, 4, 4, secondaryColor); // İç hava boşluğu
        break;

      case RetroPixelIconType.chat:
        // Sohbet Balonu
        drawBlock(2, 2, 12, 9); // Balon kutusu
        drawBlock(2, 11, 4, 3); // Kuyruk
        drawBlock(4, 5, 2, 2, secondaryColor); // Nokta 1
        drawBlock(7, 5, 2, 2, secondaryColor); // Nokta 2
        drawBlock(10, 5, 2, 2, secondaryColor); // Nokta 3
        break;

      case RetroPixelIconType.flame:
        // Alev / Hırs
        drawBlock(7, 1, 2, 3);
        drawBlock(5, 4, 5, 4);
        drawBlock(3, 7, 10, 5);
        drawBlock(4, 12, 8, 3);
        drawBlock(6, 7, 3, 5, secondaryColor); // İç kor
        break;

      case RetroPixelIconType.scales:
        // Terazi / Kıyaslama
        drawBlock(7, 1, 2, 14); // Orta direk
        drawBlock(2, 3, 12, 2); // Denge kolu
        drawBlock(1, 5, 4, 1); // Sol kefe ipi
        drawBlock(0, 6, 6, 2); // Sol kefe tabağı
        drawBlock(11, 5, 4, 1); // Sağ kefe ipi
        drawBlock(10, 6, 6, 2); // Sağ kefe tabağı
        drawBlock(4, 14, 8, 2); // Taban kaidesi
        break;

      case RetroPixelIconType.pen:
        // Sözleşme Dolmakalemi
        drawBlock(11, 1, 4, 4); // Kalem ucu arkası
        drawBlock(7, 5, 6, 4); // Gövde
        drawBlock(4, 9, 5, 4); // Tutacak
        drawBlock(1, 13, 3, 2); // Metal uç
        drawPixel(0, 15); // Mürekkep noktası
        break;

      case RetroPixelIconType.sprout:
        // Altyapı Filizi
        drawBlock(7, 7, 2, 8); // Gövde sapı
        drawBlock(3, 3, 4, 3); // Sol yaprak
        drawBlock(2, 4, 5, 2);
        drawBlock(9, 2, 4, 3); // Sağ yaprak
        drawBlock(9, 3, 5, 2);
        drawBlock(4, 14, 8, 2, secondaryColor); // Toprak tabakası
        break;

      case RetroPixelIconType.plane:
        // Uçak / Transfer Çalımı
        drawBlock(7, 1, 2, 14); // Gövde
        drawBlock(1, 7, 14, 3); // Ana kanatlar
        drawBlock(4, 13, 8, 2); // Arka kuyruk kanadı
        break;

      case RetroPixelIconType.satellite:
        // Uydu / Radar
        drawBlock(1, 2, 6, 6); // Radar çanağı
        drawBlock(7, 7, 4, 4); // Eksen bağlantısı
        drawBlock(11, 10, 4, 5); // Güneş paneli
        drawBlock(0, 10, 4, 5); // Güneş paneli sol
        break;

      case RetroPixelIconType.briefcase:
        // Evrak Çantası / Menajer
        drawBlock(6, 2, 4, 2); // Tutma sapı
        drawBlock(2, 4, 12, 10); // Çanta gövdesi
        drawBlock(2, 8, 12, 1, secondaryColor); // Açma çizgisi
        drawBlock(7, 8, 2, 2, Colors.white); // Kilit tokası
        break;

      case RetroPixelIconType.gavel:
        // Tokmak / Hukuk & Ceza
        drawBlock(1, 3, 7, 4); // Tokmak başı
        drawBlock(6, 6, 8, 8); // Sap
        drawBlock(0, 13, 8, 2); // Vurma tahtası
        break;

      case RetroPixelIconType.tv:
        // Televizyon / Medya
        drawBlock(5, 1, 2, 2); // Anten sol
        drawBlock(9, 1, 2, 2); // Anten sağ
        drawBlock(1, 3, 14, 11); // TV kasası
        drawBlock(3, 5, 8, 7, secondaryColor); // Ekran
        drawBlock(12, 5, 2, 2, secondaryColor); // Düğme 1
        drawBlock(12, 8, 2, 2, secondaryColor); // Düğme 2
        break;

      case RetroPixelIconType.safe:
        // Kasa / Banka
        drawBlock(2, 2, 12, 12); // Kasa çerçevesi
        drawBlock(4, 4, 8, 8, secondaryColor); // Kasa kapağı
        drawBlock(6, 6, 4, 4, primaryColor); // Çark göbeği
        drawPixel(7, 7, secondaryColor);
        break;

      case RetroPixelIconType.vip:
        // VIP Loca / Elmas
        drawBlock(5, 3, 6, 2);
        drawBlock(2, 5, 12, 3);
        drawBlock(4, 8, 8, 3);
        drawBlock(6, 11, 4, 2);
        drawBlock(7, 13, 2, 1);
        break;

      case RetroPixelIconType.lock:
        // Kilit
        drawBlock(5, 2, 6, 5); // Kilit kemeri
        drawBlock(7, 4, 2, 3, secondaryColor); // Kemer içi boşluk
        drawBlock(3, 7, 10, 8); // Gövde
        drawBlock(7, 10, 2, 3, secondaryColor); // Anahtar deliği
        break;

      case RetroPixelIconType.unlock:
        // Açık Kilit
        drawBlock(7, 1, 6, 5); // Açık kilit kemeri
        drawBlock(9, 3, 2, 3, secondaryColor);
        drawBlock(3, 7, 10, 8); // Gövde
        drawBlock(7, 10, 2, 3, secondaryColor); // Anahtar deliği
        break;

      case RetroPixelIconType.clock:
        // Saat / Süre
        drawBlock(3, 2, 10, 12);
        drawBlock(5, 1, 6, 14);
        drawBlock(5, 4, 6, 8, secondaryColor); // Saat içi
        drawBlock(7, 5, 2, 4, primaryColor); // Akrep
        drawBlock(7, 8, 3, 2, primaryColor); // Yelkovan
        break;

      case RetroPixelIconType.target:
        // Hedef
        drawBlock(6, 1, 4, 14);
        drawBlock(1, 6, 14, 4);
        drawBlock(4, 4, 8, 8, secondaryColor);
        drawBlock(6, 6, 4, 4, primaryColor);
        drawPixel(7, 7, Colors.white);
        break;

      case RetroPixelIconType.filter:
        // Filtre
        drawBlock(1, 2, 14, 3);
        drawBlock(4, 5, 8, 3);
        drawBlock(6, 8, 4, 6);
        break;

      case RetroPixelIconType.chart:
        // Grafik
        drawBlock(1, 13, 14, 2); // X ekseni
        drawBlock(1, 1, 2, 14); // Y ekseni
        drawBlock(4, 9, 2, 4); // Çubuk 1
        drawBlock(8, 6, 2, 7); // Çubuk 2
        drawBlock(12, 3, 2, 10); // Çubuk 3
        break;

      case RetroPixelIconType.ball:
        // Futbol Topu
        drawBlock(3, 2, 10, 12);
        drawBlock(2, 3, 12, 10);
        drawBlock(6, 6, 4, 4, secondaryColor); // Orta beşgen
        drawPixel(4, 4, secondaryColor);
        drawPixel(11, 4, secondaryColor);
        drawPixel(4, 11, secondaryColor);
        drawPixel(11, 11, secondaryColor);
        break;

      case RetroPixelIconType.check:
        // Onay İmi
        drawBlock(1, 8, 3, 3);
        drawBlock(4, 10, 3, 3);
        drawBlock(7, 7, 3, 3);
        drawBlock(10, 4, 3, 3);
        drawBlock(13, 1, 3, 3);
        break;

      case RetroPixelIconType.cross:
        // Çarpı İmi
        drawBlock(2, 2, 3, 3);
        drawBlock(11, 2, 3, 3);
        drawBlock(5, 5, 6, 6);
        drawBlock(2, 11, 3, 3);
        drawBlock(11, 11, 3, 3);
        break;

      case RetroPixelIconType.arrowUp:
        drawBlock(7, 1, 2, 14);
        drawBlock(5, 4, 6, 2);
        drawBlock(3, 6, 10, 2);
        break;

      case RetroPixelIconType.arrowDown:
        drawBlock(7, 1, 2, 14);
        drawBlock(5, 10, 6, 2);
        drawBlock(3, 8, 10, 2);
        break;

      case RetroPixelIconType.user:
        drawBlock(6, 2, 4, 4); // Baş
        drawBlock(3, 8, 10, 7); // Omuz ve gövde
        break;

      case RetroPixelIconType.users:
        drawBlock(4, 2, 4, 4); // Baş 1
        drawBlock(9, 2, 4, 4); // Baş 2
        drawBlock(1, 7, 7, 8); // Gövde 1
        drawBlock(8, 7, 7, 8); // Gövde 2
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _RetroPixelIconPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
