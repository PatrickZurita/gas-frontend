import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/data_chip.dart';
import '../../../shared/loading_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/number_input_control.dart';
import '../../../shared/summary_card.dart';
import '../models/stock_requests.dart';
import '../models/stock_resumen.dart';
import '../services/stock_service.dart';

class StockHoySection extends StatefulWidget {
  const StockHoySection({required this.stockService, super.key});

  final StockService stockService;

  @override
  State<StockHoySection> createState() => _StockHoySectionState();
}

class _StockHoySectionState extends State<StockHoySection> {
  late Future<StockResumen> _stockFuture;

  @override
  void initState() {
    super.initState();
    _loadStock();
  }

  void _loadStock() {
    _stockFuture = widget.stockService.obtenerResumenHoy();
  }

  void _retry() {
    setState(_loadStock);
  }

  Future<void> _iniciarDia() async {
    final cantidad = await showDialog<int>(
      context: context,
      builder:
          (_) => const _StockNumberDialog(
            title: 'Registrar stock de hoy',
            description: 'Cuenta los balones del deposito y registra el total.',
            confirmLabel: 'Guardar stock',
            icon: Icons.flag_outlined,
            allowZero: true,
          ),
    );
    if (cantidad == null) {
      return;
    }

    await _runOperation(
      () => widget.stockService.iniciarDia(
        StockIniciarDiaRequest(fecha: DateTime.now(), stockInicial: cantidad),
      ),
      successMessage: 'Stock de hoy registrado',
    );
  }

  Future<void> _registrarEntrada() async {
    final cantidad = await showDialog<int>(
      context: context,
      builder:
          (_) => const _StockNumberDialog(
            title: 'Agregar balones',
            description: 'Usa esto cuando llegaron balones al deposito.',
            confirmLabel: 'Guardar entrada',
            icon: Icons.add_circle_outline,
            initialValue: 1,
          ),
    );
    if (cantidad == null) {
      return;
    }

    await _runOperation(
      () => widget.stockService.registrarEntrada(
        StockEntradaRequest(fecha: DateTime.now(), cantidad: cantidad),
      ),
      successMessage: 'Entrada guardada',
    );
  }

  Future<void> _ajustarStock(int? stockActual) async {
    final cantidad = await showDialog<int>(
      context: context,
      builder:
          (_) => _StockNumberDialog(
            title: 'Actualizar stock actual',
            description: 'Registra cuantos balones tienes fisicamente ahora.',
            confirmLabel: 'Actualizar stock',
            icon: Icons.fact_check_outlined,
            initialValue: stockActual ?? 0,
            allowZero: true,
          ),
    );
    if (cantidad == null) {
      return;
    }

    await _runOperation(
      () => widget.stockService.ajustarStock(
        StockAjusteRequest(fecha: DateTime.now(), stockFisico: cantidad),
      ),
      successMessage: 'Stock actualizado',
    );
  }

  Future<void> _runOperation(
    Future<Object> Function() operation, {
    required String successMessage,
  }) async {
    try {
      await operation();
      if (mounted) {
        _retry();
        _showMessage(successMessage);
      }
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo actualizar el stock.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StockResumen>(
      future: _stockFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCard(
            message: 'Cargando stock...',
            icon: Icons.inventory_2_outlined,
          );
        }

        if (snapshot.hasError) {
          return SummaryCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Stock de hoy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                MessageBox(
                  message: _errorMessage(snapshot.error),
                  type: MessageBoxType.error,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          );
        }

        final stock = snapshot.data;
        if (stock == null) {
          return const SizedBox.shrink();
        }

        return _StockContent(
          stock: stock,
          onIniciarDia: _iniciarDia,
          onRegistrarEntrada: _registrarEntrada,
          onAjustarStock: () => _ajustarStock(stock.stockActual),
        );
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'No se pudo cargar el stock.';
  }
}

class _StockContent extends StatelessWidget {
  const _StockContent({
    required this.stock,
    required this.onIniciarDia,
    required this.onRegistrarEntrada,
    required this.onAjustarStock,
  });

  final StockResumen stock;
  final VoidCallback onIniciarDia;
  final VoidCallback onRegistrarEntrada;
  final VoidCallback onAjustarStock;

  @override
  Widget build(BuildContext context) {
    if (!stock.stockIniciado) {
      return SummaryCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stock de hoy',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Todavia no se registro cuantos balones hay en el deposito.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cuenta los balones y guarda el numero.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onIniciarDia,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Registrar stock de hoy'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Balones disponibles',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${stock.stockActual ?? 0}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Stock actual en deposito',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DataChip(label: 'Vendidos hoy', value: '${stock.salidas}'),
              DataChip(label: 'Inicio', value: '${stock.stockInicial ?? 0}'),
              if (stock.entradas > 0)
                DataChip(label: 'Entradas', value: '${stock.entradas}'),
              if (stock.ajustes > 0)
                DataChip(label: 'Ajustes', value: '${stock.ajustes}'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAjustarStock,
              icon: const Icon(Icons.fact_check_outlined),
              label: const Text('Actualizar stock actual'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRegistrarEntrada,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Agregar entrada'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockNumberDialog extends StatefulWidget {
  const _StockNumberDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.icon,
    this.initialValue = 0,
    this.allowZero = false,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final IconData icon;
  final int initialValue;
  final bool allowZero;

  @override
  State<_StockNumberDialog> createState() => _StockNumberDialogState();
}

class _StockNumberDialogState extends State<_StockNumberDialog> {
  late final TextEditingController _cantidadController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cantidadController = TextEditingController(
      text: widget.initialValue.toString(),
    );
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  void _submit() {
    final cantidad = int.tryParse(_cantidadController.text.trim());
    final isValid =
        cantidad != null && (widget.allowZero ? cantidad >= 0 : cantidad > 0);
    if (!isValid) {
      setState(() {
        _error =
            widget.allowZero
                ? 'Ingresa 0 o mas balones.'
                : 'Ingresa una cantidad mayor a 0.';
      });
      return;
    }

    Navigator.of(context).pop(cantidad);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.description, style: const TextStyle(fontSize: 17)),
          const SizedBox(height: 16),
          NumberInputControl(
            controller: _cantidadController,
            label: 'Cantidad',
            icon: widget.icon,
            minValue: widget.allowZero ? 0 : 1,
            maxValue: 9999,
            onChanged: () {
              setState(() {
                _error = null;
              });
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

