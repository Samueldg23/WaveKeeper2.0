import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SalesPage extends StatefulWidget {
  final String userId;

  const SalesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Map<String, dynamic>> _vendas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendas();
  }

  Future<void> _fetchVendas() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('transacao')
          .select('id_obra, contrato')
          .or('id_comprador.eq.${widget.userId},id_vendedor.eq.${widget.userId}');

      List<dynamic> data = response;

      final List<Map<String, dynamic>> vendasList = [];

      for (var item in data) {
        final obraResponse = await supabase
            .from('obra')
            .select('id, titulo, preco, capa_url')
            .eq('id', item['id_obra'])
            .single();

        vendasList.add({
          'titulo': obraResponse['titulo'],
          'preco': obraResponse['preco'],
          'capa_url': obraResponse['capa_url'],
          'contrato': item['contrato'],
        });
      }

      setState(() {
        _vendas = vendasList;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar vendas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 25.0,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Minhas Vendas',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white,
            letterSpacing: 0.0,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              stops: [0.2, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vendas.isEmpty
              ? const Center(
                  child: Text(
                    'Nenhuma venda efetuada.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _vendas.length,
                  itemBuilder: (context, index) {
                    final venda = _vendas[index];
                    return _buildVendaCard(context, venda);
                  },
                ),
    );
  }

  Widget _buildVendaCard(BuildContext context, Map<String, dynamic> venda) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              venda['capa_url'] != null && venda['capa_url'].isNotEmpty
                  ? Image.network(
                      venda['capa_url'],
                      height: 70.0,
                      width: 70.0,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.white70,
                      size: 70.0,
                    ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venda['titulo'] ?? 'Sem Título',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Preço: R\$ ${venda['preco']?.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                onPressed: () => _downloadContrato(context, venda['contrato']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _downloadContrato(BuildContext context, String contrato) async {
    try {
      final pdfBytes = await _generatePdfContrato(contrato);
      await Printing.sharePdf(
          bytes: Uint8List.fromList(pdfBytes), filename: 'contrato.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar contrato: $e')),
      );
    }
  }

  Future<List<int>> _generatePdfContrato(String contrato) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            contrato,
            style: pw.TextStyle(fontSize: 18),
          ),
        ),
      ),
    );

    return pdf.save();
  }
}
