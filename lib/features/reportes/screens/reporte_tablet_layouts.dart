import 'package:flutter/material.dart';

import '../../../shared/data_chip.dart';
import '../../../shared/metric_card.dart';
import '../../../shared/summary_card.dart';
import '../models/reporte_dia_breve.dart';
import '../models/reporte_mensual.dart';
import '../models/reporte_semanal.dart';
import '../money_format.dart';

class DiaBreveTile extends StatelessWidget {
  const DiaBreveTile({
    required this.dia,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final ReporteDiaBreve dia;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final tile = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: selected ? colors.primaryContainer.withValues(alpha: 0.4) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _fechaCorta(dia.fecha),
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                formatSolesFromCentavos(dia.montoTotalCentavos),
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (dia.balonesVendidos10kg > 0)
                DataChip(
                  label: '10 kg',
                  value: '${dia.balonesVendidos10kg}',
                ),
              if (dia.balonesVendidos45kg > 0)
                DataChip(
                  label: '45 kg',
                  value: '${dia.balonesVendidos45kg}',
                ),
              DataChip(label: 'Pedidos', value: '${dia.pedidosCount}'),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) return tile;
    return InkWell(onTap: onTap, child: tile);
  }

  String _fechaCorta(DateTime date) {
    const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${weekdays[date.weekday - 1]} $day/$month';
  }
}

class TabletSemanalLayout extends StatefulWidget {
  const TabletSemanalLayout({
    required this.reporte,
    required this.header,
    this.onAbrirDia,
    super.key,
  });

  final ReporteSemanal reporte;
  final Widget header;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  State<TabletSemanalLayout> createState() => _TabletSemanalLayoutState();
}

class _TabletSemanalLayoutState extends State<TabletSemanalLayout> {
  ReporteDiaBreve? _seleccionado;

  @override
  void initState() {
    super.initState();
    if (widget.reporte.dias.isNotEmpty) {
      _seleccionado = widget.reporte.dias.first;
    }
  }

