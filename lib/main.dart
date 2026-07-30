import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'features/clientes/cliente_service.dart';
import 'features/demanda_perdida/demanda_perdida_service.dart';
import 'features/pedidos/pedido_service.dart';
import 'features/reportes/services/reportes_service.dart';
import 'features/stock/services/stock_service.dart';
import 'home_screen.dart';

void main() {
  runApp(const GasApp());
}

class GasApp extends StatelessWidget {
  const GasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();
    final clienteService = ApiClienteService(apiClient);
    final pedidoService = ApiPedidoService(apiClient);
    final reportesService = ApiReportesService(apiClient);
    final stockService = ApiStockService(apiClient);
    final demandaPerdidaService = ApiDemandaPerdidaService(apiClient);

    return MaterialApp(
      title: 'Pedidos de Gas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeScreen(
        clienteService: clienteService,
        pedidoService: pedidoService,
        reportesService: reportesService,
        stockService: stockService,
        demandaPerdidaService: demandaPerdidaService,
      ),
    );
  }
}
