import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/catalog_selector.dart';
import '../../../shared/message_box.dart';
import '../../../shared/number_input_control.dart';
import '../../../shared/peso_balon_selector.dart';
import '../models/pedido.dart';
import '../models/pedido_update_request.dart';
import '../pedido_service.dart';

class EditarPedidoScreen extends StatefulWidget {
  const EditarPedidoScreen({
    required this.pedido,
    required this.pedidoService,
    this.onPedidoActualizado,
    super.key,
  });

  final Pedido pedido;
  final PedidoService pedidoService;
  final Future<void> Function()? onPedidoActualizado;

  @override
  State<EditarPedidoScreen> createState() => _EditarPedidoScreenState();
}

class _EditarPedidoScreenState extends State<EditarPedidoScreen> {
  late final TextEditingController _cantidadController;
  late final TextEditingController _precioController;
  late final TextEditingController _motivoController;

  late bool _pagado;
  late String _marcaBalon;
  late String _tipoBalon;
  late int _pesoBalonKg;

  bool _isSaving = false;
  String? _message;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pedido;
    _cantidadController = TextEditingController(text: '${p.cantidadBalones}');
    final precio = p.precioUnitarioCentavos;
    _precioController = TextEditingController(
      text: precio != null ? _formatCentavos(precio) : '',
    );
    _motivoController = TextEditingController();
    _pagado = p.pagado;
    _marcaBalon = p.marcaBalon;
    _tipoBalon = p.tipoBalon;
    _pesoBalonKg = p.pesoBalonKg;
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _precioController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_isSaving) return;

    final cantidad = int.tryParse(_cantidadController.text.trim());
    if (cantidad == null || cantidad <= 0) {
      setState(() {
        _message = 'La cantidad debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

    final precioCentavos = _parseSolesToCentavos(_precioController.text);
    if (precioCentavos == null || precioCentavos <= 0) {
      setState(() {
        _message = 'El precio debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

    final motivo = _motivoController.text.trim();
    final montoTotalCentavos = cantidad * precioCentavos;
    final montoPendienteCentavos = _pagado ? 0 : montoTotalCentavos;

    setState(() {
      _isSaving = true;
      _message = null;
      _saved = false;
    });

    try {
      await widget.pedidoService.editarPedido(
        widget.pedido.id,
        PedidoUpdateRequest(
          cantidadBalones: cantidad,
          pagado: _pagado,
          marcaBalon: _marcaBalon,
          tipoBalon: _tipoBalon,
          pesoBalonKg: _pesoBalonKg,
          precioUnitarioCentavos: precioCentavos,
          montoTotalCentavos: montoTotalCentavos,
          montoPendienteCentavos: montoPendienteCentavos,
          motivoEdicion: motivo.isEmpty ? null : motivo,
        ),
      );
      if (!mounted) return;
      await widget.onPedidoActualizado?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido actualizado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } on PedidoConflictoException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saved = false;
        _message = error.message;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saved = false;
        _message = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saved = false;
        _message = 'No se pudo actualizar el pedido.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar pedido')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Editar pedido',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
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
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _precioController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Precio por balon',
                hintText: '55',
                helperText: 'No escribas el total',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            CatalogSelector(
              label: 'Marca',
              value: _marcaBalon,
              options: const [
                CatalogOption(value: 'PETROPERU', label: 'Petroperu'),
                CatalogOption(value: 'SOLGAS', label: 'Solgas'),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() {
                        _marcaBalon = value;
                      }),
            ),
            const SizedBox(height: 16),
            CatalogSelector(
              label: 'Tipo',
              value: _tipoBalon,
              options: const [
                CatalogOption(value: 'NORMAL', label: 'Normal'),
                CatalogOption(value: 'PREMIUM', label: 'Premium'),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() {
                        _tipoBalon = value;
                      }),
            ),
            const SizedBox(height: 20),
            Text(
              'Pagado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) {
                      setState(() {
                        _pagado = selection.first;
                      });
                    },
              style: ButtonStyle(
                minimumSize:
                    WidgetStateProperty.all(const Size.fromHeight(60)),
                textStyle:
                    WidgetStateProperty.all(const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motivoController,
              maxLines: 2,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Motivo de la edicion (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),
            if (_message != null) ...[
              MessageBox(
                message: _message!,
                type: _saved ? MessageBoxType.success : MessageBoxType.error,
              ),
              const SizedBox(height: 16),
            ],
            ActionButton(
              label: _isSaving ? 'Guardando...' : 'Guardar cambios',
              icon: Icons.save,
              primary: true,
              onPressed: _isSaving ? null : _guardar,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCentavos(int centavos) {
    final soles = centavos ~/ 100;
    final cents = (centavos % 100).toString().padLeft(2, '0');
    return cents == '00' ? '$soles' : '$soles.$cents';
  }

  int? _parseSolesToCentavos(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;

    final parts = normalized.split('.');
    if (parts.length > 2 || parts.first.isEmpty) return null;

    final soles = int.tryParse(parts[0]);
    if (soles == null || soles < 0) return null;

    var cents = 0;
    if (parts.length == 2) {
      final centsText = parts[1];
      if (centsText.isEmpty || centsText.length > 2) return null;
      cents = int.tryParse(centsText.padRight(2, '0')) ?? -1;
      if (cents < 0) return null;
    }

    return soles * 100 + cents;
  }
}
