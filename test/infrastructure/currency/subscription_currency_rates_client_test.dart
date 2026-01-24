import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subctrl/domain/entities/currency.dart';
import 'package:subctrl/domain/entities/currency_rate.dart';
import 'package:subctrl/domain/entities/subscription.dart';
import 'package:subctrl/domain/repositories/currency_repository.dart';
import 'package:subctrl/infrastructure/currency/proxy_currency_client.dart';
import 'package:subctrl/infrastructure/currency/subscription_currency_rates_client.dart';

class _MockProxyCurrencyRatesClient extends Mock
    implements ProxyCurrencyRatesClient {}

class _MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late SubscriptionCurrencyRatesClient client;
  late _MockProxyCurrencyRatesClient proxyClient;
  late _MockCurrencyRepository currencyRepository;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    proxyClient = _MockProxyCurrencyRatesClient();
    currencyRepository = _MockCurrencyRepository();
    client = SubscriptionCurrencyRatesClient(
      proxyCurrencyClient: proxyClient,
      currencyRepository: currencyRepository,
    );
  });

  test('fetchRates seeds currencies before requesting Finance data', () async {
    when(currencyRepository.seedIfEmpty).thenAnswer((_) async {});
    when(() => currencyRepository.getCurrencies(onlyEnabled: true)).thenAnswer(
      (_) async => const [
        Currency(
          code: 'USD',
          name: 'US Dollar',
          symbol: r'$',
          isEnabled: true,
          isCustom: false,
        ),
        Currency(
          code: 'EUR',
          name: 'Euro',
          symbol: '€',
          isEnabled: true,
          isCustom: false,
        ),
      ],
    );
    final expectedRates = [
      CurrencyRate(
        baseCode: 'USD',
        quoteCode: 'EUR',
        rate: 1.12,
        fetchedAt: DateTime.utc(2024, 1, 1),
      ),
    ];
    when(
      () => proxyClient.fetchRates(
        baseCode: any(named: 'baseCode'),
        quoteCodes: any(named: 'quoteCodes'),
      ),
    ).thenAnswer((_) async => expectedRates);

    final result = await client.fetchRates(
      baseCurrencyCode: 'usd',
      subscriptions: [
        Subscription(
          name: 'Test',
          amount: 10,
          currency: 'eur',
          cycle: BillingCycle.monthly,
          purchaseDate: DateTime(2024, 1, 1),
        ),
      ],
    );

    expect(result, equals(expectedRates));
    verify(currencyRepository.seedIfEmpty).called(1);
    verify(() => currencyRepository.getCurrencies(onlyEnabled: true)).called(1);
    verify(
      () => proxyClient.fetchRates(baseCode: 'USD', quoteCodes: {'EUR'}),
    ).called(1);
  });
}
