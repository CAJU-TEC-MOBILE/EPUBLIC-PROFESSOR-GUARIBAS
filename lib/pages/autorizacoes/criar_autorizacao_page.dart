import 'package:flutter/material.dart';
import 'package:professor_acesso_notifiq/constants/app_tema.dart';
import 'package:professor_acesso_notifiq/functions/textos/extrair_primeiro_nome.dart';
import 'package:professor_acesso_notifiq/models/auth_model.dart';
import 'package:professor_acesso_notifiq/models/etapa_model.dart';
import 'package:professor_acesso_notifiq/models/gestao_ativa_model.dart';
import 'package:professor_acesso_notifiq/models/pedido_model..dart';
import 'package:professor_acesso_notifiq/pages/aulas/criar_aula_page.dart';
import 'package:professor_acesso_notifiq/services/adapters/auth_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/gestao_ativa_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/pedidos_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/adapters/usuarios_service_adapter.dart';
import 'package:professor_acesso_notifiq/services/http/autorizacoes/autorizacoes_salvar_service.dart';

import '../../componentes/dialogs/custom_snackbar.dart';

class CriarAutorizacaoPage extends StatefulWidget {
  final Etapa? etapa;
  const CriarAutorizacaoPage({super.key, required this.etapa});

  @override
  State<CriarAutorizacaoPage> createState() => _CriarAutorizacaoPageState();
}

class _CriarAutorizacaoPageState extends State<CriarAutorizacaoPage> {
  final TextEditingController _obsController = TextEditingController();

  List<Pedido> _listaPedidos = [];
  List<Auth> _listaAvaliadores = [];
  GestaoAtiva? gestaoAtivaModel =
      GestaoAtivaServiceAdapter().exibirGestaoAtiva();
  Auth authModel = AuthServiceAdapter().exibirAuth();

  var _pedidoSelecionadoID;
  var _avaliadorSelecionadoID;

  @override
  void initState() {
    super.initState();
    getStart();
  }

  Future<void> getStart() async {
    _listaPedidos = PedidosServiceAdapter().listar();
    _listaAvaliadores = UsuariosServiceAdapter().listar();
    _listaAvaliadores.sort((a, b) => a.name.compareTo(b.name.toUpperCase()));

    setState(() {});
  }

  Future<void> _salvarAutorizacao(BuildContext context) async {
    try {
      
      if (_pedidoSelecionadoID == null) {
        CustomSnackBar.showErrorSnackBar(context, 'Solicitação é obrigatório');
        return;
      }

      if (_avaliadorSelecionadoID == null) {
        CustomSnackBar.showErrorSnackBar(context, 'Avaliador é obrigatório');
        return;
      }

      if (_avaliadorSelecionadoID == null) {
        CustomSnackBar.showErrorSnackBar(context, 'observação é obrigatório');
        return;
      }


      await ApiSalvarAutorizacoesService().executar(
        context,
        pedidoID: _pedidoSelecionadoID.toString(),
        instrutorDisciplinaTurmaID: gestaoAtivaModel!.idt_id.toString(),
        etapaID: widget.etapa!.id.toString(),
        userSolicitanteID: authModel.id.toString(),
        userAprovadorID: _avaliadorSelecionadoID.toString(),
        observacao: _obsController.text,
      );
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CriarAulaPage(),
        ),
      );
    } catch (e) { 
      throw Exception('Ocorreu um erro ao salvar a autorização.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTema.backgroundColorApp,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CriarAulaPage()),
            );
          },
        ),
        title: const Text('Pedido de Autorização'),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppTema.primaryWhite,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Etapa ${widget.etapa!.descricao.toString()}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 5),
                        child: const Text(
                          'Selecione a solicitação',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      DropdownButtonFormField<int>(
                        value: _pedidoSelecionadoID,
                        dropdownColor: AppTema.primaryWhite,
                        elevation: 1,
                        onChanged: (var novaSelecao) {
                          setState(() {
                            _pedidoSelecionadoID = novaSelecao;
                          });
                        },
                         decoration: InputDecoration(
                          fillColor: AppTema.backgroundColorApp,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        items:
                            _listaPedidos.map<DropdownMenuItem<int>>((objeto) {
                          return DropdownMenuItem<int>(
                              value: int.parse(objeto.id),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  objeto.descricao, // Exibe o texto completo
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                ),
                              ));
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um pedido';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 5),
                        child: const Text(
                          'Selecione o avaliador',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      DropdownButtonFormField<int>(
                        value: _avaliadorSelecionadoID,
                          dropdownColor: AppTema.primaryWhite,
                        elevation: 1,
                        onChanged: (var novaSelecao) {
                          setState(() {
                            _avaliadorSelecionadoID = novaSelecao;
                          });
                        },
                        focusColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppTema.backgroundColorApp,
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.0,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                        items: _listaAvaliadores
                            .map<DropdownMenuItem<int>>((objeto) {
                          return DropdownMenuItem<int>(
                            value: int.parse(objeto.id),
                            child: Container(
                              width: 200,
                              child: Text(
                                '${extrairPrimeiroNome(objeto.name.toUpperCase())}',
                                overflow: TextOverflow
                                    .ellipsis, // Para evitar quebra de linha
                              ),
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione um pedido';
                          }
                          return null;
                        },
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 15),
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Observação',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _obsController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor, preencha o conteúdo';
                          }
                          return null;
                        },
                        maxLines: 8,
                        decoration: InputDecoration(
                          fillColor: AppTema.backgroundColorApp,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 16.0),
                        child:  ElevatedButton(
                            onPressed: () async {
                              await _salvarAutorizacao(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTema.primaryDarkBlue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 34.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text(
                              'Enviar',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
