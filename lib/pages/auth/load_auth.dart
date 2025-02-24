import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoadAuth extends StatefulWidget {
  const LoadAuth({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoadAuthState createState() => _LoadAuthState();
}

class _LoadAuthState extends State<LoadAuth> {
  @override
  void initState() {
    super.initState();
    loadAuth();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.top]);
  }

  loadAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      var verifyAuth = Hive.box('auth');

      if (verifyAuth.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/todasAsGestoesDoProfessor');
        return;
      }

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/icon_notifiq_sem_fundo.png',
                  width: 200,
                  height: 200,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: const CircularProgressIndicator(
                    color: Color.fromARGB(255, 229, 157, 3),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
