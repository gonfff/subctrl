import 'dart:developer' as developer;

import 'package:subctrl/domain/entities/donation_wallet.dart';
import 'package:subctrl/domain/services/donation_wallets_provider.dart';

class ResilientDonationWalletsProvider implements DonationWalletsProvider {
  ResilientDonationWalletsProvider({
    required DonationWalletsProvider primary,
    required List<DonationWallet> fallbackWallets,
  }) : _primary = primary,
       _fallbackWallets = List<DonationWallet>.unmodifiable(fallbackWallets);

  final DonationWalletsProvider _primary;
  final List<DonationWallet> _fallbackWallets;

  static const _logName = 'ResilientDonationWalletsProvider';

  @override
  Future<List<DonationWallet>> fetchWallets() async {
    try {
      final wallets = await _primary.fetchWallets();
      if (wallets.isNotEmpty) {
        return wallets;
      }
      developer.log(
        'Primary provider returned empty list, using fallback.',
        name: _logName,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Primary provider failed, returning fallback wallets.',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
      );
    }
    return _fallbackWallets;
  }
}
