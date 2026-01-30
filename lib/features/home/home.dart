import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BARRA SUPERIOR ---
      appBar: AppBar(
        title: const Text('Menu Principal'),
        backgroundColor: const Color(0xFFCF0025),
        foregroundColor: Colors.white, // Cor do texto/ícones
        actions: [
          // Botão de Logout (Sair)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Volta para a tela de login e remove o histórico
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      // --- CORPO DA TELA ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de sucesso
            const Icon(
              Icons.check_circle_outline, 
              size: 100, 
              color: Colors.green
            ),
            const SizedBox(height: 20),
            
            // Texto de boas-vindas
            const Text(
              'Login realizado com sucesso!',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 10),
            const Text('Você está na Home Screen.'),

            const SizedBox(height: 40),
            
            // Exemplo de botão para funcionalidades futuras
            ElevatedButton.icon(
              icon: const Icon(Icons.car_repair),
              label: const Text("Consultar Tabela FIPE"),
              onPressed: () {
// Apenas um aviso visual por enquanto
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em desenvolvimento!'))
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}