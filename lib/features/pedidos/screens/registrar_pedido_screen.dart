import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../clientes/models/cliente.dart';
import '../models/pedido_create_request.dart';
import '../pedido_service.dart';

class RegistrarPedidoScreen extends StatefulWidget {
  const RegistrarPedidoScreen({
    required this.cliente,
    required this.pedidoService,
    super.key,
  });

  final Cliente cliente;
  final PedidoService pedidoService;

  @override
  State<RegistrarPedidoScreen> createState() => _RegistrarPedidoScreenState();
}

class _RegistrarPedidoScreenState extends State<RegistrarPedidoScreen> {
  final TextEditingController _cantidadController = TextEditingController(
    text: '1',
  );
  final TextEditingController _totalController = TextEditingController();

  bool _pagado = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _message;

  @override
  void dispose() {
    _cantidadController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _guardarPedido() async {
    final cantidad = int.tryParse(_cantidadController.text.trim());
    final total = double.tryParse(
      _totalController.text.trim().replaceAll(',', '.'),
    );

    if (cantidad == null || cantidad <= 0) {
      setState(() {
        _message = 'La cantidad debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

    if (total == null || total <= 0) {
      setState(() {
        _message = 'El total debe ser mayor a 0.';
        _saved = false;
      });
      return;
    }

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
          totalSoles: total,
          pagado: _pagado,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _saved = true;
        _message =
            _pagado
                ? 'Pedido guardado como pagado.'
                : 'Pedido guardado como no pagado.';
      });
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
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Cantidad de balones',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.propane_tank_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Total soles',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              onSubmitted: (_) => _guardarPedido(),
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
