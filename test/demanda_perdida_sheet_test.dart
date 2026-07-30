import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gas_frontend/features/demanda_perdida/models/demanda_perdida_create_request.dart';
import 'package:gas_frontend/features/demanda_perdida/widgets/demanda_perdida_sheet.dart';

void main() {
  Future<void> pumpSheetHost(
    WidgetTester tester,
    void Function(DemandaPerdidaCreateRequest?) onResult,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      onResult(await showDemandaPerdidaSheet(context));
                    },
                    child: const Text('abrir'),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('choosing a motivo closes sheet with minimal request', (
    WidgetTester tester,
  ) async {
    DemandaPerdidaCreateRequest? result;
    await pumpSheetHost(tester, (value) => result = value);

    expect(find.text('Llamada no atendida'), findsOneWidget);
    expect(find.text('Sin stock'), findsOneWidget);
    expect(find.text('Fuera de zona'), findsOneWidget);
    expect(find.text('Saturado'), findsOneWidget);
    expect(find.text('Otro'), findsOneWidget);

    await tester.tap(find.text('Saturado'));
    await tester.pumpAndSettle();

    expect(find.byType(DemandaPerdidaSheet), findsNothing);
    expect(result, isNotNull);
    expect(result!.motivo, DemandaPerdidaMotivo.saturado);
    expect(result!.toJson(), {'motivo': 'SATURADO'});
  });

  testWidgets('touched optionals are included with the motivo', (
    WidgetTester tester,
  ) async {
    DemandaPerdidaCreateRequest? result;
    await pumpSheetHost(tester, (value) => result = value);

    await tester.tap(find.text('45 kg'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Zona (opcional)'),
      ' Musa Alta ',
    );
    await tester.tap(find.text('Fuera de zona'));
    await tester.pumpAndSettle();

    expect(result!.toJson(), {
      'motivo': 'FUERA_DE_ZONA',
      'cantidad_balones': 3,
      'peso_balon_kg': 45,
      'zona_texto': 'Musa Alta',
    });
  });

  testWidgets('dismissing the sheet returns null and sends nothing', (
    WidgetTester tester,
  ) async {
    var called = false;
    DemandaPerdidaCreateRequest? result;
    await pumpSheetHost(tester, (value) {
      called = true;
      result = value;
    });

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(DemandaPerdidaSheet), findsNothing);
    expect(called, isTrue);
    expect(result, isNull);
  });

  testWidgets('cantidad stepper respects the minimum of 1', (
    WidgetTester tester,
  ) async {
    DemandaPerdidaCreateRequest? result;
    await pumpSheetHost(tester, (value) => result = value);

    final removeButton = find.byIcon(Icons.remove);
    expect(
      tester.widget<OutlinedButton>(
        find.ancestor(
          of: removeButton,
          matching: find.byType(OutlinedButton),
        ),
      ).onPressed,
      isNull,
    );

    await tester.tap(find.text('Otro'));
    await tester.pumpAndSettle();

    expect(result!.cantidadBalones, isNull);
  });
}
