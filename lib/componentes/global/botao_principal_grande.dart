import 'package:flutter/material.dart';

class BotaoPrincipalGrande extends StatelessWidget {
  final double? width;
  final VoidCallback onPressed;
  final String texto;
  final IconData icon;
  final Color cor;
  const BotaoPrincipalGrande(
      {super.key,
      this.width = 115,
      required this.texto,
      required this.icon,
      required this.cor,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: SizedBox(
        width: width,
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Define o raio da borda
          ),
          color: cor,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 80.0,
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ), 
                Text(
                  texto,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
