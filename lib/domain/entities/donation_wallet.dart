class DonationWallet {
  const DonationWallet({
    required this.label,
    required this.address,
    this.currency,
    this.name,
    this.network,
  });

  final String label;
  final String address;
  final String? currency;
  final String? name;
  final String? network;
}
