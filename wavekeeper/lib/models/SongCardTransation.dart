import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SongCard extends StatelessWidget {
  final String imageUrl;
  final String songName;
  final String price;
  final String userId;
  final int obraId;
  final int transactionId;

  const SongCard({
    required this.imageUrl,
    required this.songName,
    required this.price,
    required this.userId,
    required this.obraId,
    required this.transactionId,
  });

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final supabase = Supabase.instance.client;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Deseja confirmar a negociação?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        // 1. Buscar detalhes da obra e vendedor
        final obraData = await supabase
            .from('obra')
            .select('titulo, id_usuario')
            .eq('id', obraId)
            .single();
        final vendedorId = obraData['id_usuario'];

        // 2. Buscar dados do comprador e vendedor
        final compradorData = await supabase
            .from('usuario')
            .select('nome, email, CPF')
            .eq('id', userId)
            .single();
        final vendedorData = await supabase
            .from('usuario')
            .select('nome, email, CPF')
            .eq('id', vendedorId)
            .single();

        // 3. Gerar contrato e obter data atual
        final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        final contrato = '''
          Contrato de Compra e Venda de Direitos:
          Comprador: ${compradorData['nome']}, Email: ${compradorData['email']}, CPF: ${compradorData['CPF']}
          Vendedor: ${vendedorData['nome']}, Email: ${vendedorData['email']}, CPF: ${vendedorData['CPF']}
          Obra: ${obraData['titulo']}
          Data: $now
        ''';

        // 4. Atualizar transação e salvar contrato
        await supabase.from('transacao').update({
          'status': true,
          'realizada_em': now,
          'contrato': contrato,
          'id_vendedor':vendedorId
        }).eq('id', transactionId);

        // 5. Transferir posse da obra para o comprador
        await supabase
            .from('obra')
            .update({'id_usuario': userId})
            .eq('id', obraId);

        _showSuccessDialog(context);
      } catch (error) {
        _showErrorDialog(context, 'Erro ao confirmar transação: $error');
      }
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erro"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Negociação confirmada com sucesso."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(songName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(price, style: const TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _showConfirmationDialog(context),
                  child: const Text("Confirmar Compra"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
