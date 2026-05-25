import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/catalog_selector.dart';
import '../../../shared/cliente_info_card.dart';
import '../../../shared/message_box.dart';
import '../../../shared/number_input_control.dart';
import '../../../shared/peso_balon_selector.dart';
import '../../clientes/models/cliente.dart';
import '../../stock/models/catalogo_item.dart';
import '../../stock/models/stock_resumen.dart';
import '../../stock/services/stock_service.dart';
import '../models/pedido.dart';
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
  int _pesoBalonKg = 10;
  MetodoPago _metodoPago = MetodoPago.efectivo;
  StockResumen? _stock;
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
    _loadStock();
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

  Future<void> _loadStock() async {
    try {
      final stock = await widget.stockService.obtenerResumenHoy();
      if (!mounted) return;
      setState(() {
        _stock = stock;
      });
    } catch (_) {
      // El backend puede no responder; seguimos permitiendo el flujo
      // pero sin info de stock para validar localmente.
    }
  }

  int? get _stockDisponibleSeleccionado {
    final porPeso = _stock?.porPeso;
    if (porPeso == null) return _stock?.stockActual;
    return _pesoBalonKg == 45
        ? porPeso.stockActual45kg
        : porPeso.stockActual10kg;
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

    final disponible = _stockDisponibleSeleccionado;
    if (disponible != null && disponible <= 0) {
      setState(() {
        _message =
            'No tienes stock de balones de $_pesoBalonKg kg. Registra una entrada antes de crear el pedido.';
        _saved = false;
      });
      return;
    }
    if (disponible != null && cantidad > disponible) {
      setState(() {
        _message =
            'Solo tienes $disponible balon(es) de $_pesoBalonKg kg disponibles. Ajusta la cantidad o registra una entrada.';
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
          pesoBalonKg: _pesoBalonKg,
          precioUnitarioCentavos: precioCentavos,
          montoTotalCentavos: montoTotalCentavos,
          montoPendienteCentavos: _pagado ? 0 : montoTotalCentavos,
          metodoPago: _pagado ? _metodoPago : null,
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
            ClienteInfoCard(
              direccion: direccion,
              telefono: widget.cliente.telefono,
            ),
            const SizedBox(height: 20),
            NumberInputControl(
              controller: _cantidadController,
              label: 'Balones',
              icon: Icons.propane_tank_outlined,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            PesoBalonSelector(
              value: _pesoBalonKg,
              enabled: !_isSaving,
              onChanged: (value) => setState(() {
                _pesoBalonKg = value;
                if (_message != null) _message = null;
              }),
            ),
            const SizedBox(height: 10),
            _StockDisponibleHint(
              pesoKg: _pesoBalonKg,
              disponible: _stockDisponibleSeleccionado,
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
            CatalogSelector(
              label: 'Marca',
              value: _marcaBalon,
              options:
                  _marcas
                      .map(
                        (m) => CatalogOption(value: m.codigo, label: m.nombre),
                      )
                      .toList(),
              onChanged:
                  _isSaving
                      ? null
                      : (value) => setState(() {
                        _marcaBalon = value;
                      }),
            ),
            const SizedBox(height: 16),
            CatalogSelector(
              label: 'Tipo',
              value: _tipoBalon,
              options:
                  _tipos
                      .map(
                        (t) => CatalogOption(value: t.codigo, label: t.nombre),
                      )
                      .toList(),
              onChanged:
                  _isSaving
                      ? null
                      : (value) => setState(() {
                        _tipoBalon = value;
                      }),
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
            if (_pagado) ...[
              const SizedBox(height: 16),
              Text(
                'Como pago',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<MetodoPago>(
                segments: const [
                  ButtonSegment<MetodoPago>(
                    value: MetodoPago.efectivo,
                    label: Text('Efectivo'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                  ButtonSegment<MetodoPago>(
                    value: MetodoPago.yape,
                    label: Text('Yape'),
                    icon: Icon(Icons.phone_iphone),
                  ),
                ],
                selected: {_metodoPago},
                onSelectionChanged: _isSaving
                    ? null
                    : (selection) {
                        setState(() {
                          _metodoPago = selection.first;
                        });
                      },
                style: ButtonStyle(
                  minimumSize:
                      WidgetStateProperty.all(const Size.fromHeight(60)),
                  textStyle:
                      WidgetStateProperty.all(const TextStyle(fontSize: 20)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_message != null)
              MessageBox(
                message: _message!,
                type: _saved ? MessageBoxType.success : MessageBoxType.error,
              ),
            if (_message != null) const SizedBox(height: 16),
            ActionButton(
              label: _isSaving ? 'Guardando...' : 'Guardar pedido',
              icon: Icons.save,
              primary: true,
              onPressed: (_isSaving ||
                      (_stockDisponibleSeleccionado != null &&
                          _stockDisponibleSeleccionado! <= 0))
                  ? null
                  : _guardarPedido,
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

class _StockDisponibleHint extends StatelessWidget {
  const _StockDisponibleHint({required this.pesoKg, required this.disponible});

  final int pesoKg;
  final int? disponible;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (disponible == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Stock no verificado',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    final sinStock = disponible! <= 0;
    final bgColor = sinStock
        ? colors.errorContainer.withValues(alpha: 0.55)
        : colors.primaryContainer.withValues(alpha: 0.45);
    final borderColor = sinStock ? colors.error : colors.primary;
    final iconData =
        sinStock ? Icons.error_outline : Icons.check_circle_outline;
    final textColor = sinStock ? colors.error : colors.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(iconData, size: 24, color: borderColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              sinStock
                  ? 'Sin stock de $pesoKg kg. Registra una entrada antes de crear el pedido.'
                  : 'Stock disponible $pesoKg kg: $disponible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

