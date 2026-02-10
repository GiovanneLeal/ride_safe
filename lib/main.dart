import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// IMPORTS DAS SUAS TELAS
import 'package:ride_safe/features/bottombar/bottombar.dart';
import 'features/landingpage/landingpage.dart'; 
import 'features/register/register.dart';

void main() async { // 
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o sistema tá pronto
  
  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Safe',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Dica: Visual3 deixa os inputs e botões mais modernos
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCF0025), // A cor "mãe" do app
          brightness: Brightness.dark,  // Define se o app é tema claro ou escuro
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1), // Fundo translúcido
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Bordas arredondadas
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCF0025),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      // --- PONTO DE PARTIDA ---
      // Agora o app começa direto na tela animada
      home: const LandingPage(),

      // --- ROTAS DE NAVEGAÇÃO ---
      routes: {
        // Quando o usuário clicar em "ENTRAR", o código chama '/home'
        '/home': (context) => const BottomBar(),
        
        // Se precisar voltar para o login depois (logout)
        '/login': (context) => const LandingPage(),

        // Outras rotas futuras:
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}