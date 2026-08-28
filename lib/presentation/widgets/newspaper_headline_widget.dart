// presentation/widgets/newspaper_headline_widget.dart
// Retro Newspaper Headlines & Gazete Kupürü Widget (§17.5-1, §21.3, §66)

import 'package:flutter/material.dart';

class NewspaperHeadlineWidget extends StatelessWidget {
  final String outletName; // e.g. "FANATİK MANŞET", "FOTOMAÇ", "HÜRRİYET SPOR"
  final String headline;
  final String subhead;
  final String dateString;
  final String? reporter;
  final String? columnQuote;
  final bool isPositive;

  const NewspaperHeadlineWidget({
    super.key,
    this.outletName = 'FUTBOL GAZETESİ • SON BASKI',
    required this.headline,
    required this.subhead,
    required this.dateString,
    this.reporter,
    this.columnQuote,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6E2), // Vintage newsprint paper color
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gazete Başlık Bandı & Tarih
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('[MANSET]', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    outletName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontFamily: 'serif',
                    ),
                  ),
                ],
              ),
              Text(
                dateString,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 9.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.black, thickness: 1.8, height: 8),

          // Ana Manşet
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              headline.toUpperCase(),
              style: TextStyle(
                color: isPositive ? const Color(0xFF0F5132) : const Color(0xFF842029),
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                height: 1.15,
                letterSpacing: 0.2,
              ),
            ),
          ),

          // Alt Başlık / Haber Detayı
          Text(
            subhead,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 11,
              fontFamily: 'serif',
              height: 1.35,
            ),
          ),

          // Yazar / Köşe Yazısı Alıntısı
          if (columnQuote != null && columnQuote!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                border: const Border(left: BorderSide(color: Colors.black, width: 2.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    columnQuote!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'serif',
                    ),
                  ),
                  if (reporter != null && reporter!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '— $reporter',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
