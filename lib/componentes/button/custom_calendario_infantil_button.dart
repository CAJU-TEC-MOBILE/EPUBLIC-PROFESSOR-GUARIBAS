// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:professor_acesso_notifiq/constants/app_tema.dart';

// ignore: must_be_immutable
class CustomCalendarioInfantilButton extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<String>? semanas;
  final String? inicioPeriodoEtapa;
  final String? fimPeriodoEtapa;
  final DateTime? onDataSelected;
  final void Function(DateTime selectedDate)? onDateSelected;
  final void Function(String diaSemana)? onDiaSelected;
  final String? label;

  const CustomCalendarioInfantilButton({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.semanas,
    this.inicioPeriodoEtapa,
    this.fimPeriodoEtapa,
    this.onDataSelected,
    this.onDateSelected,
    this.onDiaSelected,
    this.label,
  });

  @override
  _CustomCalendarioInfantilButtonState createState() =>
      _CustomCalendarioInfantilButtonState();
}

class _CustomCalendarioInfantilButtonState
    extends State<CustomCalendarioInfantilButton> {
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

      widget.onDateSelected?.call(pickedDate);

      String diaSemana = DateFormat('EEEE', 'pt_BR').format(pickedDate);
      _selecionarDia(pickedDate);
      //widget.onDiaSelected?.call(diaSemana);
    }
  }

  void _selecionarDia(DateTime date) {
    const Map<int, String> diasSemana = {
      DateTime.sunday: "Domingo",
      DateTime.monday: "Segunda-feira",
      DateTime.tuesday: "Terça-feira",
      DateTime.wednesday: "Quarta-feira",
      DateTime.thursday: "Quinta-feira",
      DateTime.friday: "Sexta-feira",
      DateTime.saturday: "Sábado",
    };

    final String diaFormatado = diasSemana[date.weekday] ?? "Desconhecido";

    if (mounted) {
      widget.onDiaSelected?.call(diaFormatado);
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
