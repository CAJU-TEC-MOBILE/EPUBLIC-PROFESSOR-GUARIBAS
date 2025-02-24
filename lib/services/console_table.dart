import 'package:cli_table/cli_table.dart';

class ConsoleTable {
  Future<void> getDatabase({required String database}) async {
    final table = Table(
      header: ['N°', 'Nome'],
    );

    table.addAll([
      ['1', database],
    ]);

    print(table.toString());
  }
}
