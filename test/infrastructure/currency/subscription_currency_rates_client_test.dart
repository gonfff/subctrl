import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/infrastructure/currency/subscription_currency_rates_client.dart';
import 'package:subtrackr/infrastructure/currency/yahoo_finance_client.dart';
import 'package:subtrackr/infrastructure/repositories/currency_repository.dart';

class _MockYahooFinanceCurrencyClient extends Mock
    implements YahooFinanceCurrencyClient {}

class _MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late SubscriptionCurrencyRatesClient client;
  late _MockYahooFinanceCurrencyClient yahooClient;
  late _MockCurrencyRepository currencyRepository;

  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    yahooClient = _MockYahooFinanceCurrencyClient();
    currencyRepository = _MockCurrencyRepository();
    client = SubscriptionCurrencyRatesClient(
      yahooFinanceCurrencyClient: yahooClient,
      currencyRepository: currencyRepository,
    );
  });

  test(
    'fetchRates seeds currencies before requesting Yahoo Finance data',
    () async {
      when(currencyRepository.seedIfEmpty).thenAnswer((_) async {});
      when(
        () => currencyRepository.getCurrencies(onlyEnabled: true),
      ).thenAnswer(
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
        () => yahooClient.fetchRates(
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
      verify(() => currencyRepository.getCurrencies(onlyEnabled: true))
          .called(1);
      verify(
        () => yahooClient.fetchRates(
          baseCode: 'USD',
          quoteCodes: {'EUR'},
        ),
      ).called(1);
    },
  );
}
