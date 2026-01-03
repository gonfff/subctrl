import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/domain/services/donation_wallets_provider.dart';
import 'package:subctrl/infrastructure/support/remote_donation_wallets_provider.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient httpClient;
  late RemoteDonationWalletsProvider provider;
  final endpoint = Uri.parse('https://example.com/wallets.json');

  setUp(() {
    httpClient = _MockHttpClient();
    provider = RemoteDonationWalletsProvider(
      endpoint: endpoint,
      httpClient: httpClient,
    );
  });

  tearDown(() {
    provider.close();
  });

  test('fetchWallets returns parsed wallets from payload', () async {
    when(() => httpClient.get(endpoint)).thenAnswer(
      (_) async => http.Response(
        jsonEncode({
          'wallets': [
            {
              'label': 'BTC',
              'address': 'btc-address',
              'currency': 'BTC',
              'name': 'Bitcoin',
              'network': 'Bitcoin',
            },
            {'label': 10, 'address': 'skip-invalid'},
          ],
        }),
        200,
      ),
    );

    final wallets = await provider.fetchWallets();

    expect(wallets, hasLength(1));
    expect(wallets.first.label, 'BTC');
    expect(wallets.first.address, 'btc-address');
  });

  test(
    'fetchWallets throws DonationWalletsFetchException on error status',
    () async {
      when(
        () => httpClient.get(endpoint),
      ).thenAnswer((_) async => http.Response('error', 500));

      await expectLater(
        provider.fetchWallets,
        throwsA(isA<DonationWalletsFetchException>()),
      );
    },
  );
}
