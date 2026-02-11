import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para salvar no banco
import 'package:firebase_auth/firebase_auth.dart'; // Para pegar o usuário logado
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:ride_safe/features/config/config.dart';
import 'package:ride_safe/features/home/home.dart';
import 'package:ride_safe/features/map/map.dart';
import 'package:ride_safe/features/workshops/workshops.dart';
import 'package:ride_safe/features/notifications/notifications.dart';


class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottombarState();
}

class _BottombarState extends State<BottomBar> {
  int _indiceAtual = 0; // Controla qual aba está selecionada (0 = Home)

  // Lista das páginas que vão aparecer no "miolo"
  final List<Widget> _telas = [
    const HomeScreen(),     // 0
    const WorkshopsScreen(), // 1
    const MapScreen(),     // 2
    const ConfigScreen(),   // 3
  ];
  void initState() {
    super.initState();
    // Chama as funções ao iniciar a tela
    _salvarTokenNoBanco();
  }

  // Função para SALVAR O TOKEN no Firestore (Chame isso no initState)
  void _salvarTokenNoBanco() async {
  // Pega o endereço deste celular
    String? token = await FirebaseMessaging.instance.getToken();
    User? user = FirebaseAuth.instance.currentUser;

    // Se tiver token e usuário logado, salva!
    if (token != null && user != null) {
      await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .update({
          'fcm_token': token, 
      });
      print(">>> SUCESSO: Token salvo no banco!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. APP BAR SUPERIOR (Logotipo e Ícones)
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212), // Cor de fundo do topo
        elevation: 0,
        automaticallyImplyLeading: false, // Remove a seta de voltar automática
        toolbarHeight: 120,
        // Lado Esquerdo: Logotipo
        title: Row(
          children: [
            Image.asset('assets/logos/biglogotransp2.png', height: 90),
            const SizedBox(width: 30),
          ],
        ),

        // Lado Direito: Notificação
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFCF0025), size: 30), 
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NotificationScreen())
              );
            },
          ),
          const SizedBox(width: 20),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // 2. CORPO (Onde as páginas mudam)
      body: _telas[_indiceAtual],

      // 3. BARRA INFERIOR CUSTOMIZADA
      bottomNavigationBar: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFCF0025), // Fundo da barra inferior
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -2))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
            children: [
              _botaoNavegacao(0, Icons.home, "Home"),
              _botaoNavegacao(1, Icons.build, "Oficinas"),
              _botaoNavegacao(2, Icons.map, "Mapa"),
              _botaoNavegacao(3, Icons.more_horiz, "Config"),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os ícones da barra inferior
  Widget _botaoNavegacao(int index, IconData icon, String label) {
    bool isSelected = _indiceAtual == index;

    return GestureDetector(
      onTap: () {
        setState(() => _indiceAtual = index);
      },
      behavior: HitTestBehavior.opaque, // Melhora o toque
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // O Ícone
          Icon(
            icon,
            size: 40,
            // Se selecionado: Preto. Se não: Branco.
            color: isSelected ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
          ),
          
          const SizedBox(height: 5),
          
          // A Barrinha Branca Embaixo
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isSelected ? 25 : 0, // Se selecionado mostra, se não some
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}