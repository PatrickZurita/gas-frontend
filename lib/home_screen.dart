import 'package:flutter/material.dart';

import 'features/clientes/cliente_service.dart';
import 'features/clientes/screens/buscar_cliente_screen.dart';
import 'features/pedidos/pedido_service.dart';
import 'features/reportes/screens/pedidos_dia_screen.dart';
import 'features/reportes/services/reportes_service.dart';
import 'features/reportes/widgets/deudas_pendientes_section.dart';
import 'features/reportes/widgets/resumen_dia_section.dart';
import 'features/stock/services/stock_service.dart';
import 'features/stock/widgets/stock_hoy_section.dart';
import 'shared/action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.clienteService,
    required this.pedidoService,
    required this.reportesService,
    required this.stockService,
    super.key,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;
  final ReportesService reportesService;
  final StockService stockService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _refreshVersion = 0;

  Future<void> _refreshHome() async {
    setState(() {
      _refreshVersion++;
    });
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de gas')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Pedidos de gas',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Lo principal para trabajar hoy.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 18),
              ActionButton(
                label: 'Registrar pedido',
                icon: Icons.add_shopping_cart,
                primary: true,
                onPressed: () => _openBuscarCliente(context),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CompactHomeButton(
                      label: 'Buscar',
                      icon: Icons.search,
                      onPressed: () => _openBuscarCliente(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CompactHomeButton(
                      label: 'Pedidos',
                      icon: Icons.receipt_long,
                      onPressed: () => _openPedidos(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ResumenDiaSection(
                key: ValueKey('resumen-$_refreshVersion'),
                reportesService: widget.reportesService,
              ),
              const SizedBox(height: 16),
              StockHoySection(
                key: ValueKey('stock-$_refreshVersion'),
                stockService: widget.stockService,
              ),
              const SizedBox(height: 16),
              DeudasPendientesSection(
                key: ValueKey('deudas-$_refreshVersion'),
                reportesService: widget.reportesService,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBuscarCliente(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => BuscarClienteScreen(
              clienteService: widget.clienteService,
              pedidoService: widget.pedidoService,
              stockService: widget.stockService,
              onPedidoGuardado: _refreshHome,
            ),
      ),
    );
  }

  void _openPedidos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => PedidosDiaScreen(reportesService: widget.reportesService),
      ),
    );
  }
}

class _CompactHomeButton extends StatelessWidget {
  const _CompactHomeButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    );
  }
}
