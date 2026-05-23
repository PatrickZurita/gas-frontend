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
  State<StockHoySection> createState() => StockHoySectionState();
}

class StockHoySectionState extends State<StockHoySection> {
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

  Future<void> refresh() async {
    late final Future<StockResumen> nextFuture;
    setState(() {
      nextFuture = widget.stockService.obtenerResumenHoy();
      _stockFuture = nextFuture;
    });
    try {
      await nextFuture;
    } catch (_) {
      // FutureBuilder renders the latest error state.
    }
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
    final resultado = await showDialog<_StockPesoCantidadResult>(
      context: context,
      builder: (_) => const _StockPesoCantidadDialog(
        title: 'Agregar balones',
        description: 'Usa esto cuando llegaron balones al deposito.',
        confirmLabel: 'Guardar entrada',
        icon: Icons.add_circle_outline,
        initialValue: 1,
      ),
    );
    if (resultado == null) {
      return;
    }

    await _runOperation(
      () => widget.stockService.registrarEntrada(
        StockEntradaRequest(
          fecha: DateTime.now(),
          cantidad: resultado.cantidad,
          pesoBalonKg: resultado.pesoKg,
        ),
      ),
      successMessage: 'Entrada guardada (${resultado.pesoKg} kg)',
    );
  }

  Future<void> _ajustarStock(StockResumen stock) async {
    final porPeso = stock.porPeso;
    final stock10 = porPeso?.stockActual10kg ?? stock.stockActual ?? 0;
    final stock45 = porPeso?.stockActual45kg ?? 0;

    final resultado = await showDialog<_StockPesoCantidadResult>(
      context: context,
      builder: (_) => _StockPesoCantidadDialog(
        title: 'Actualizar stock actual',
        description:
            'Cuenta los balones del peso que vas a actualizar y registra el total.',
        confirmLabel: 'Actualizar stock',
        icon: Icons.fact_check_outlined,
        initialValue: stock10,
        allowZero: true,
        initialValueFor45kg: stock45,
      ),
    );
    if (resultado == null) {
      return;
    }

    await _runOperation(
      () => widget.stockService.ajustarStock(
        StockAjusteRequest(
          fecha: DateTime.now(),
          stockFisico: resultado.cantidad,
          pesoBalonKg: resultado.pesoKg,
        ),
      ),
      successMessage: 'Stock ${resultado.pesoKg} kg actualizado',
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
          onAjustarStock: () => _ajustarStock(stock),
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

    final porPeso = stock.porPeso;
    final stock10 = porPeso?.stockActual10kg ?? stock.stockActual ?? 0;
    final stock45 = porPeso?.stockActual45kg ?? 0;

    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balones disponibles',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StockPesoCard(
                  pesoLabel: '10 kg',
                  cantidad: stock10,
                  icon: Icons.propane_tank_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StockPesoCard(
                  pesoLabel: '45 kg',
                  cantidad: stock45,
                  icon: Icons.propane_tank,
                ),
              ),
            ],
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
              if (stock.ajustes != 0)
                DataChip(
                  label: 'Ajuste manual',
                  value: _formatAjustes(stock.ajustes),
                ),
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

  String _formatAjustes(int ajustes) {
    if (ajustes > 0) {
      return '+$ajustes';
    }
    return '$ajustes';
  }
}

class _StockPesoCard extends StatelessWidget {
  const _StockPesoCard({
    required this.pesoLabel,
    required this.cantidad,
    required this.icon,
  });

  final String pesoLabel;
  final int cantidad;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sinStock = cantidad <= 0;
    final bgColor = sinStock
        ? colors.errorContainer.withValues(alpha: 0.45)
        : colors.primaryContainer.withValues(alpha: 0.55);
    final borderColor = sinStock ? colors.error : colors.primary;
    final cantidadColor = sinStock ? colors.error : colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: borderColor),
              const SizedBox(width: 6),
              Text(
                pesoLabel,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$cantidad',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: cantidadColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sinStock ? 'Sin stock' : 'disponibles',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cantidadColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockPesoCantidadResult {
  const _StockPesoCantidadResult({required this.pesoKg, required this.cantidad});

  final int pesoKg;
  final int cantidad;
}

class _StockPesoCantidadDialog extends StatefulWidget {
  const _StockPesoCantidadDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.icon,
    this.initialValue = 0,
    this.initialValueFor45kg,
    this.allowZero = false,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final IconData icon;
  final int initialValue;

  /// Si se provee, al cambiar a 45kg el campo de cantidad se actualiza a
  /// este valor (utilizado por el ajuste para precargar el stock actual de
  /// cada peso). Si es null, se mantiene `initialValue` para ambos.
  final int? initialValueFor45kg;
  final bool allowZero;

  @override
  State<_StockPesoCantidadDialog> createState() =>
      _StockPesoCantidadDialogState();
}

class _StockPesoCantidadDialogState extends State<_StockPesoCantidadDialog> {
  late final TextEditingController _cantidadController;
  int _pesoKg = 10;
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

  void _onPesoChanged(int peso) {
    final inicial = widget.initialValueFor45kg;
    if (inicial != null) {
      final nuevoValor = peso == 45 ? inicial : widget.initialValue;
      _cantidadController.text = nuevoValor.toString();
    }
    setState(() {
      _pesoKg = peso;
      _error = null;
    });
  }

  void _submit() {
    final cantidad = int.tryParse(_cantidadController.text.trim());
    final isValid =
        cantidad != null && (widget.allowZero ? cantidad >= 0 : cantidad > 0);
    if (!isValid) {
      setState(() {
        _error = widget.allowZero
            ? 'Ingresa 0 o mas balones.'
            : 'Ingresa una cantidad mayor a 0.';
      });
      return;
    }

    Navigator.of(context).pop(
      _StockPesoCantidadResult(pesoKg: _pesoKg, cantidad: cantidad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.description, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 16),
            const Text(
              'Peso del balon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 10,
                  label: Text('10 kg'),
                  icon: Icon(Icons.propane_tank_outlined),
                ),
                ButtonSegment<int>(
                  value: 45,
                  label: Text('45 kg'),
                  icon: Icon(Icons.propane_tank),
                ),
              ],
              selected: {_pesoKg},
              onSelectionChanged: (selection) => _onPesoChanged(selection.first),
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size.fromHeight(54)),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
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

class _StockNumberDialog extends StatefulWidget {
  const _StockNumberDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.icon,
    this.allowZero = false,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final IconData icon;
  final int initialValue = 0;
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

