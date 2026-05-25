import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/data_chip.dart';
import '../../../shared/status_badge.dart';
import '../../../shared/summary_card.dart';
import '../../reportes/money_format.dart';
import '../models/pedido.dart';
import '../pedido_service.dart';
import 'editar_pedido_screen.dart';

class DetallePedidoScreen extends StatefulWidget {
  const DetallePedidoScreen({
    required this.pedido,
    required this.pedidoService,
    this.clienteAlias,
    this.onCambioPedido,
    super.key,
  });

  final Pedido pedido;
  final PedidoService pedidoService;
  final String? clienteAlias;
  final Future<void> Function()? onCambioPedido;

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  late Pedido _pedido;
  bool _isAnulando = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedido;
  }

  Future<void> _editar() async {
    final actualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditarPedidoScreen(
          pedido: _pedido,
          pedidoService: widget.pedidoService,
          onPedidoActualizado: widget.onCambioPedido,
        ),
      ),
    );
    if (!mounted) return;
    if (actualizado == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _confirmarAnular() async {
    if (_pedido.esAnulado) {
      return;
    }

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anular pedido'),
        content: const Text(
          'Este pedido ya no contara en ventas ni stock.',
          style: TextStyle(fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor:
                  Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('Anular pedido'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    setState(() {
      _isAnulando = true;
      _message = null;
    });

    try {
      final pedido = await widget.pedidoService.anularPedido(_pedido.id);
      if (!mounted) return;
      setState(() {
        _pedido = pedido;
        _isAnulando = false;
      });
      await widget.onCambioPedido?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido anulado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } on PedidoConflictoException catch (error) {
      if (!mounted) return;
      setState(() {
        _isAnulando = false;
        _message = error.message;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isAnulando = false;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAnulando = false;
        _message = 'No se pudo anular el pedido.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final monto = _pedido.montoTotalCentavos != null
        ? formatSolesFromCentavos(_pedido.montoTotalCentavos!)
        : 'S/ ${_pedido.totalSoles.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del pedido')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.clienteAlias != null) ...[
              Text(
                widget.clienteAlias!,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              _formatDate(_pedido.fechaEntrega),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SummaryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Total',
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        monto,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      DataChip(
                        label: 'Balones',
                        value: '${_pedido.cantidadBalones}',
                      ),
                      DataChip(
                        label: 'Peso',
                        value: '${_pedido.pesoBalonKg} kg',
                      ),
                      DataChip(
                        label: 'Marca',
                        value: _displayCode(_pedido.marcaBalon),
                      ),
                      DataChip(
                        label: 'Tipo',
                        value: _displayCode(_pedido.tipoBalon),
                      ),
                      if (_pedido.pagado && _pedido.metodoPago != null)
                        DataChip(
                          label: 'Pago',
                          value: metodoPagoLabel(_pedido.metodoPago!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatusBadge(
                        label: _pedido.pagado ? 'Pagado' : 'Debe',
                        type: _pedido.pagado
                            ? StatusBadgeType.paid
                            : StatusBadgeType.debt,
                      ),
                      const SizedBox(width: 8),
                      if (_pedido.esAnulado)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                            border:
                                Border.all(color: colors.outline, width: 0.8),
                          ),
                          child: Text(
                            'ANULADO',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_pedido.esAnulado && _pedido.anuladoMotivo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Motivo: ${_pedido.anuladoMotivo}',
                      style: text.titleMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_pedido.esAnulado) ...[
              ActionButton(
                label: 'Editar pedido',
                icon: Icons.edit_outlined,
                primary: true,
                onPressed: _isAnulando ? null : _editar,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isAnulando ? null : _confirmarAnular,
                icon: const Icon(Icons.cancel_outlined, size: 28),
                label: Text(
                  _isAnulando ? 'Anulando...' : 'Anular pedido',
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                ),
              ),
            ] else ...[
              SummaryCard(
                child: Text(
                  'Este pedido esta anulado. No suma a ventas ni stock.',
                  style:
                      text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _displayCode(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
