import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/models/SongCardTransation.dart';
import 'package:wavekeeper/screens/business/searchPage.dart';

class BusinessView extends StatefulWidget {
  final String userId;

  const BusinessView({super.key, required this.userId});

  @override
  State<BusinessView> createState() => _BusinessViewState();
}

class _BusinessViewState extends State<BusinessView> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await supabase
          .from('transacao')
          .select('id, id_obra, id_comprador')
          .eq('id_comprador', widget.userId)
          .eq('status', false);

      List<Map<String, dynamic>> loadedTransactions = [];
      for (final transaction in response) {
        final obraResponse = await supabase
            .from('obra')
            .select('id, capa_url, titulo, preco, id_usuario')
            .eq('id', transaction['id_obra'])
            .single();


        loadedTransactions.add({
          'transactionId': transaction['id'],
          'obraId': obraResponse['id'],
          'imageUrl': obraResponse['capa_url'],
          'songName': obraResponse['titulo'],
          'price': obraResponse['preco'],
          'idComprador': transaction['id_comprador'],
          'idVendedor': transaction['id_vendedor'].toString(),
        });
            }

      setState(() {
        transactions = loadedTransactions;
      });
    } catch (error) {
      print('Erro ao buscar transações: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Icon(Icons.business_center, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              const Text(
                'Negociações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                ),
              ),
              Align(
            alignment: Alignment.topRight, 
            child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ),
              ),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.black],
                stops: [0.1, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          elevation: 0.0,
        ),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('Nenhuma transação pendente.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return SongCard(
                  imageUrl: transaction['imageUrl'],
                  songName: transaction['songName'],
                  price: 'R\$ ${transaction['price'].toStringAsFixed(2)}',
                  userId: transaction['idComprador'],
                  obraId: transaction['obraId'],
                  transactionId: transaction['transactionId'],
                );
              },
            ),
    );
  }
}
