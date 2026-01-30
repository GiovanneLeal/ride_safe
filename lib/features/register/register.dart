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
    // 1. Validações Básicas
    if (_nomeController.text.isEmpty || 
        _sobrenomeController.text.isEmpty ||
        _emailController.text.isEmpty || 
        _senhaController.text.isEmpty) {
      _mostrarErro("Preencha todos os campos.");
      return;
    }

    if (_senhaController.text != _confirmaSenhaController.text) {
      _mostrarErro("As senhas não conferem.");
      return;
    }

    if (!_termosAceitos) {
      _mostrarErro("Você precisa aceitar os termos.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Cria usuário no Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 3. Salva dados no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': _nomeController.text.trim(),
        'sobrenome': _sobrenomeController.text.trim(),
        'email': _emailController.text.trim(),
        'criado_em': FieldValue.serverTimestamp(),
        'tipo_conta': 'padrao',
      });

      // 4. Sucesso! Volta para o Login (pulando animação)
      if (mounted) {
        // Envia um argumento 'pularAnimacao' como true
        Navigator.pushReplacementNamed(context, '/login', arguments: {'pularAnimacao': true});
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conta criada com sucesso!")),
        );
      }

    } on FirebaseAuthException catch (e) {
      String msg = "Erro ao cadastrar.";
      if (e.code == 'email-already-in-use') msg = "Este e-mail já está em uso.";
      if (e.code == 'weak-password') msg = "A senha é muito fraca.";
      _mostrarErro(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            
            _input(_nomeController, "Nome", Icons.person),
            const SizedBox(height: 15),
            _input(_sobrenomeController, "Sobrenome", Icons.person_outline),
            const SizedBox(height: 15),
            _input(_emailController, "E-mail", Icons.email, tipo: TextInputType.emailAddress),
            const SizedBox(height: 15),
            _input(_senhaController, "Senha", Icons.lock, oculto: true),
            const SizedBox(height: 15),
            _input(_confirmaSenhaController, "Confirmar Senha", Icons.lock_outline, oculto: true),
            
            const SizedBox(height: 20),

            // Checkbox de Termos
            Row(
              children: [
                Checkbox(
                  value: _termosAceitos,
                  onChanged: (valor) => setState(() => _termosAceitos = valor!),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Aqui você colocaria o código para abrir o link
                      // Ex: launchUrl(Uri.parse('https://seusite.com/termos'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Abrindo termos de uso...")),
                      );
                    },
                    child: const Text(
                      "Li e concordo com os Termos de Uso e Políticas de Privacidade.",
                      style: TextStyle(
                        color: Color(0xFF2196F3), 
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _realizarCadastro,
                    child: const Text("CADASTRAR"),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para não repetir código dos inputs
  Widget _input(TextEditingController controller, String label, IconData icon, 
      {bool oculto = false, TextInputType tipo = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: oculto,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}