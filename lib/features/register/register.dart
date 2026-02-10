import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  // Variável do Checkbox
  bool _termosAceitos = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

Future<void> _realizarCadastro() async {
    print("--- 1. INICIANDO PROCESSO DE CADASTRO ---");

    // Validações básicas
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _mostrarErro("Preencha todos os campos!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ETAPA A: AUTENTICAÇÃO
      print("--- 2. TENTANDO CRIAR USUÁRIO NO AUTH ---");
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );
      
      String uid = userCredential.user!.uid;
      print(">>> SUCESSO AUTH! ID GERADO: $uid");

      // ETAPA B: BANCO DE DADOS
      print("--- 3. TENTANDO SALVAR NO FIRESTORE ---");
      
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'email': _emailController.text.trim(),
        'criado_em': FieldValue.serverTimestamp(),
        'tipo_conta': 'padrao',
      });

      print(">>> SUCESSO FIRESTORE! DADOS SALVOS.");

      // ETAPA C: NAVEGAÇÃO
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login', arguments: {'pularAnimacao': true});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sucesso! Faça login.")),
        );
      }

    } on FirebaseAuthException catch (e) {
      print("!!! ERRO NO AUTH (LOGIN/SENHA) !!!");
      print("CÓDIGO: ${e.code}");
      print("MENSAGEM: ${e.message}");
      _mostrarErro("Erro no cadastro: ${e.message}");
    
    } catch (e) {
      print("!!! ERRO NO BANCO DE DADOS (FIRESTORE) !!!");
      print("O ERRO EXATO É: $e");
      _mostrarErro("Erro ao salvar dados: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4), // Fica visível por 4 segundos
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar invisível
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: Stack(
        children: [
          // 1. IMAGEM DE FUNDO (A mesma do login para consistência)
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper_5.jpg', // Certifique-se que essa imagem existe
              fit: BoxFit.cover,
            ),
          ),
          // 2. FILTRO ESCURO (Para o texto ficar legível)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          
          // 3. CONTEÚDO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    "Criar Conta",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFCF0025),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Preencha seus dados para começar",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      ),
                  ),
                  const SizedBox(height: 40),

                  // Container dos Campos
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1), // Efeito vidro
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _inputCustomizado(_nomeController, "Nome", Icons.person),
                        const SizedBox(height: 15),
                        _inputCustomizado(_sobrenomeController, "Sobrenome", Icons.person_outline),
                        const SizedBox(height: 15),
                        _inputCustomizado(_emailController, "E-mail", Icons.email, tipo: TextInputType.emailAddress),
                        const SizedBox(height: 15),
                        _inputCustomizado(_senhaController, "Senha", Icons.lock, oculto: true),
                        const SizedBox(height: 15),
                        _inputCustomizado(_confirmaSenhaController, "Confirmar Senha", Icons.lock_outline, oculto: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Checkbox customizado
                  Row(
                    children: [
                      Checkbox(
                        value: _termosAceitos,
                        activeColor: const Color(0xFFCF0025),
                        side: const BorderSide(color: Colors.white70),
                        onChanged: (v) => setState(() => _termosAceitos = v!),
                      ),
                      Expanded(
                        child: Text(
                          "Li e concordo com os Termos de Uso.",
                          style: TextStyle(color: Colors.white.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botão Largo
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _realizarCadastro,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CADASTRAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para deixar o input bonito
  Widget _inputCustomizado(TextEditingController controller, String label, IconData icon, 
      {bool oculto = false, TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: oculto,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white70),
        // O restante do estilo já vem do ThemeData no main.dart!
      ),
    );
  }
}