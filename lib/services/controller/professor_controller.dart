import 'package:hive_flutter/hive_flutter.dart';
import '../../models/professor_model.dart';
import 'auth_controller.dart';

class ProfessorController {
  late Box<Professor> box;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(ProfessorAdapter().typeId)) {
      Hive.registerAdapter(ProfessorAdapter());
    }

    box = await Hive.openBox<Professor>('professores');
  }

  Future<void> create(Map<String, dynamic> model) async {
    try {
      // await clear();
      Professor professor = Professor(
        id: model['id']?.toString() ?? '',
        userId: model['user_id']?.toString() ?? '',
        nome: model['nome']?.toString() ?? '',
        email: model['email']?.toString() ?? '',
        cpf: model['cpf']?.toString() ?? '',
        codigo: model['codigo']?.toString() ?? '',
        matricula: model['matricula']?.toString() ?? '',
        vinculo: model['vinculo']?.toString() ?? '',
        dataNascimento: model['data_nascimento']?.toString() ?? '',
        corOuRaca: model['cor_ou_raca']?.toString() ?? '',
        municipalidade: model['municipalidade']?.toString() ?? '',
        naturalidade: model['naturalidade']?.toString() ?? '',
        estadualidade: model['estadualidade']?.toString() ?? '',
        nacionalidade: model['nacionalidade']?.toString() ?? '',
        zonaResidencia: model['zona_residencia']?.toString() ?? '',
        municipioResidencia: model['municipio_residencia']?.toString() ?? '',
        ufResidencia: model['uf_residencia']?.toString() ?? '',
        paisResidencia: model['pais_residencia']?.toString() ?? '',
        cep: model['cep']?.toString() ?? '',
        filiacao1: model['filiacao1']?.toString() ?? '',
        filiacao2: model['filiacao2']?.toString() ?? '',
        roleId: model['role_id']?.toString() ?? '',
      );
      await box.add(professor);
      print('Professor adicionado sucesso!');
    } catch (e) {
      print('Professor error: $e');
    }
  }

  Future<Professor?> getProfessor() async {
    if (box.isEmpty) {
      return null;
    }
    print(box.values.first);
    return box.values.first;
  }

  Future<int> clear() async {
    return await box.clear();
  }

  Future<void> update(model) async {
    //final authController = AuthController();
    //await authController.init();
    await clear();
    await create(model);
    //await authController.updateName(model['nome']?.toString() ?? '');
  }
}
