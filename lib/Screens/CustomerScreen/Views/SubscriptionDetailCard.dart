import 'package:flutter/material.dart';

class SubscriptionDetailsCard extends StatelessWidget {
  final String currentPlan;
  final String planPrice;
  final String startDate;
  final String endDate;
  final String? endNote; 
  final List<String> variationTitles;
  final VoidCallback onRenew;
  final VoidCallback onCancel;
  final VoidCallback onPause;
  final String activeSubscriptionId;
  final String customerProfileId;

  const SubscriptionDetailsCard({
    super.key,
    required this.currentPlan,
    required this.planPrice,
    required this.startDate,
    required this.endDate,
    this.endNote,
    required this.variationTitles,
    required this.onRenew,
    required this.onCancel,
    required this.onPause, 
    required this.activeSubscriptionId,
    required this.customerProfileId,
  });

  @override
  Widget build(BuildContext context) {
    const captionStyle = TextStyle(
      color: Color(0xFF717182),
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.4,
    );

    const valueStyle = TextStyle(
      color: Colors.black,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.2,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 18),

          // Row 1: Current plan | Plan price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(
                  caption: 'CURRENT PLAN',
                  value: currentPlan,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledValue(
                  caption: 'PLAN PRICE',
                  value: planPrice,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Row 2: Start date | End date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LabeledValue(
                  caption: 'START DATE',
                  value: startDate,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _LabeledValue(
                  caption: 'END DATE',
                  value: endDate,
                  subtitle: endNote,
                  captionStyle: captionStyle,
                  valueStyle: valueStyle,
                  subtitleStyle: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 28, color: Color(0xFFE5E5EA)),

          const Text('PLAN VARIATIONS', style: captionStyle),
          const SizedBox(height: 10),

          if (variationTitles.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: variationTitles
                  .map(
                    (title) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            const Text(
              'No variations found',
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 18),

          // ✅ Renew Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onRenew,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0474B9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              child: const Text('Renew Subscription'),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Pause Button (new)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onPause,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0474B9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFF0474B9),
                backgroundColor: const Color(0xFFE9F6FF),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              child: const Text('Pause Subscription'),
            ),
          ),

          const SizedBox(height: 12),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE8E8EE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: const Color(0xFFDF3B2F),
                textStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text('Cancel Subscription'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String caption;
  final String value;
  final String? subtitle;
  final TextStyle captionStyle;
  final TextStyle valueStyle;
  final TextStyle? subtitleStyle;

  const _LabeledValue({
    required this.caption,
    required this.value,
    this.subtitle,
    required this.captionStyle,
    required this.valueStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: captionStyle),
        const SizedBox(height: 6),
        Text(value, style: valueStyle),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: subtitleStyle),
        ],
      ],
    );
  }
}
