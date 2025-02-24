import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:professor_acesso_notifiq/models/serie_model.dart';
import '../../constants/app_tema.dart';

class CustomMultiSelectSerieDropdown extends StatefulWidget {
  final List<Serie> items;
  final List<String> initialSelectedIds;
  final String title;
  final String buttonText;
  final List<Serie> initialSelectedSeries;
  final Function(List<Serie>) onConfirm;

  const CustomMultiSelectSerieDropdown({
    Key? key,
    required this.items,
    required this.onConfirm,
    this.initialSelectedIds = const [],
    this.title = "Selecione as opções",
    this.buttonText = "Selecionar",
    this.initialSelectedSeries = const [],
  }) : super(key: key);

  @override
  _CustomMultiSelectSerieDropdownState createState() =>
      _CustomMultiSelectSerieDropdownState();
}

class _CustomMultiSelectSerieDropdownState
    extends State<CustomMultiSelectSerieDropdown> {
  late List<Serie> _selectedItems;

  @override
  void initState() {
    super.initState();
    print('initialSelectedSeries: ${widget.initialSelectedSeries}');
    print('Initial Selected IDs: ${widget.initialSelectedIds}');
    print('Initial Selected Series: ${widget.initialSelectedSeries}');
    _selectedItems = widget.items.where((item) {
      return widget.initialSelectedSeries
          .any((selected) => selected.serieId == item.serieId);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<MultiSelectItem<Serie>> multiSelectItems = widget.items
        .map((serie) =>
            MultiSelectItem<Serie>(serie, serie.descricao.toString()))
        .toList();

    return MultiSelectDialogField(
      items: multiSelectItems,
      title: Text(widget.title),
      listType: MultiSelectListType.CHIP,
      searchable: true,

      initialValue: _selectedItems,
      selectedColor: AppTema.primaryAmarelo,
      checkColor: Colors.white,
      selectedItemsTextStyle: const TextStyle(
        color: Colors.white,
      ),
      cancelText: const Text(
        'Cancelar',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTema.primaryAzul,
        ),
      ),
      confirmText: const Text(
        'Confirmar',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTema.primaryAzul,
        ),
      ),
      searchIcon: const Icon(Icons.search),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      buttonIcon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.black,
      ),
      buttonText: Text(
        widget.buttonText,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
      ),
      barrierColor: Colors.black26,
      // chipDisplay: MultiSelectChipDisplay(
      //   scroll: true,
      //   items: _selectedItems
      //       .map((item) =>
      //           MultiSelectItem<Serie>(item, item.descricao.toString()))
      //       .toList(),
      // ),
      onConfirm: (results) {
        setState(() {
          _selectedItems = results.cast<Serie>();
        });
        widget.onConfirm(_selectedItems);
      },
    );
  }
}