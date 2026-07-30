import 'package:flutter/material.dart';

import 'core/network/api_exception.dart';
import 'features/clientes/cliente_service.dart';
import 'features/clientes/screens/buscar_cliente_screen.dart';
import 'features/clientes/screens/clientes_screen.dart';
import 'features/demanda_perdida/demanda_perdida_service.dart';
import 'features/demanda_perdida/widgets/demanda_perdida_sheet.dart';
import 'features/pedidos/pedido_service.dart';
import 'features/reportes/screens/pedidos_dia_screen.dart';
import 'features/reportes/screens/reportes_screen.dart';
import 'features/reportes/services/reportes_service.dart';
import 'features/reportes/widgets/deudas_pendientes_section.dart';
import 'features/reportes/widgets/resumen_dia_section.dart';
import 'features/stock/services/stock_service.dart';
import 'features/stock/widgets/stock_hoy_section.dart';
import 'shared/action_button.dart';
import 'shared/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.clienteService,
    required this.pedidoService,
    required this.reportesService,
    required this.stockService,
    required this.demandaPerdidaService,
    super.key,
  });

  final ClienteService clienteService;
  final PedidoService pedidoService;
  final ReportesService reportesService;
  final StockService stockService;
  final DemandaPerdidaService demandaPerdidaService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<StockHoySectionState> _stockSectionKey =
      GlobalKey<StockHoySectionState>();
  final GlobalKey<ResumenDiaSectionState> _resumenSectionKey =
      GlobalKey<ResumenDiaSectionState>();
  final GlobalKey<DeudasPendientesSectionState> _deudasSectionKey =
      GlobalKey<DeudasPendientesSectionState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshHome();
    }
  }

  Future<void> _refreshHome() async {
    final tasks = <Future<void>>[
      if (_stockSectionKey.currentState != null)
        _stockSectionKey.currentState!.refresh(),
      if (_resumenSectionKey.currentState != null)
        _resumenSectionKey.currentState!.refresh(),
      if (_deudasSectionKey.currentState != null)
        _deudasSectionKey.currentState!.refresh(),
    ];

    if (tasks.isEmpty) {
      return;
    }

    await Future.wait(tasks);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de gas')),
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          backgroundColor: colors.surface,
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const SectionTitle(
                title: 'Pedidos de gas',
                subtitle: 'Stock, pedidos y ventas de hoy.',
                large: true,
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
                      label: 'Clientes',
                      icon: Icons.people_alt_outlined,
                      onPressed: () => _openClientes(context),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _CompactHomeButton(
                      label: 'Reportes',
                      icon: Icons.insights_outlined,
                      onPressed: () => _openReportes(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _CompactHomeButton(
                      label: 'No atendido',
                      icon: Icons.phone_missed_outlined,
                      onPressed: _registrarNoAtendido,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              StockHoySection(
                key: _stockSectionKey,
                stockService: widget.stockService,
              ),
              const SizedBox(height: 16),
              ResumenDiaSection(
                key: _resumenSectionKey,
                reportesService: widget.reportesService,
                pedidoService: widget.pedidoService,
                onCambioPedido: _refreshHome,
              ),
              const SizedBox(height: 16),
              DeudasPendientesSection(
                key: _deudasSectionKey,
                reportesService: widget.reportesService,
                pedidoService: widget.pedidoService,
                onCambioPedido: _refreshHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registrarNoAtendido() async {
    final request = await showDemandaPerdidaSheet(context);
    if (request == null || !mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.demandaPerdidaService.registrarDemandaPerdida(request);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Llamada no atendida guardada.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar. Intenta otra vez.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openBuscarCliente(BuildContext context) async {
    await Navigator.of(context).push(
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
    if (!mounted) {
      return;
    }
    await _refreshHome();
  }

  Future<void> _openClientes(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClientesScreen(
          clienteService: widget.clienteService,
          pedidoService: widget.pedidoService,
          stockService: widget.stockService,
          onPedidoGuardado: _refreshHome,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshHome();
  }

  Future<void> _openPedidos(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PedidosDiaScreen(
          reportesService: widget.reportesService,
          pedidoService: widget.pedidoService,
          onCambioPedido: _refreshHome,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshHome();
  }

  Future<void> _openReportes(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportesScreen(
          reportesService: widget.reportesService,
          pedidoService: widget.pedidoService,
          onCambioPedido: _refreshHome,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _refreshHome();
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
      label: Text(label, style: Theme.of(context).textTheme.titleMedium),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    );
  }
}
