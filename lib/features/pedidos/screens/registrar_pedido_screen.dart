import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../clientes/models/cliente.dart';
import '../../stock/models/catalogo_item.dart';
import '../../stock/services/stock_service.dart';
import '../models/pedido_create_request.dart';
import '../pedido_service.dart';

class RegistrarPedidoScreen extends StatefulWidget {
  const RegistrarPedidoScreen({
    required this.cliente,
    required this.pedidoService,
    required this.stockService,
    this.onPedidoGuardado,
    super.key,
  });

  final Cliente cliente;
  final PedidoService pedidoService;
  final StockService stockService;
  final Future<void> Function()? onPedidoGuardado;

  @override
  State<RegistrarPedidoScreen> createState() => _RegistrarPedidoScreenState();
}

class _RegistrarPedidoScreenState extends State<RegistrarPedidoScreen> {
  final TextEditingController _cantidadController = TextEditingController(
    text: '1',
  );
  final TextEditingController _precioController = TextEditingController();

  bool _pagado = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _message;
  String _marcaBalon = 'PETROPERU';
  String _tipoBalon = 'NORMAL';
  List<CatalogoItem> _marcas = const [
    CatalogoItem(codigo: 'PETROPERU', nombre: 'Petroperu'),
    CatalogoItem(codigo: 'SOLGAS', nombre: 'Solgas'),
  ];
  List<CatalogoItem> _tipos = const [
    CatalogoItem(codigo: 'NORMAL', nombre: 'Normal'),
    CatalogoItem(codigo: 'PREMIUM', nombre: 'Premium'),
  ];

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCatalogos();
  }

  Future<void> _loadCatalogos() async {
    try {
      final results = await Future.wait([
        widget.stockService.obtenerMarcasBalon(),
        widget.stockService.obtenerTiposBalon(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _marcas = results[0];
        _tipos = results[1];
      });
    } catch (_) {
      // Defaults keep the order flow usable when catalogs cannot load.
    }
  }

  Future<void> _guardarPedido() async {
    if (_isSaving) {
      return;
    }

    final cantidad = int.tryParse(_cantidadController.text.trim());
    final precioCentavos = _parseSolesToCentavos(_precioController.text);

    if (cantidad == null || cantidad <= 0) {
      setState(() {
        _message = 'La cantidad debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

    if (precioCentavos == null || precioCentavos <= 0) {
      setState(() {
        _message = 'El precio debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

    final montoTotalCentavos = cantidad * precioCentavos;

    setState(() {
      _isSaving = true;
      _message = null;
      _saved = false;
    });

    try {
      await widget.pedidoService.crearPedido(
        PedidoCreateRequest(
          clienteId: widget.cliente.id,
          cantidadBalones: cantidad,
          pagado: _pagado,
          marcaBalon: _marcaBalon,
          tipoBalon: _tipoBalon,
          precioUnitarioCentavos: precioCentavos,
          montoTotalCentavos: montoTotalCentavos,
          montoPendienteCentavos: _pagado ? 0 : montoTotalCentavos,
        ),
      );
      if (!mounted) {
        return;
      }
      await widget.onPedidoGuardado?.call();
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = true;
        _message = 'Pedido guardado';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido guardado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = false;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = false;
        _message = 'No se pudo guardar el pedido. Intenta otra vez.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final direccion = widget.cliente.direccion ?? widget.cliente.alias;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar pedido')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Nuevo pedido',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _ClienteBox(
              direccion: direccion,
              telefono: widget.cliente.telefono,
            ),
            const SizedBox(height: 20),
            _CantidadBalonesControl(
              controller: _cantidadController,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Precio por balon',
                hintText: '55',
                helperText: 'No escribas el total',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              onSubmitted: (_) => _guardarPedido(),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            _CatalogSegmented(
              label: 'Marca',
              value: _marcaBalon,
              items: _marcas,
              onChanged:
                  _isSaving
                      ? null
                      : (value) {
                        if (value != null) {
                          setState(() {
                            _marcaBalon = value;
                          });
                        }
                      },
            ),
            const SizedBox(height: 16),
            _CatalogSegmented(
              label: 'Tipo',
              value: _tipoBalon,
              items: _tipos,
              onChanged:
                  _isSaving
                      ? null
                      : (value) {
                        if (value != null) {
                          setState(() {
                            _tipoBalon = value;
                          });
                        }
                      },
            ),
            const SizedBox(height: 20),
            Text(
              'Pagado',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('Si'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('No'),
                  icon: Icon(Icons.pending_outlined),
                ),
              ],
              selected: {_pagado},
              onSelectionChanged:
                  _isSaving
                      ? null
                      : (selection) {
                        setState(() {
                          _pagado = selection.first;
                        });
                      },
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size.fromHeight(60)),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              _OrderMessage(message: _message!, success: _saved),
            if (_message != null) const SizedBox(height: 16),
            ActionButton(
              label: _isSaving ? 'Guardando...' : 'Guardar pedido',
              icon: Icons.save,
              primary: true,
              onPressed: _isSaving ? null : _guardarPedido,
            ),
          ],
        ),
      ),
    );
  }

  int? _parseSolesToCentavos(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }

    final parts = normalized.split('.');
    if (parts.length > 2 || parts.first.isEmpty) {
      return null;
    }

    final soles = int.tryParse(parts[0]);
    if (soles == null || soles < 0) {
      return null;
    }

    var cents = 0;
    if (parts.length == 2) {
      final centsText = parts[1];
      if (centsText.isEmpty || centsText.length > 2) {
        return null;
      }
      cents = int.tryParse(centsText.padRight(2, '0')) ?? -1;
      if (cents < 0) {
        return null;
      }
    }

    return soles * 100 + cents;
  }
}

class _CatalogSegmented extends StatelessWidget {
  const _CatalogSegmented({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<CatalogoItem> items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments:
                items
                    .map(
                      (item) => ButtonSegment<String>(
                        value: item.codigo,
                        label: Text(item.nombre),
                      ),
                    )
                    .toList(),
            selected: {value},
            onSelectionChanged:
                onChanged == null
                    ? null
                    : (selection) => onChanged!(selection.first),
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size.fromHeight(54)),
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}

class _CantidadBalonesControl extends StatefulWidget {
  const _CantidadBalonesControl({
    required this.controller,
    required this.enabled,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  State<_CantidadBalonesControl> createState() =>
      _CantidadBalonesControlState();
}

class _CantidadBalonesControlState extends State<_CantidadBalonesControl> {
  int get _cantidad => int.tryParse(widget.controller.text.trim()) ?? 1;

  @override
  Widget build(BuildContext context) {
    final cantidad = _cantidad.clamp(1, 999);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.propane_tank_outlined, size: 28),
              SizedBox(width: 8),
              Text(
                'Balones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onPressed:
                    widget.enabled && cantidad > 1
                        ? () => _setCantidad(cantidad - 1)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: widget.controller,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _QuantityButton(
                icon: Icons.add,
                onPressed:
                    widget.enabled ? () => _setCantidad(cantidad + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setCantidad(int value) {
    widget.controller.text = value.clamp(1, 999).toString();
    setState(() {});
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Icon(icon, size: 34),
      ),
    );
  }
}

class _ClienteBox extends StatelessWidget {
  const _ClienteBox({required this.direccion, required this.telefono});

  final String direccion;
  final String telefono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cliente', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            direccion,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(telefono, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _OrderMessage extends StatelessWidget {
  const _OrderMessage({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success ? colors.primaryContainer : colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(fontSize: 18)),
    );
  }
}
