// import '../constants/app_tema.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../pages/calendario_page.dart';
// import '../providers/custom_calendario_circuito_nota_provider.dart';

// class CustomCalendarioCircuitoNota extends StatefulWidget {
//   const CustomCalendarioCircuitoNota({super.key});

//   @override
//   State<CustomCalendarioCircuitoNota> createState() =>
//       _CustomCalendarioCircuitoNotaState();
// }

// class _CustomCalendarioCircuitoNotaState
//     extends State<CustomCalendarioCircuitoNota> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final provider = Provider.of<CustomCalendarioCircuitoNotaProvider>(
//         context,
//         listen: false,
//       );
//       await provider.loadData(context: context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<CustomCalendarioCircuitoNotaProvider>(context);

//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               const Text(
//                 'Circuito de Notas',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15.0,
//                   color: AppTema.primaryDarkBlue,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 provider.ano.descricao ?? '--/--/----',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15.0,
//                   color: AppTema.primaryDarkBlue,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(),
//           if (provider.isLoading)
//             const Center(child: CircularProgressIndicator())
//           else if (provider.errorMessage != null)
//             Text(
//               provider.errorMessage!,
//               style: const TextStyle(color: Colors.red),
//             )
//           else
//             SizedBox(
//               height: 380,
//               child: CalendarioPage(
//                 eventos: provider.eventos,
//               ),
//             ),
//           Column(
//             children: provider.etapas.map((etapa) {
//               return SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 child: Card(
//                   color: AppTema.backgroundColorApp,
//                   elevation: 0.0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           etapa.descricao.toString(),
//                         ),
//                         Text(
//                           etapa.prazo.toString(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           )
//         ],
//       ),
//     );
//   }
// }
