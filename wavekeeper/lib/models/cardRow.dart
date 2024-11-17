import 'package:flutter/material.dart';

class MusicRowCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String authorName;
  final double price;
  final VoidCallback onTap; 

  const MusicRowCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.authorName,
    required this.price,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        width: 130.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            Text(
              authorName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
            Text(
              'R\$ ${price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
