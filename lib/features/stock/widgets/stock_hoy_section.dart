import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
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
    final request = await showDialog<StockIniciarDiaRequest>(
      context: context,
      builder:
          (_) => const _StockNumberDialog(
            title: 'Iniciar dia',
            label: 'Balones al empezar',
            confirmLabel: 'Iniciar dia',
            icon: Icons.flag_outlined,
          ),
    );
    if (request == null) {
      return;
    }

    await _runOperation(() => widget.stockService.iniciarDia(request));
  }

  Future<void> _registrarEntrada() async {
    final request = await showDialog<StockEntradaRequest>(
      context: context,
      builder:
          (_) => const _StockNumberDialog(
            title: 'Agregar balones',
            label: 'Balones recibidos',
            confirmLabel: 'Guardar entrada',
            icon: Icons.add_circle_outline,
          ),
    );
    if (request == null) {
      return;
    }

    await _runOperation(() => widget.stockService.registrarEntrada(request));
  }

  Future<void> _ajustarStock() async {
    final request = await showDialog<StockAjusteRequest>(
      context: context,
      builder:
          (_) => const _StockNumberDialog(
            title: 'Ajustar stock',
            label: 'Balones fisicos ahora',
            confirmLabel: 'Ajustar stock',
            icon: Icons.tune,
            allowZero: true,
          ),
    );
    if (request == null) {
      return;
    }

    await _runOperation(() => widget.stockService.ajustarStock(request));
  }

  Future<void> _runOperation(Future<Object> Function() operation) async {
    try {
      await operation();
      if (mounted) {
        _retry();
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
          return const _StockFrame(
            child: Column(
              children: [
                SizedBox(height: 8),
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Cargando stock...', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _StockFrame(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Stock de hoy',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(_errorMessage(snapshot.error)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
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
          onAjustarStock: _ajustarStock,
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
      return _StockFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Stock de hoy',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Todavia no se registro el stock del dia.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onIniciarDia,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Iniciar dia'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      );
    }

    return _StockFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Stock de hoy',
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
            'Inicio ${stock.stockInicial ?? 0} · Vendidos ${stock.salidas} · Entradas ${stock.entradas} · Ajustes ${stock.ajustes}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRegistrarEntrada,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Agregar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAjustarStock,
                  icon: const Icon(Icons.tune),
                  label: const Text('Ajustar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockFrame extends StatelessWidget {
  const _StockFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _StockNumberDialog extends StatefulWidget {
  const _StockNumberDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    required this.icon,
    this.allowZero = false,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final IconData icon;
  final bool allowZero;

  @override
  State<_StockNumberDialog> createState() => _StockNumberDialogState();
}

class _StockNumberDialogState extends State<_StockNumberDialog> {
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _observacionController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _cantidadController.dispose();
    _observacionController.dispose();
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

    final fecha = DateTime.now();
    final observacion = _observacionController.text.trim();
    final note = observacion.isEmpty ? null : observacion;

    if (widget.title == 'Iniciar dia') {
      Navigator.of(context).pop(
        StockIniciarDiaRequest(
          fecha: fecha,
          stockInicial: cantidad,
          observacion: note,
        ),
      );
    } else if (widget.title == 'Agregar balones') {
      Navigator.of(context).pop(
        StockEntradaRequest(
          fecha: fecha,
          cantidad: cantidad,
          observacion: note,
        ),
      );
    } else {
      Navigator.of(context).pop(
        StockAjusteRequest(
          fecha: fecha,
          stockFisico: cantidad,
          observacion: note,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _cantidadController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: const TextStyle(fontSize: 22),
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(widget.icon),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _observacionController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Observacion opcional',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
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
