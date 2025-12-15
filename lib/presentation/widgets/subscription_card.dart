import 'package:flutter/cupertino.dart';
import 'package:subtrackr/domain/entities/currency.dart';
import 'package:subtrackr/domain/entities/currency_rate.dart';
import 'package:subtrackr/domain/entities/subscription.dart';
import 'package:subtrackr/domain/entities/tag.dart';
import 'package:subtrackr/presentation/formatters/currency_formatter.dart';
import 'package:subtrackr/presentation/formatters/date_formatter.dart';
import 'package:subtrackr/presentation/l10n/app_localizations.dart';
import 'package:subtrackr/presentation/theme/app_theme.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.subscription,
    this.currency,
    this.rateMap,
    this.baseCurrency,
    this.baseCurrencyCode,
    this.onTap,
    this.tag,
    super.key,
  });

  final Subscription subscription;
  final Currency? currency;
  final Map<String, CurrencyRate>? rateMap;
  final Currency? baseCurrency;
  final String? baseCurrencyCode;
  final VoidCallback? onTap;
  final Tag? tag;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppTheme.cardBackgroundColor(context);
    final textTheme = CupertinoTheme.of(context).textTheme;
    final baseStyle = textTheme.textStyle;
    final localizations = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      subscription.name,
                      style: baseStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusIndicator(isActive: subscription.isActive),
                  const SizedBox(width: 6),
                  if (tag != null)
                    SubscriptionTag(
                      label: tag!.name,
                      color: _colorFromHex(tag!.colorHex),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatAmountWithCurrency(
                subscription.amount,
                subscription.currency,
                currency: currency,
              ),
              style: baseStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: baseStyle.copyWith(fontSize: 13),
                  children: [
                    TextSpan(
                      text: '${localizations.nextPaymentPrefix}: ',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                    TextSpan(
                      text: formatDate(subscription.nextPaymentDate, locale),
                      style: baseStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: baseStyle.color ??
                            CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            _BaseCurrencyValue(
              subscription: subscription,
              rateMap: rateMap,
              baseCurrency: baseCurrency,
              baseCurrencyCode: baseCurrencyCode,
            ),
          ],
        ),
      ],
    );
    if (onTap == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: content,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [content],
          ),
        ),
      ),
    );
  }
}

class SubscriptionTag extends StatelessWidget {
  const SubscriptionTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? CupertinoColors.systemGreen.resolveFrom(context)
        : CupertinoColors.systemRed.resolveFrom(context);
    final icon = isActive
        ? CupertinoIcons.check_mark_circled_solid
        : CupertinoIcons.xmark_circle_fill;
    return Icon(icon, size: 18, color: color);
  }
}

Color _colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '').padLeft(6, '0');
  final value = int.parse(normalized, radix: 16);
  return Color(0xFF000000 | value);
}

class _BaseCurrencyValue extends StatelessWidget {
  const _BaseCurrencyValue({
    required this.subscription,
    required this.rateMap,
    required this.baseCurrency,
    required this.baseCurrencyCode,
  });

  final Subscription subscription;
  final Map<String, CurrencyRate>? rateMap;
  final Currency? baseCurrency;
  final String? baseCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final baseCode = baseCurrencyCode?.toUpperCase();
    if (rateMap == null || baseCode == null || baseCurrency == null) {
      return const SizedBox.shrink();
    }
    final rates = rateMap!;
    final quoteCode = subscription.currency.toUpperCase();
    if (quoteCode == baseCode) {
      return const SizedBox.shrink();
    }
    final rate = rates[quoteCode];
    if (rate == null) return const SizedBox.shrink();
    final converted = subscription.amount * rate.rate;
    final effectiveBaseCode = rate.baseCode.toUpperCase();
    final formatted = formatAmountWithCurrency(
      converted,
      effectiveBaseCode,
      currency: baseCurrency,
    );

    final displayText = AppLocalizations.of(context).baseCurrencyValue(
      formatted,
    );
    final textStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
          fontSize: 13,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        );

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0),
      child: Text(
        displayText,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      ),
    );
  }
}
