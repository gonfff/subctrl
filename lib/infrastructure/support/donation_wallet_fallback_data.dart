import 'package:subctrl/domain/entities/donation_wallet.dart';

const List<DonationWallet> donationWalletFallbackData = [
  DonationWallet(
    label: 'BTC',
    address: 'bc1qjtjzlxel5mn3pvtps2u2wnfease44783r5nmhl',
    currency: 'BTC',
    name: 'Bitcoin',
    network: 'Bitcoin',
  ),
  DonationWallet(
    label: 'USDT (TRON)',
    address: 'TRsN3XgSXdeQz3yoGusW3f94KHsBNE62yR',
    currency: 'USDT',
    name: 'Tether',
    network: 'TRON (TRC20)',
  ),
  DonationWallet(
    label: 'ETH',
    address: '0xDf3275d97DF7Ba76d12ec0F82378C1e0628A5F6F',
    currency: 'ETH',
    name: 'Ethereum',
    network: 'Ethereum',
  ),
  DonationWallet(
    label: 'TON',
    address: 'UQCYgQSiRx5pk5E0ALzhz6WsFjuK3SyPiAe7vYG5uhidsyqj',
    currency: 'TON',
    name: 'Toncoin',
    network: 'TON',
  ),
  DonationWallet(
    label: 'SOL',
    address: '2KRt8ASpGasvMSaWZfgFfrFgb1LaUHzudHfGiEcF9vVK',
    currency: 'SOL',
    name: 'Solana',
    network: 'Solana',
  ),
];
