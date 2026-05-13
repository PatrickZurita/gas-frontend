import 'package:flutter/material.dart';

import 'quantity_button.dart';

class NumberInputControl extends StatefulWidget {
  const NumberInputControl({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.minValue = 1,
    this.maxValue = 999,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final int minValue;
  final int maxValue;
  final VoidCallback? onChanged;

  @override
  State<NumberInputControl> createState() => _NumberInputControlState();
}

class _NumberInputControlState extends State<NumberInputControl> {
  int get _cantidad {
    final parsed = int.tryParse(widget.controller.text.trim()) ?? widget.minValue;
    return parsed.clamp(widget.minValue, widget.maxValue);
  }

  void _setCantidad(int value) {
    widget.controller.text =
        value.clamp(widget.minValue, widget.maxValue).toString();
    widget.onChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final cantidad = _cantidad;
    final canDecrement = widget.enabled && cantidad > widget.minValue;
    final canIncrement = widget.enabled && cantidad < widget.maxValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 28, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              QuantityButton(
                icon: Icons.remove,
                onPressed: canDecrement ? () => _setCantidad(cantidad - 1) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.onSurface,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) {
                      widget.onChanged?.call();
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              QuantityButton(
                icon: Icons.add,
                onPressed: canIncrement ? () => _setCantidad(cantidad + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
