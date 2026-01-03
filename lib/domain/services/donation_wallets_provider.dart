import 'package:subctrl/domain/entities/donation_wallet.dart';

abstract class DonationWalletsProvider {
  Future<List<DonationWallet>> fetchWallets();
}

class DonationWalletsFetchException implements Exception {
  DonationWalletsFetchException(this.message);

  final String message;

  @override
  String toString() => 'DonationWalletsFetchException: $message';
}
