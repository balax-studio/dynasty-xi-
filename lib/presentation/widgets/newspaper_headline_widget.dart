// presentation/widgets/newspaper_headline_widget.dart
// Retro Newspaper Headlines & Gazete Kupürü Widget (§17.5-1, §21.3)

import 'package:flutter/material.dart';

class NewspaperHeadlineWidget extends StatelessWidget {
  final String outletName; // e.g. "FANATİK MANŞET", "FOTOMAÇ", "HÜRRİYET SPOR"
  final String headline;
  final String subhead;
  final String dateString;
  final bool isPositive;

  const NewspaperHeadlineWidget({
    super.key,
    this.outletName = 'FUTBOL GAZETESİ • SON BASKI',
    required this.headline,
    required this.subhead,
    required this.dateString,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6E2), // Old paper / retro newspaper bg
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                outletName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                dateString,
                style: const TextStyle(color: Colors.black54, fontSize: 9, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const Divider(color: Colors.black, thickness: 1.5, height: 10),
          Text(
            headline.toUpperCase(),
            style: TextStyle(
              color: isPositive ? const Color(0xFF0F5132) : const Color(0xFF842029),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subhead,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 10.5,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }
}
