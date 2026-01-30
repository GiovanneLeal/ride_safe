import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  // Os controladores de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Para liberar memória quando a tela fechar
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // --- ESTADOS DA TELA ---
  bool _logoCentralizada = true;
  bool _estaCarregando = false;
  bool _mostrarFormulario = false;
  bool _verificouArgumentos = false;

  // --- CONFIGURAÇÃO DE TEMPOS (AJUSTE AQUI) ---
  // Tempo que o logo demora para subir
  final Duration _tempoSubida = const Duration(milliseconds: 1500);
  
  // Tempo que a roleta fica girando antes de mostrar o login
  final Duration _tempoCarregando = const Duration(seconds: 3);

@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_verificouArgumentos) {
      // Tenta pegar os argumentos passados pelo Navigator
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      
      // Se tiver o argumento 'pularAnimacao' como true
      if (args != null && args['pularAnimacao'] == true) {
        // Já define o estado final direto, sem animação
        setState(() {
          _logoCentralizada = false;
          _estaCarregando = false;
          _mostrarFormulario = true;
        });
      } else {
        // Se não tiver argumento, roda a animação normal
        _iniciarAnimacao();
      }
      _verificouArgumentos = true;
    }
  }

  void _iniciarAnimacao() async {
    await Future.delayed(const Duration(seconds: 2));     // 1. O App abre e o logo fica parado no centro por 2 segundos
    if(!mounted) return;
    setState(() => _logoCentralizada = false);     // 2. Apenas movemos o logo. A roleta continua oculta.
    
    await Future.delayed(_tempoSubida);    // 3. Esperamos exatamente o tempo da subida terminar
    if(!mounted) return;
    setState(() => _estaCarregando = true);    // 4. O logo chegou no topo, então ligamos a roleta
    
    await Future.delayed(_tempoCarregando);     // 5. A roleta gira pelo tempo definido
    if(!mounted) return;
    setState(() {      // 6. Fim do carregamento, mostra o formulário
      _estaCarregando = false;
      _mostrarFormulario = true;
    });
  }

  // Função para fazer Login
  Future<void> _fazerLogin() async {       // Mostra um loading rápido
    try {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Tenta logar no Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // trim remove espaços vazios
        password: _passwordController.text.trim(),
      );
      if(!mounted) return;

      Navigator.pop(context); //Se deu certo, fecha o loading
      Navigator.pushReplacementNamed(context, '/home'); // E vai para a Home
    } on FirebaseAuthException catch (e) {
      
      Navigator.pop(context); // Se deu erro, fecha o loading e avisa
      String mensagemErro = "Erro desconhecido";
      if (e.code == 'user-not-found') mensagemErro = "E-mail não cadastrado.";
      if (e.code == 'wrong-password') mensagemErro = "Senha incorreta.";
      if (e.code == 'invalid-email') mensagemErro = "E-mail inválido.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                top: 220, left: 30, right: 30, bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: _mostrarFormulario ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !_mostrarFormulario,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bem-vindo de volta.", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),

                        // Inputs apenas de LOGIN
                        TextField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true, fillColor: Colors.white.withOpacity(0.2),
                            hintText: 'E-mail', hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.email, color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true, fillColor: Colors.white.withOpacity(0.2),
                            hintText: 'Senha', hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.lock, color: Colors.white),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity, height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCF0025)),
                            onPressed: _fazerLogin,
                            child: const Text("ENTRAR", style: TextStyle(color: Colors.white)),
                          ),
                        ),

                        const SizedBox(height: 20),
                        
                        // Botão que leva para a nova tela de cadastro
                        TextButton(
                          onPressed: () {
                            // Navega para a tela de registro
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Criar uma nova conta", style: TextStyle(color: Color(0xFFCF0025), fontWeight: FontWeight.bold)),
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