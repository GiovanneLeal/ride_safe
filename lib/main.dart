import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

// IMPORTS DAS SUAS TELAS
import 'package:ride_safe/features/bottombar/bottombar.dart';
import 'features/landingpage/landingpage.dart'; 
import 'features/register/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Safe',
      debugShowCheckedModeBanner: false,

      // TEMA GLOBAL (DESIGN SYSTEM)
      theme: ThemeData(
        useMaterial3: true,
        
        // Cores Principais
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCF0025),
          brightness: Brightness.dark,
        ),

        // Estilo Global dos Inputs (Caixas de Texto)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200], // Fundo cinza claro
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIconColor: const Color(0xFFCF0025),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF0025), width: 2),
          ),
        ),

        // Estilo Global dos Botões
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCF0025),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        // Estilo da AppBar Padrão 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCF0025),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      
      // ROTAS E NAVEGAÇÃO
      // Se já estiver logado, vai pra Home. Se não, Login.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const BottomBar(); // Usuário Logado -> Vai pra Tela Principal
          }
          return const LandingPage(); // Não Logado -> Vai pro Login
        },
      ),

      // Definição das Rotas Nomeadas
      routes: {
        '/login': (context) => const LandingPage(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const BottomBar(),
      },
    );
  }
}