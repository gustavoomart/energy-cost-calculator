import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, PlatformDispatcher;
import 'package:energy_cost/src/data/energy_cost.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

class EnergyCostViewModel extends ChangeNotifier {
  final List<EnergyCost> items = [];
  final TextEditingController kWhCtrl = TextEditingController();

  final locale = PlatformDispatcher.instance.locale;
  late final currencyFormat = NumberFormat.simpleCurrency(locale: locale.toString());


  double get kWh => double.tryParse(kWhCtrl.text) ?? 0;

  double get totalDayCost {
    double total = 0;

    for (final item in items) {
      double? cost = item.totalCost(kWh);
      total += cost ?? 0;
    }
    return total;
  }

  double get totalMonthCost =>
      totalDayCost *
      DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  double get totalYearCost {
    final currentYear = DateTime.now().year;
    final isLeapYear =
        (currentYear % 4 == 0 && currentYear % 100 != 0) ||
        (currentYear % 400 == 0);
    final daysInCurrentYear = isLeapYear ? 366 : 365;
    return daysInCurrentYear * totalDayCost;
  }

  double get totalPower {
    double totalPower = 0;

    for (final item in items) {
      final amount = int.tryParse(item.amountCtrl.text) ?? 1;
      final watts = double.tryParse(item.wattsCtrl.text) ?? 0;
      final minutes = item.selectedMinutes;

      if (watts > 0 && minutes > 0) {
        totalPower += watts * amount;
      }
    }
    return totalPower;
  }

  void addItem() {
    items.add(EnergyCost());
    notifyListeners();
  }

  void removeItem(int index) {
    items[index].nameCtrl.dispose();
    items[index].wattsCtrl.dispose();
    items.removeAt(index);
    notifyListeners();
  }

  void updateItem(int index, {int? minutes}) {
    if (minutes != null) items[index].selectedMinutes = minutes;
    notifyListeners();
  }

  void updateKWh() => notifyListeners();

  Future<void> share() async {
    final pdf = pw.Document();

    final validItems = items.where((e) {
      final amount = e.amountCtrl.text.trim();
      final watts = e.wattsCtrl.text.trim();
      final duration = e.duration;
      return amount.isNotEmpty && watts.isNotEmpty && duration != '00:00';
    }).toList();

    final tableData = validItems.map((e) {
      final amount = e.amountCtrl.text.trim();
      final name = e.nameCtrl.text.trim().isEmpty
          ? 'Unnamed'
          : e.nameCtrl.text.trim();
      final watts = e.wattsCtrl.text.trim();
      final duration = e.duration;
      return [amount, name, watts, duration];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text(
            'Energy Consumption Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['Amount (und)', 'Name', 'Power (W)', 'Daily usage (h)'],
            data: tableData,
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total Power: ${totalPower.toStringAsFixed(2)} W'),
          pw.Text('Total Cost per Day: \$${totalDayCost.toStringAsFixed(2)}'),
          pw.Text(
            'Total Cost per Month: \$${totalMonthCost.toStringAsFixed(2)}',
          ),
          pw.Text('Total Cost per Year: \$${totalYearCost.toStringAsFixed(2)}'),
        ],
      ),
    );

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      await Printing.sharePdf(bytes: pdfBytes, filename: 'energy_costs.pdf');
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/energy_costs.pdf');
      await file.writeAsBytes(pdfBytes);

      ShareParams params = ShareParams(
        files: [XFile(file.path)],
        subject: 'Custos de Energia',
        text: 'Relatório de custos de energia',
      );

      await SharePlus.instance.share(params);
    }
  }

  Future<void> save() async {
    final buffer = StringBuffer();
    buffer.writeln('Amount;Name;Power (W);Duration (h)');

    for (final item in items) {
      buffer.writeln(
        '${item.amountCtrl.text};${item.nameCtrl.text};${item.wattsCtrl.text};${item.duration}',
      );
    }

    final bom = [0xEF, 0xBB, 0xBF];
    final csvBytes = Uint8List.fromList([
      ...bom,
      ...utf8.encode(buffer.toString()),
    ]);

    await FileSaver.instance.saveFile(
      name: 'energy_costs',
      bytes: csvBytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  Future<void> load() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null) {
      return;
    }

    final fileBytes = result.files.first.bytes!;
    final content = utf8.decode(fileBytes);
    final lines = LineSplitter.split(content).toList();

    items.clear();

    for (int i = 1; i < lines.length; i++) {
      final item = EnergyCost.fromCsvRow(lines[i]);
      items.add(item);
    }
    notifyListeners();
  }
}
