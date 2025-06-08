import 'package:flutter/material.dart';

class EnergyCost {
  TextEditingController nameCtrl;
  TextEditingController wattsCtrl;
  TextEditingController amountCtrl;
  int selectedMinutes;

  String get duration {
    final hours = selectedMinutes ~/ 60;
    final minutes = selectedMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
  double? totalCost(double kWh) {
    int? amount = int.tryParse(amountCtrl.text);
    int? power = int.tryParse(wattsCtrl.text);
    if (amount ==  null || power == null || amount == 0 || power == 0 || selectedMinutes == 0) return null;
    return (amount * (((power * selectedMinutes)/60) * (kWh/1000)));
  }

  EnergyCost({
    String initialName = '',
    String initialkWh = '',
    String initialAmount = '1',
  })  : nameCtrl = TextEditingController(text: initialName),
        wattsCtrl = TextEditingController(text: initialkWh),
        amountCtrl = TextEditingController(text: initialAmount),
        selectedMinutes = 0;

  String toCsvRow() {
    return '"${amountCtrl.text}","${nameCtrl.text}","${wattsCtrl.text}","$duration"';
  }

  factory EnergyCost.fromCsvRow(String csvLine) {
    try {
      final values = csvLine.split(';');
      if (values.length < 4) throw FormatException("Linha CSV incompleta: $csvLine");

      final amount = values[0].trim();
      final name = values[1].trim();
      final watts = values[2].trim();
      final durationParts = values[3].trim().split(':');
      if (durationParts.length != 2) throw FormatException("Duração inválida");

      final minutes =
          int.parse(durationParts[0]) * 60 + int.parse(durationParts[1]);

      final energyCost = EnergyCost(
        initialAmount: amount,
        initialName: name,
        initialkWh: watts,
      );
      energyCost.selectedMinutes = minutes;
      return energyCost;
    } catch (e) {
      debugPrint('Erro ao processar linha CSV: $e');
      return EnergyCost();
    }
  }
}
