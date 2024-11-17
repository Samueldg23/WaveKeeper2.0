import 'package:flutter/material.dart';

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
                      _downloadPdf(id);
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

  void _downloadPdf(int id) {
    // Lógica para baixar o PDF associado ao ID da música
    print("Download do PDF para a música com ID: $id");
  }
}