  @override
  void didUpdateWidget(covariant TabletSemanalLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dias = widget.reporte.dias;
    if (dias.isEmpty) {
      _seleccionado = null;
    } else if (_seleccionado == null ||
        !dias.any((d) => d.fecha == _seleccionado!.fecha)) {
      _seleccionado = dias.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.header,
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _DiasListaTablet(
                    dias: widget.reporte.dias,
                    seleccionado: _seleccionado,
                    onSelect: (dia) {
                      setState(() {
                        _seleccionado = dia;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 7,
                  child: _DetalleTablet(
                    reporte: widget.reporte,
                    dia: _seleccionado,
                    onAbrirDia: widget.onAbrirDia,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabletMensualLayout extends StatefulWidget {
  const TabletMensualLayout({
    required this.reporte,
    required this.header,
    this.onAbrirDia,
    super.key,
  });

  final ReporteMensual reporte;
  final Widget header;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  State<TabletMensualLayout> createState() => _TabletMensualLayoutState();
}

class _TabletMensualLayoutState extends State<TabletMensualLayout> {
  ReporteDiaBreve? _seleccionado;

  @override
  void initState() {
    super.initState();
    if (widget.reporte.dias.isNotEmpty) {
      _seleccionado = widget.reporte.dias.first;
    }
  }

  @override
  void didUpdateWidget(covariant TabletMensualLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    final dias = widget.reporte.dias;
    if (dias.isEmpty) {
      _seleccionado = null;
    } else if (_seleccionado == null ||
        !dias.any((d) => d.fecha == _seleccionado!.fecha)) {
      _seleccionado = dias.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.header,
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _DiasListaTablet(
                    dias: widget.reporte.dias,
                    seleccionado: _seleccionado,
                    onSelect: (dia) {
                      setState(() {
                        _seleccionado = dia;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 7,
                  child: _DetalleMensualTablet(
                    reporte: widget.reporte,
                    dia: _seleccionado,
                    onAbrirDia: widget.onAbrirDia,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiasListaTablet extends StatelessWidget {
  const _DiasListaTablet({
    required this.dias,
    required this.seleccionado,
    required this.onSelect,
  });

  final List<ReporteDiaBreve> dias;
  final ReporteDiaBreve? seleccionado;
  final ValueChanged<ReporteDiaBreve> onSelect;

  @override
  Widget build(BuildContext context) {
    if (dias.isEmpty) {
      return SummaryCard(
        child: Text(
          'Sin ventas en este rango.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    return SummaryCard(
      padding: EdgeInsets.zero,
      borderRadius: 8,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: dias.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        itemBuilder: (context, index) {
          final dia = dias[index];
          final esActivo =
              seleccionado != null && seleccionado!.fecha == dia.fecha;
          return DiaBreveTile(
            dia: dia,
            selected: esActivo,
            onTap: () => onSelect(dia),
          );
        },
      ),
    );
  }
}

class _DetalleTablet extends StatelessWidget {
  const _DetalleTablet({
    required this.reporte,
    required this.dia,
    this.onAbrirDia,
  });

  final ReporteSemanal reporte;
  final ReporteDiaBreve? dia;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resumen de la semana',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              MetricCard(
                label: 'Total vendido',
                value: formatSolesFromCentavos(reporte.montoTotalCentavos),
                primary: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Cobrado',
                      value: formatSolesFromCentavos(
                          reporte.montoCobradoCentavos),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      label: 'Pendiente',
                      value: formatSolesFromCentavos(
                          reporte.montoPendienteCentavos),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Balones 10 kg',
                      value: '${reporte.balonesVendidos10kg}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      label: 'Balones 45 kg',
                      value: '${reporte.balonesVendidos45kg}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (dia != null) _DetalleDia(dia: dia!, onAbrirDia: onAbrirDia),
      ],
    );
  }
}

class _DetalleMensualTablet extends StatelessWidget {
  const _DetalleMensualTablet({
    required this.reporte,
    required this.dia,
    this.onAbrirDia,
  });

  final ReporteMensual reporte;
  final ReporteDiaBreve? dia;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SummaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resumen del mes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              MetricCard(
                label: 'Total vendido',
                value: formatSolesFromCentavos(reporte.montoTotalCentavos),
                primary: true,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Cobrado',
                      value: formatSolesFromCentavos(
                          reporte.montoCobradoCentavos),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      label: 'Pendiente',
                      value: formatSolesFromCentavos(
                          reporte.montoPendienteCentavos),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Balones 10 kg',
                      value: '${reporte.balonesVendidos10kg}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      label: 'Balones 45 kg',
                      value: '${reporte.balonesVendidos45kg}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (dia != null) _DetalleDia(dia: dia!, onAbrirDia: onAbrirDia),
      ],
    );
  }
}

class _DetalleDia extends StatelessWidget {
  const _DetalleDia({required this.dia, this.onAbrirDia});

  final ReporteDiaBreve dia;
  final void Function(DateTime fecha)? onAbrirDia;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final puedeAbrir = onAbrirDia != null && dia.pedidosCount > 0;
    return SummaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _fechaLarga(dia.fecha),
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Total del dia',
            value: formatSolesFromCentavos(dia.montoTotalCentavos),
            primary: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Cobrado',
                  value: formatSolesFromCentavos(dia.montoCobradoCentavos),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Pendiente',
                  value: formatSolesFromCentavos(dia.montoPendienteCentavos),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Balones 10 kg',
                  value: '${dia.balonesVendidos10kg}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Balones 45 kg',
                  value: '${dia.balonesVendidos45kg}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DataChip(label: 'Pedidos', value: '${dia.pedidosCount}'),
              DataChip(label: 'Balones', value: '${dia.balonesVendidos}'),
            ],
          ),
          if (puedeAbrir) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onAbrirDia!(dia.fecha),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Ver pedidos de este dia'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 17),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fechaLarga(DateTime date) {
    const weekdays = [
      'Lunes',
      'Martes',
      'Miercoles',
      'Jueves',
      'Viernes',
      'Sabado',
      'Domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} de ${months[date.month - 1]}';
  }
}
