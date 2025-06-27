import 'package:flutter/material.dart';

// Importando as páginas necessárias
import '../pages/atualizacoes/atualizacoes_list_page.dart';
import '../pages/aulas/aula__infantil_atualizar_page.dart';
import '../pages/aulas/aula_atualizar_page.dart';
import '../pages/aulas/criar_aula_infantil.dart';
import '../pages/aulas/criar_aula_page.dart';
import '../pages/aulas/listagem_aulas_infantil_page.dart';
import '../pages/aulas/listagem_aulas_page.dart';
import '../pages/aulas/listagem_fundamental_page.dart';
import '../pages/aulas/listagem_infantil_page.dart';
import '../pages/auth/load_auth.dart';
import '../pages/graficos_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/notificacao/notificacao_page.dart';
import '../pages/principal_page.dart';
import '../pages/professor/listagem_gestoes_professor.dart';
import '../pages/sobre/sobre_o_app_page.dart';
import '../pages/usuarioPage.dart';

class Routes {
  static final List<Map<String, dynamic>> _routeDefinitions = [
    {'name': '/loadAuth', 'widget': const LoadAuth()},
    {'name': '/login', 'widget': const LoginPage()},
    {'name': '/home', 'widget': const HomePage()},
    {'name': '/perfil', 'widget': const UsuarioPage()},
    {
      'name': '/todasAsGestoesDoProfessor',
      'widget': const ListagemGestoesProfessor()
    },
    {'name': '/criarAula', 'widget': const CriarAulaPage()},
    {'name': '/criarAulaInfantil', 'widget': const CriarAulaInfantilPage()},
    {'name': '/listagemAulas', 'widget': const ListagemAulasPage()},
    {
      'name': '/listagemAulasInfantil',
      'widget': const ListagemAulasInfantilPage()
    },
    {'name': '/atualizacoesList', 'widget': const AtualizacoesListPage()},
    {'name': '/sobreApp', 'widget': const SobreAppPage()},
    {'name': '/graficos', 'widget': const GraficosPage()},
    {'name': '/atualizarAula', 'widget': const AulaAtualizarPage()},
    {
      'name': '/atualizarAulaInfantil',
      'widget': const AulaInfantilAtualizarPage()
    },
    {'name': '/index-notificacao', 'widget': const NotificacaoPage()},
    {'name': '/principal', 'widget': const PrincipalPage()},
    {'name': '/index-infantil', 'widget': const ListagemInfantilPage()},
    {'name': '/index-fundamental', 'widget': const ListagemFundamentalPage()},
  ];

  static Map<String, Widget Function(BuildContext)> routes = {
    for (var route in _routeDefinitions)
      route['name']: (context) => route['widget'] as Widget,
  };
}
