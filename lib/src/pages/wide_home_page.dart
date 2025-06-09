

import 'package:energy_cost/src/ViewModel/energy_cost_vm.dart';
import 'package:energy_cost/src/widgets/time_entry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WideHomePage extends StatefulWidget {
  const WideHomePage({super.key});

  @override
  State<WideHomePage> createState() => _WideHomePageState();
}

class _WideHomePageState extends State<WideHomePage> {
  final EnergyCostViewModel model = EnergyCostViewModel();

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: SizedBox(
              width: 600,
              child: Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: model.share,
                                  tooltip: 'Share',
                                  icon: Icon(Icons.share),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: model.save,
                                  tooltip: 'Save',
                                  icon: Icon(Icons.save),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: model.load,
                                  tooltip: 'Load',
                                  icon: Icon(Icons.folder_open),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              'Items',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              tooltip: 'Add item',
                              onPressed: model.addItem,
                              icon: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: model,
                      builder: (context, _) {
                        return ListView.builder(
                          itemCount: model.items.length,
                          itemBuilder: (ctx, i) => _itemTile(i),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 32, indent: 8, endIndent: 8),

                  AnimatedBuilder(
                    animation: model,
                    builder: (context, _) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                          bottom: 8,
                          right: 8,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 101,
                              child: TextField(
                                controller: model.kWhCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Valor kWh',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'\d+(\.\d*)?'),
                                  ),
                                ],
                                onChanged: (_) => model.updateKWh(),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    'Day: ${model.currencySymbol} ${model.totalDayCost.toStringAsFixed(2)}',
                                  ),
                                  Spacer(),
                                  Text(
                                    'Month: ${model.currencySymbol} ${model.totalMonthCost.toStringAsFixed(2)}',
                                  ),
                                  Spacer(),
                                  Text(
                                    'Year: ${model.currencySymbol} ${model.totalYearCost.toStringAsFixed(2)}',
                                  ),
                                  Spacer(),
                                  Text(
                                    'Power: ${model.totalPower.toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemTile(int index) {
    final item = model.items[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    controller: item.amountCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      isDense: true,

                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[1-9]\d*$')),
                    ],
                    onChanged: (_) => model.updateItem(index),
                  ),
                ),
                SizedBox(width: 8),

                Flexible(
                  flex: 8,
                  child: TextField(
                    controller: item.nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                Flexible(
                  flex: 5,
                  child: TextField(
                    controller: item.wattsCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Power (W)',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d+(\.\d*)?')),
                    ],
                    onChanged: (_) => model.updateItem(index),
                  ),
                ),
                SizedBox(width: 8),

                TimeEntry(
                  initialDuration: Duration(minutes: item.selectedMinutes),
                  onTimeChanged: (duration) =>
                      model.updateItem(index, minutes: duration.inMinutes),
                ),

                SizedBox(width: 8),

                Builder(
                  builder: (context) {
                    

                    double? itemCost = model.items[index].totalCost(model.kWh);
                    String cost = itemCost != null
                        ? '${model.currencySymbol} ${itemCost.toStringAsFixed(2)}'
                        : '${model.currencySymbol} 0.00';
                    return SizedBox(
                      width: 62,
                      child: Center(child: Text(cost)),
                    );
                  },
                ),

                SizedBox(width: 8),

                IconButton(
                  tooltip: 'Delete item',
                  onPressed: () => model.removeItem(index),
                  icon: Icon(Icons.delete),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
