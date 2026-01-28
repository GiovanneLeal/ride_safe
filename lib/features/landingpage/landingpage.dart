import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // --- ESTADOS DA TELA ---
  bool _logoCentralizada = true;
  bool _estaCarregando = false;
  bool _mostrarFormulario = false;

  // --- CONFIGURAÇÃO DE TEMPOS (AJUSTE AQUI) ---
  // Tempo que o logo demora para subir
  final Duration _tempoSubida = const Duration(milliseconds: 1500);
  
  // Tempo que a roleta fica girando antes de mostrar o login
  final Duration _tempoCarregando = const Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _iniciarAnimacao();
  }

  void _iniciarAnimacao() async {
    // 1. O App abre e o logo fica parado no centro por 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // 2. Apenas movemos o logo. A roleta continua oculta.
    setState(() {
      _logoCentralizada = false;
    });

    // 3. Esperamos exatamente o tempo da subida terminar
    await Future.delayed(_tempoSubida); 

    // 4. O logo chegou no topo, então ligamos a roleta
    setState(() {
      _estaCarregando = true;
    });

    // 5. A roleta gira pelo tempo definido
    await Future.delayed(_tempoCarregando);

    // 6. Fim do carregamento, mostra o formulário
    setState(() {
      _estaCarregando = false;
      _mostrarFormulario = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // --- CAMADA 1: FUNDO ---
              Positioned.fill(
                child: Image.asset(
                  'assets/images/wallpaper_5.jpg', // Verifique se o nome está correto
                  fit: BoxFit.cover,
                ),
              ),
              // --- CAMADA 2: FILTRO ---
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),

              // --- CAMADA 3: O LOGOTIPO ANIMADO ---
              AnimatedPositioned(
                duration: _tempoSubida, // Variável de movimento
                curve: Curves.easeInOutCubic,
                
                // Se centralizada: (AlturaTela / 2) - (MetadeAlturaLogo). 
                // Se subiu: 130px do topo.
                top: _logoCentralizada ? (size.height / 2) - 100 : 130,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: _tempoSubida, // Sincronizado com o movimento
                  height: _logoCentralizada ? 200 : 180, // Diminui de tamanho
                  child: Image.asset('assets/logos/logotransp2.png'),
                ),
              ),

              // --- CAMADA 4: A ROLETA DE CARREGAMENTO ---
              if (_estaCarregando)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFCF0025),
                    strokeWidth: 7,
                  ),
                ),

              // --- CAMADA 5: OS INPUTS DE LOGIN ---
              Positioned(
                top: 220,
                left: 30,
                right: 30,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800), // Fade in suave
                  opacity: _mostrarFormulario ? 1.0 : 0.0,
                  
                  child: IgnorePointer(
                    ignoring: !_mostrarFormulario,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Acesse sua Conta",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        
                        // Input E-mail
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            hintText: 'E-mail',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.email, color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Input Senha
                        TextField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            hintText: 'Senha',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Botão Entrar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCF0025),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: const Text("ENTRAR", style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
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