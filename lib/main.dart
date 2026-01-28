import 'package:flutter/material.dart';

// IMPORTS DAS SUAS TELAS
import 'features/home/home.dart';
import 'features/landingpage/landingpage.dart'; // <--- Importe o arquivo novo aqui

// Se tiver outras telas criadas, descomente:
// import 'screens/fipe_screen.dart';
// import 'screens/mapa_screen.dart';

void main() {
  runApp(const MeuAppAuto());
}

class MeuAppAuto extends StatelessWidget {
  const MeuAppAuto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Helper',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Dica: Visual3 deixa os inputs e botões mais modernos
        useMaterial3: true, 
      ),

      // --- PONTO DE PARTIDA ---
      // Agora o app começa direto na tela animada
      home: const LandingPage(),

      // --- ROTAS DE NAVEGAÇÃO ---
      routes: {
        // Quando o usuário clicar em "ENTRAR", o código chama '/home'
        '/home': (context) => const HomeScreen(),
        
        // Se precisar voltar para o login depois (logout)
        '/login': (context) => const LandingPage(),

        // Outras rotas futuras:
        // '/fipe': (context) => const FipeScreen(),
      },
    );
  }
}