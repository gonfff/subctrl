import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/domain/entities/donation_wallet.dart';
import 'package:subctrl/domain/services/donation_wallets_provider.dart';
import 'package:subctrl/infrastructure/support/resilient_donation_wallets_provider.dart';

class _MockDonationWalletsProvider extends Mock
    implements DonationWalletsProvider {}

void main() {
  late _MockDonationWalletsProvider primary;
  late ResilientDonationWalletsProvider provider;
  const fallbackWallets = [DonationWallet(label: 'BTC', address: 'btc')];

  setUp(() {
    primary = _MockDonationWalletsProvider();
    provider = ResilientDonationWalletsProvider(
      primary: primary,
      fallbackWallets: fallbackWallets,
    );
  });

  test('returns primary wallets when available', () async {
    when(() => primary.fetchWallets()).thenAnswer(
      (_) async => const [DonationWallet(label: 'SOL', address: 'sol')],
    );

    final wallets = await provider.fetchWallets();

    expect(wallets.single.label, 'SOL');
  });

  test('returns fallback when primary returns empty list', () async {
    when(() => primary.fetchWallets()).thenAnswer((_) async => const []);

    final wallets = await provider.fetchWallets();

    expect(wallets.single.label, 'BTC');
  });

  test('returns fallback when primary throws', () async {
    when(() => primary.fetchWallets()).thenThrow(Exception('network'));

    final wallets = await provider.fetchWallets();

    expect(wallets.single.address, 'btc');
  });
}
