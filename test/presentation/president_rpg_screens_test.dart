// test/presentation/president_rpg_screens_test.dart
// Widget tests for President RPG depth screens and modals.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol/domain/entities/facility.dart';
import 'package:futbol/domain/entities/player.dart';
import 'package:futbol/domain/president/president_crisis.dart';
import 'package:futbol/domain/president/president_origin.dart';
import 'package:futbol/presentation/screens/affiliate_clubs_screen.dart';
import 'package:futbol/presentation/screens/board_faction_screen.dart';
import 'package:futbol/presentation/screens/clubs_association_summit_screen.dart';
import 'package:futbol/presentation/screens/grassroots_tournament_screen.dart';
import 'package:futbol/presentation/screens/legal_defense_screen.dart';
import 'package:futbol/presentation/screens/midnight_tv_debate_screen.dart';
import 'package:futbol/presentation/screens/player_agent_meeting_screen.dart';
import 'package:futbol/presentation/screens/president_luxury_lifestyle_screen.dart';
import 'package:futbol/presentation/screens/transfer_hijack_screen.dart';
import 'package:futbol/presentation/widgets/contractor_tender_modal.dart';
import 'package:futbol/presentation/widgets/counterfeit_raid_modal.dart';
import 'package:futbol/presentation/widgets/foreign_takeover_dialog.dart';
import 'package:futbol/presentation/widgets/hostile_takeover_rescue_modal.dart';
import 'package:futbol/presentation/widgets/president_origin_selection_widget.dart';
import 'package:futbol/presentation/widgets/president_statue_unveiling_modal.dart';
import 'package:futbol/presentation/widgets/presidential_directives_modal.dart';
import 'package:futbol/presentation/widgets/ref_tunnel_confrontation_dialog.dart';
import 'package:futbol/presentation/widgets/tax_audit_inspection_modal.dart';
import 'package:futbol/presentation/widgets/under_the_table_bribe_dialog.dart';
import 'package:futbol/presentation/widgets/urgent_phone_call_modal.dart';
import 'package:futbol/presentation/widgets/victory_bus_parade_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

Player _createDummyPlayer() {
  return const Player(
    id: 'p_test',
    firstName: 'Yasin',
    lastName: 'Kara',
    countryCode: 'TR',
    position: Position.st,
    age: 24,
    pace: 85,
    shooting: 80,
    passing: 75,
    technique: 80,
    defending: 40,
    physical: 78,
    mentality: 75,
    potential: 88,
    weeklyWage: 5000,
    contractSeasonsLeft: 3,
    releaseClause: 65000,
    personality: PersonalityType.ambitious,
    morale: 80,
    fitness: 90,
    form: 7.5,
    sharpness: 85,
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('President RPG Screens Smoke Tests', () {
    testWidgets('BoardFactionScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: BoardFactionScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('YÖNETİM İÇİ HİZİPLER'), findsWidgets);
    });

    testWidgets('PlayerAgentMeetingScreen renders correctly', (tester) async {
      final player = _createDummyPlayer();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: PlayerAgentMeetingScreen(player: player)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('LÜKS RESTORAN'), findsWidgets);
    });

    testWidgets('TransferHijackScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: TransferHijackScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('TRANSFER ÇALIMI'), findsWidgets);
    });

    testWidgets('LegalDefenseScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LegalDefenseScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('HUKUK BÜROSU'), findsWidgets);
    });

    testWidgets('MidnightTvDebateScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: MidnightTvDebateScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('CANLI YAYIN'), findsWidgets);
    });

    testWidgets('PresidentLuxuryLifestyleScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: PresidentLuxuryLifestyleScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('LÜKS YAŞAMI'), findsWidgets);
    });

    testWidgets('ClubsAssociationSummitScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ClubsAssociationSummitScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('KULÜPLER BİRLİĞİ'), findsWidgets);
    });

    testWidgets('GrassrootsTournamentScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GrassrootsTournamentScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('GELECEĞİN YILDIZLARI'), findsWidgets);
    });

    testWidgets('AffiliateClubsScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: AffiliateClubsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('PİLOT TAKIM'), findsWidgets);
    });
  });

  group('President RPG Modals & Dialogs Smoke Tests', () {
    testWidgets('UrgentPhoneCallModal renders choices', (tester) async {
      final caller = PresidentCrisisCall.getPredefinedCalls().first;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: UrgentPhoneCallModal(call: caller))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('ACİL ÇAĞRI'), findsWidgets);
    });

    testWidgets('RefTunnelConfrontationDialog renders choices', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: RefTunnelConfrontationDialog(onConfrontationComplete: (_) {}))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('DEVRE ARASI KORİDOR BASKINI'), findsWidgets);
    });

    testWidgets('PresidentialDirectivesModal renders actions', (tester) async {
      final player = _createDummyPlayer();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: PresidentialDirectivesModal(players: [player]))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('BAŞKANLIK KADRO TALİMATLARI'), findsWidgets);
    });

    testWidgets('PresidentOriginSelectionWidget renders 4 archetypes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PresidentOriginSelectionWidget(
                selectedOrigin: PresidentOriginType.industrialist,
                onOriginSelected: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('BAŞKANLIK GEÇMİŞİ'), findsWidgets);
    });

    testWidgets('ForeignTakeoverDialog renders offers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: ForeignTakeoverDialog())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('YABANCI FON'), findsWidgets);
    });

    testWidgets('TaxAuditInspectionModal renders scenarios', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: TaxAuditInspectionModal())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('MALİYE MÜFETTİŞİ'), findsWidgets);
    });

    testWidgets('ContractorTenderModal renders contractors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ContractorTenderModal(
                facilityType: FacilityType.stadium,
                baseCost: 15000,
                onContractorSelected: (_, __, ___) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('MÜTEAHHİT İHALESİ'), findsWidgets);
    });

    testWidgets('UnderTheTableBribeDialog renders bribes', (tester) async {
      final player = _createDummyPlayer();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: UnderTheTableBribeDialog(player: player))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('GİZLİ PRİM'), findsWidgets);
    });

    testWidgets('CounterfeitRaidModal renders raid actions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: CounterfeitRaidModal())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('KORSAN ÜRÜNLE'), findsWidgets);
    });

    testWidgets('PresidentStatueUnveilingModal renders statue actions', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: PresidentStatueUnveilingModal())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('HEYKEL DİKME'), findsWidgets);
    });

    testWidgets('VictoryBusParadeDialog renders bus parade options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: VictoryBusParadeDialog())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('ŞEHİR TURU'), findsWidgets);
    });

    testWidgets('HostileTakeoverRescueModal renders bailout options', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: HostileTakeoverRescueModal())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('ACİL KULÜP KURTARMA'), findsWidgets);
    });
  });
}
