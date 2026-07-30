import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/action_button.dart';
import '../../../shared/canal_captacion_selector.dart';
import '../../../shared/message_box.dart';
import '../cliente_service.dart';
import '../models/cliente_create_request.dart';

class CrearClienteScreen extends StatefulWidget {
  const CrearClienteScreen({required this.clienteService, super.key});

  final ClienteService clienteService;

  @override
  State<CrearClienteScreen> createState() => _CrearClienteScreenState();
}

class _CrearClienteScreenState extends State<CrearClienteScreen> {
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isSaving = false;
  String? _message;
  bool _isSuccess = false;
  String? _canalCaptacion;

  @override
  void dispose() {
    _aliasController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCliente() async {
    final alias = _aliasController.text.trim();
    final telefono = _telefonoController.text.trim();

    if (alias.length < 3) {
      setState(() {
        _message = 'Escribe una direccion de al menos 3 caracteres.';
        _isSuccess = false;
      });
      return;
    }

    if (telefono.length < 6) {
      setState(() {
        _message = 'Escribe un telefono de al menos 6 digitos.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
      _isSuccess = false;
    });

    try {
      final cliente = await widget.clienteService.crearCliente(
        ClienteCreateRequest(
          alias: alias,
          telefono: telefono,
          canalCaptacion: _canalCaptacion,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'Cliente guardado.';
        _isSuccess = true;
      });
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop(cliente);
      }
    } on ClienteDuplicadoException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message;
        _isSuccess = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message;
        _isSuccess = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = 'No se pudo guardar. Intenta otra vez.';
        _isSuccess = false;
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
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cliente')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Nuevo cliente',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aliasController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Direccion / Alias',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Telefono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              onSubmitted: (_) => _guardarCliente(),
            ),
            const SizedBox(height: 16),
            CanalCaptacionSelector(
              value: _canalCaptacion,
              enabled: !_isSaving,
              onChanged: (canal) {
                setState(() {
                  _canalCaptacion = canal;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_message != null)
              MessageBox(
                message: _message!,
                type:
                    _isSuccess ? MessageBoxType.success : MessageBoxType.error,
              ),
            if (_message != null) const SizedBox(height: 16),
            ActionButton(
              label: _isSaving ? 'Guardando...' : 'Guardar cliente',
              icon: Icons.save,
              primary: true,
              onPressed: _isSaving ? null : _guardarCliente,
            ),
          ],
        ),
      ),
    );
  }
}
