import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Pega o usuário atual para saber de QUEM buscar as notificações
  final User? usuarioAtual = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // Se não tiver usuário logado, mostra erro ou vazio
    if (usuarioAtual == null) return const Scaffold(body: Center(child: Text("Faça login.")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Notificações", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: "Limpar tudo",
            onPressed: _limparTodasNotificacoes,
          )
        ],
      ),
      // O VIGIA DO BANCO DE DADOS
      body: StreamBuilder<QuerySnapshot>(
        // Onde ele vai vigiar: Coleção 'notificacoes' DENTRO do documento do usuário
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioAtual!.uid)
            .collection('notificacoes')
            .orderBy('data', descending: true) // Mais recentes primeiro
            .snapshots(),
        
        builder: (context, snapshot) {
          // 1. Verificando erros ou carregamento
          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar avisos."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Verifica se está vazio
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEstadoVazio();
          }

          // 3. Monta a lista real
          final listaDocumentos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaDocumentos.length,
            itemBuilder: (context, index) {
              // Pega os dados brutos do banco
              var dados = listaDocumentos[index].data() as Map<String, dynamic>;
              String idDoc = listaDocumentos[index].id; // ID para poder apagar depois

              return _buildCardNotificacao(dados, idDoc);
            },
          );
        },
      ),
    );
  }

  // --- CARD DE NOTIFICAÇÃO CONECTADO ---
  Widget _buildCardNotificacao(Map<String, dynamic> item, String idDoc) {
    // Define cores (Usei um padrão simples caso o campo 'tipo' não exista no banco)
    String tipo = item['tipo'] ?? 'info';
    bool lida = item['lida'] ?? false;
    
    Color corTema;
    IconData icone;

    if (tipo == 'alerta') {
      corTema = Colors.redAccent;
      icone = Icons.warning_amber_rounded;
    } else if (tipo == 'promo') {
      corTema = Colors.green;
      icone = Icons.local_offer;
    } else {
      corTema = Colors.blueAccent;
      icone = Icons.info_outline;
    }

    // Formata a data (Simples)
    String tempo = "Agora";
    if (item['data'] != null) {
      DateTime data = (item['data'] as Timestamp).toDate();
      tempo = "${data.day}/${data.month} ${data.hour}:${data.minute}";
    }

    return Dismissible(
      key: Key(idDoc),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // APAGA DO BANCO DE DADOS DE VERDADE
        FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioAtual!.uid)
            .collection('notificacoes')
            .doc(idDoc)
            .delete();
            
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notificação removida")));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: corTema.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icone, color: corTema),
          ),
          title: Text(
            item['titulo'] ?? "Aviso",
            style: TextStyle(fontWeight: lida ? FontWeight.normal : FontWeight.bold),
          ),
          subtitle: Text(item['msg'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tempo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (!lida) ...[
                const SizedBox(height: 5),
                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
              ]
            ],
          ),
          onTap: () {
            // MARCA COMO LIDA NO BANCO
            FirebaseFirestore.instance
                .collection('usuarios')
                .doc(usuarioAtual!.uid)
                .collection('notificacoes')
                .doc(idDoc)
                .update({'lida': true});
          },
        ),
      ),
    );
  }

  // --- FUNÇÃO PARA LIMPAR TUDO ---
  void _limparTodasNotificacoes() async {
    // Busca todas
    var snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioAtual!.uid)
        .collection('notificacoes')
        .get();

    // Apaga uma por uma
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text("Sem notificações", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }
}