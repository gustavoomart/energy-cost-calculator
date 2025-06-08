import 'package:flutter/material.dart';

class TimeEntry extends StatefulWidget {
  final Duration? initialDuration;
  final bool? initialIsFullDay;
  final Function(Duration duration)? onTimeChanged;
  
  const TimeEntry({
    super.key,
    this.initialDuration,
    this.initialIsFullDay,
    this.onTimeChanged,
  });

  @override
  State<TimeEntry> createState() => _TimeEntryState();
}

class _TimeEntryState extends State<TimeEntry> {
  late Duration selectedDuration;
  late bool isFullDay;

  @override
  void initState() {
    super.initState();
    selectedDuration = widget.initialDuration ?? Duration(hours: 0, minutes: 0);
    isFullDay = widget.initialIsFullDay ?? false;
  }

  Future<void> _selectDuration(BuildContext context) async {
    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tempo de uso diario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Selecionar horário específico'),
                onTap: () async {
                  Navigator.pop(context);
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: selectedDuration.inHours,
                      minute: selectedDuration.inMinutes.remainder(60),
                    ),
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  
                  if (picked != null) {
                    final newDuration = Duration(hours: picked.hour, minutes: picked.minute);
                    setState(() {
                      selectedDuration = newDuration;
                      isFullDay = false;
                    });
                    widget.onTimeChanged?.call(newDuration);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.all_inclusive),
                title: Text('Dia inteiro (24 horas)'),
                onTap: () {
                  Navigator.pop(context);
                  final newDuration = Duration(hours: 24, minutes: 0);
                  setState(() {
                    selectedDuration = newDuration;
                    isFullDay = true;
                  });
                  widget.onTimeChanged?.call(newDuration);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration() {
    if (isFullDay) {
      return '24:00';
    }
    return '${selectedDuration.inHours.toString().padLeft(2, '0')}:${selectedDuration.inMinutes.remainder(60).toString().padLeft(2, '0')}h';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 64,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDuration(context),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isFullDay 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.outline
                )
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDuration(),
                      style: TextStyle(
                        color: isFullDay 
                          ? Theme.of(context).colorScheme.primary 
                          : null,
                        fontWeight: isFullDay ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}