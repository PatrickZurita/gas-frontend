import 'package:flutter/material.dart';

class CompactListItem extends StatelessWidget {
  const CompactListItem({
    required this.title,
    required this.trailing,
    required this.details,
    this.showDivider = false,
    this.maxTitleLines = 2,
    super.key,
  });

  final String title;
  final String trailing;
  final List<Widget> details;
  final bool showDivider;
  final int maxTitleLines;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border:
            showDivider
                ? Border(bottom: BorderSide(color: colors.outlineVariant))
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: maxTitleLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: details,
          ),
        ],
      ),
    );
  }
}
