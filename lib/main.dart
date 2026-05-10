import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'features/clientes/cliente_service.dart';
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

    return MaterialApp(
      title: 'Pedidos de Gas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F7A4D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        clienteService: clienteService,
        pedidoService: pedidoService,
        reportesService: reportesService,
        stockService: stockService,
      ),
    );
  }
}
