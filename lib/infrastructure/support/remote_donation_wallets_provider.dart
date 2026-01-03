import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:subctrl/domain/entities/donation_wallet.dart';
import 'package:subctrl/domain/services/donation_wallets_provider.dart';

class RemoteDonationWalletsProvider implements DonationWalletsProvider {
  RemoteDonationWalletsProvider({
    required Uri endpoint,
    http.Client? httpClient,
  }) : _endpoint = endpoint,
       _httpClient = httpClient ?? http.Client();

  final Uri _endpoint;
  final http.Client _httpClient;

  static const _logName = 'RemoteDonationWalletsProvider';

  @override
  Future<List<DonationWallet>> fetchWallets() async {
    try {
      final response = await _httpClient.get(_endpoint);
      if (response.statusCode != 200) {
        throw DonationWalletsFetchException(
          'Wallet request failed with status ${response.statusCode}',
        );
      }
      return _parseResponse(response.body);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to fetch donation wallets',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
      if (error is DonationWalletsFetchException) {
        rethrow;
      }
      throw DonationWalletsFetchException('Unable to load donation wallets.');
    }
  }

  List<DonationWallet> _parseResponse(String body) {
    final decoded = json.decode(body);
    if (decoded is! Map<String, dynamic>) {
      throw DonationWalletsFetchException('Malformed wallets payload.');
    }
    final wallets = decoded['wallets'];
    if (wallets is! List) {
      return const [];
    }
    final parsed = <DonationWallet>[];
    for (final entry in wallets) {
      if (entry is! Map<String, dynamic>) continue;
      final label = entry['label'];
      final address = entry['address'];
      if (label is! String || address is! String) {
        continue;
      }
      parsed.add(
        DonationWallet(
          label: label.trim(),
          address: address.trim(),
          currency: (entry['currency'] as String?)?.trim(),
          name: (entry['name'] as String?)?.trim(),
          network: (entry['network'] as String?)?.trim(),
        ),
      );
    }
    return parsed;
  }

  void close() => _httpClient.close();
}
