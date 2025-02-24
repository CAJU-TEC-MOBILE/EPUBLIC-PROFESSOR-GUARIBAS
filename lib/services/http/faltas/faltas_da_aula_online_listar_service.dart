import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/componentes/global/preloader.dart';
import 'package:professor_acesso_notifiq/models/matricula_model.dart';
import 'package:professor_acesso_notifiq/models/models_online/falta_model_online.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:professor_acesso_notifiq/pages/login_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/http/faltas/faltas_da_aula_online_listar_http.dart';
import 'package:professor_acesso_notifiq/services/widgets/snackbar_service_widget.dart';

import '../../../componentes/dialogs/custom_snackbar.dart';

class FaltasDaAulaOnlineListarService {
  Future<List<FaltaModelOnline>> todasAsFaltas(BuildContext context,
      {required String aula_id}) async {
    List<FaltaModelOnline> faltasOnlines = [];

    showLoading(context);

    FaltasDaAulaOnlineListarHttp apiService = FaltasDaAulaOnlineListarHttp();
    http.Response response =
        await apiService.executar(aula_id: aula_id.toString());
    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      print('data: $data');
      List<dynamic> faltas = data['faltas'];

      for (var falta in faltas) {
        faltasOnlines.add(
          FaltaModelOnline(
            id: falta['id'].toString(),
            justificativa_id: falta['justificativa_id'].toString(),
            matricula_id: falta['matricula_id'].toString(),
            aula_id: falta['aula_id'].toString(),
            justificativa_descricao:
                falta['justificativa']?['descricao']?.toString() ?? '',
            status: true,
            existe_anexo: falta['existe_anexo'],
          ),
        );
      }

      hideLoading(context);
      return faltasOnlines;
    } else if (response.statusCode == 401) {
      AuthServiceAdapter().removerDadosAuth();

      Future.microtask(() {
        hideLoading(context);
        CustomSnackBar.showErrorSnackBar(context, 'Conexão expirada');

        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      });

      hideLoading(context);
      return faltasOnlines;
    } else {
      Future.microtask(() {
        CustomSnackBar.showErrorSnackBar(context, 'Erro de conexão');
      });

      hideLoading(context);
      return faltasOnlines;
    }
  }
}
