import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../models/ano_selecionado_model.dart';
import '../../models/aula_model.dart';
import '../../models/aula_sistema_bncc_model.dart';
import '../../models/aula_totalizador_model.dart';
import '../../models/auth_model.dart';
import '../../models/faltas_model.dart';
import '../../models/historico_requencia_model.dart';
import '../../models/justificativa_model.dart';
import '../../models/matricula_model.dart';
import '../../models/serie_aula_model.dart';
import '../../models/anexo_model.dart';
import '../../models/disciplina_aula_model.dart';
import '../../models/disciplina_model.dart';
import '../../models/gestao_disciplina_model.dart';
import '../../models/horario_aula_model.dart';
import '../../models/instrutor_model.dart';
import '../../models/pedido_model.dart';
import '../../models/professor_model.dart';
import '../../models/serie_model.dart';
import '../../models/ano_model.dart';
import '../../models/tipo_aula_model.dart';
import '../../services/console_table.dart';
import '../adapters/auth_adapter.dart';

class HiveConfig {
  static Future<void> start() async {
    ConsoleTable consoleTable = ConsoleTable();

    await dotenv.load(fileName: ".env");

    String dbName = dotenv.env['DB_BANCO_LOCAL'] ?? 'db_epublic';

    consoleTable.getDatabase(database: dbName);

    Directory dir = await getApplicationDocumentsDirectory();

    String hiveDir = '${dir.path}/$dbName';

    await Hive.initFlutter(hiveDir);

    Hive.registerAdapter(AuthAdapter());
    Hive.registerAdapter(AulaAdapter());
    Hive.registerAdapter(MatriculaAdapter());
    Hive.registerAdapter(FaltaAdapter());
    Hive.registerAdapter(JustificativaAdapter());
    Hive.registerAdapter(AulaSistemaBnccAdapter());
    Hive.registerAdapter(DisciplinaAdapter());
    Hive.registerAdapter(InstrutorAdapter());
    Hive.registerAdapter(DisciplinaAulaAdapter());
    Hive.registerAdapter(HorarioConfiguracaoAdapter());
    Hive.registerAdapter(GestaoDisciplinaAdapter());
    Hive.registerAdapter(SerieAdapter());
    Hive.registerAdapter(SerieAulaAdapter());
    Hive.registerAdapter(AulaTotalizadorAdapter());
    Hive.registerAdapter(AnoAdapter());
    Hive.registerAdapter(AnoSelecionadoAdapter());
    Hive.registerAdapter(ProfessorAdapter());
    Hive.registerAdapter(AnexoAdapter());
    Hive.registerAdapter(HistoricoPresencaAdapter());
    Hive.registerAdapter(TipoAulaAdapter());
    Hive.registerAdapter(PedidoAdapter());

    await Future.wait([
      Hive.openBox('auth'),
      Hive.openBox('gestoes'),
      Hive.openBox('gestao_ativa'),
      Hive.openBox('horarios'),
      Hive.openBox('pedidos'),
      Hive.openBox('usuarios'),
      Hive.openBox('autorizacoes'),
      Hive.openBox('sistema_bncc'),
      Hive.openBox<AuthModel>('auths'),
      Hive.openBox<Aula>('aulas_offlines'),
      Hive.openBox<Matricula>('matriculas'),
      Hive.openBox<Matricula>('matriculas_da_turma_ativa'),
      Hive.openBox<Falta>('faltas'),
      Hive.openBox<Justificativa>('justificativas'),
      Hive.openBox<AulaSistemaBncc>('aula_sistema_bncc_offline'),
      Hive.openBox<Disciplina>('disciplinas'),
      Hive.openBox<Instrutor>('instrutores'),
      Hive.openBox<DisciplinaAula>('disciplina_aula'),
      Hive.openBox<HorarioConfiguracao>('horario_configuracao'),
      Hive.openBox<GestaoDisciplina>('getaos_disciplinas'),
      Hive.openBox<Serie>('series'),
      Hive.openBox<SerieAula>('series_aulas'),
      Hive.openBox<AulaTotalizador>('aula_totalizadores'),
      Hive.openBox<Ano>('anos'),
      Hive.openBox<AnoSelecionado>('ano_selecionado'),
      Hive.openBox<Professor>('professores'),
      Hive.openBox<Anexo>('anexos'),
      Hive.openBox<HistoricoPresenca>('historico_presencas'),
      Hive.openBox<TipoAula>('tipos_aulas'),
      Hive.openBox<Pedido>('pedidos_enviados'),
    ]);
  }
}
