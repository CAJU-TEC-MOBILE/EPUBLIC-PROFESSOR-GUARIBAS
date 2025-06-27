// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:professor_acesso_notifiq/constants/app_tema.dart';

class CustomCalendarioButton extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  List<String>? semanas;
  final String? inicioPeriodoEtapa;
  final String? fimPeriodoEtapa;
  final DateTime? onDataSelected;
  final void Function(DateTime selectedDate)? onDateSelected;
  final String? label;

  CustomCalendarioButton({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.semanas,
    this.inicioPeriodoEtapa,
    this.fimPeriodoEtapa,
    this.onDataSelected,
    this.onDateSelected,
    this.label,
  });

  @override
  _CustomCalendarioButtonState createState() => _CustomCalendarioButtonState();
}

class _CustomCalendarioButtonState extends State<CustomCalendarioButton> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.onDataSelected ?? widget.initialDate;
  }

  DateTime _getFirstDate() {
    if (widget.inicioPeriodoEtapa != null) {
      final DateTime? parsedDate =
          DateTime.tryParse(widget.inicioPeriodoEtapa!);
      if (parsedDate != null) {
        return parsedDate.isAfter(widget.firstDate)
            ? parsedDate
            : widget.firstDate;
      }
    }
    return widget.firstDate;
  }

  DateTime _getLastDate() {
    if (widget.fimPeriodoEtapa != null) {
      final DateTime? parsedDate = DateTime.tryParse(widget.fimPeriodoEtapa!);
      if (parsedDate != null) {
        return parsedDate.isBefore(widget.lastDate)
            ? parsedDate
            : widget.lastDate;
      }
    }
    return widget.lastDate;
  }

  DateTime _getValidInitialDate(
      DateTime initialDate, List<String> diasHabilitados) {
    final Map<String, int> diaMap = {
      'Domingo': DateTime.sunday,
      'Segunda': DateTime.monday,
      'Terça': DateTime.tuesday,
      'Quarta': DateTime.wednesday,
      'Quinta': DateTime.thursday,
      'Sexta': DateTime.friday,
      'Sábado': DateTime.saturday,
    };

    while (!diasHabilitados.contains(diaMap.keys.firstWhere(
      (key) => diaMap[key] == initialDate.weekday,
    ))) {
      initialDate = initialDate.add(const Duration(days: 1));
    }

    return initialDate;
  }

  Future<void> _mostrarCalendario(BuildContext context) async {
    final DateTime firstDate = _getFirstDate();
    final DateTime lastDate = _getLastDate();

    final List<String> diasHabilitados = widget.semanas ?? [];

    // print('firstDate: $firstDate');
    // print('lastDate: $lastDate');
    // print('diasHabilitados: $diasHabilitados');

    DateTime validInitialDate =
        _getValidInitialDate(_selectedDate ?? DateTime.now(), diasHabilitados);

    final Map<String, int> diaMap = {
      'Domingo': DateTime.sunday,
      'Segunda': DateTime.monday,
      'Terça': DateTime.tuesday,
      'Quarta': DateTime.wednesday,
      'Quinta': DateTime.thursday,
      'Sexta': DateTime.friday,
      'Sábado': DateTime.saturday,
    };

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: validInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTema.primaryDarkBlue,
              onPrimary: Colors.white,
              onSurface: AppTema.primaryDarkBlue,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
      selectableDayPredicate: (DateTime date) {
        // Verifica se o dia da semana está na lista de dias habilitados
        return diasHabilitados.contains(
          diaMap.keys.firstWhere(
            (key) => diaMap[key] == date.weekday,
          ),
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTema.backgroundColorApp,
            elevation: 0.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onPressed: () => _mostrarCalendario(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : widget.label ?? "Selecione uma data",
                style: const TextStyle(
                  color: AppTema.primaryDarkBlue,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Icon(
                Icons.calendar_today,
                color: AppTema.primaryDarkBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
