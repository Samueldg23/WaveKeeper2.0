import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/models/exceptionDialog.dart';
class UserMusicCard extends StatelessWidget {
  final int id;
  final String imageUrl;
  final String title;
  final String category;
  final double price;
  final bool isProfileVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onDelete;
  final VoidCallback onDownload; 



  const UserMusicCard({
    Key? key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.category,
    required this.price,
    required this.isProfileVisible,
    required this.onToggleVisibility,
    required this.onDelete,
    required this.onDownload, 

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5.0,
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      'R\$ ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Switch.adaptive(
                    value: isProfileVisible,
                    onChanged: (_) {
                      onToggleVisibility();
                    },
                    activeColor: const Color.fromARGB(255, 175, 117, 186),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue),
                    onPressed: () {
                      // Função de download do PDF
                      _downloadContrato(context, this.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



 
  Future<void> _downloadContrato(BuildContext context, int obra) async {
  try {
    final supabase = Supabase.instance.client;

    // Realiza a consulta no Supabase
    final response = await supabase
        .from('obra')
        .select('comprovante') // Certifique-se de que a coluna existe
        .eq('id', obra)     // Filtra pela ID fornecida
        .maybeSingle();     // Retorna apenas um registro ou `null`

    // Verifica se houve resultado na consulta
    if (response == null) {
      showExceptionCustomDialog(context, 'Comprovante não encontrado para a obra $obra.');
      return;
    }

    // Acessa o valor da chave "contrato"
    final comprovante = response?['comprovante'] as String?;
    if (comprovante == null) {
       showExceptionCustomDialog(context, 'Comprovante não disponível para a obra $obra.');
       return;
    }

    // Gera o PDF e compartilha
    final pdfBytes = await _generatePdfComprovante(comprovante);
    await Printing.sharePdf(
      bytes: Uint8List.fromList(pdfBytes),
      filename: 'comprovante.pdf',
    );
  } catch (e) {
    // Mostra um erro no SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao baixar Comprovante: $e')),
    );
  }
}


  Future<List<int>> _generatePdfComprovante(String? contrato) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            contrato.toString(),
            style: pw.TextStyle(fontSize: 18),
          ),
        ),
      ),
    );

    return pdf.save();
  }
}
