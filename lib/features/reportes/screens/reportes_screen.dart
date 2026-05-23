import 'package:flutter/material.dart';

import '../../../shared/action_button.dart';
import '../../pedidos/pedido_service.dart';
import '../services/reportes_service.dart';
import 'historial_fecha_screen.dart';
import 'reporte_mensual_screen.dart';
import 'reporte_semanal_screen.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({
    required this.reportesService,
    required this.pedidoService,
    this.onCambioPedido,
    super.key,
  });

  final ReportesService reportesService;
  final PedidoService pedidoService;
  final Future<void> Function()? onCambioPedido;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Reportes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Consulta ventas por dia, semana o mes.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ActionButton(
              label: 'Historial por fecha',
              icon: Icons.calendar_today_outlined,
              primary: true,
              onPressed: () => _abrirHistorial(context),
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Reporte semanal',
              icon: Icons.calendar_view_week_outlined,
              onPressed: () => _abrirSemanal(context),
            ),
            const SizedBox(height: 12),
            ActionButton(
              label: 'Reporte mensual',
              icon: Icons.calendar_month_outlined,
              onPressed: () => _abrirMensual(context),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirHistorial(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistorialFechaScreen(
          reportesService: reportesService,
          pedidoService: pedidoService,
          onCambioPedido: onCambioPedido,
        ),
      ),
    );
  }

  void _abrirSemanal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReporteSemanalScreen(reportesService: reportesService),
      ),
    );
  }

  void _abrirMensual(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReporteMensualScreen(reportesService: reportesService),
      ),
    );
  }
}
