import 'package:subctrl/domain/entities/donation_wallet.dart';
import 'package:subctrl/domain/services/donation_wallets_provider.dart';

class FetchDonationWalletsUseCase {
  FetchDonationWalletsUseCase(this._provider);

  final DonationWalletsProvider _provider;

  Future<List<DonationWallet>> call() {
    return _provider.fetchWallets();
  }
}
