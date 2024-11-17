import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/models/cardRow.dart';
import 'package:wavekeeper/entity/music.dart';
import 'package:wavekeeper/screens/home/playerMusic.dart';
import 'package:wavekeeper/screens/profile/favorites.dart';
import 'package:wavekeeper/screens/home/uploadSong.dart';
import 'package:wavekeeper/screens/profile/chatbot.dart';

class HomeView extends StatefulWidget {
  final String userId;

  const HomeView({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? photoUrl;
  String userName = '';

  final String defaultProfileImageUrl =
      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('usuario')
          .select('nome, foto_perfil')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userName = response['nome'] ?? '';
        photoUrl = response['foto_perfil'] ?? defaultProfileImageUrl;
      });
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMusicByCategory(
      String category) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('obra')
          .select()
          .eq('categoria', category)
          .eq('ativo', true);

      print('Resposta da consulta: $response');

      if (response.isNotEmpty) {
        List<Music> musicList =
            response.map<Music>((data) => Music.fromMap(data)).toList();

        List<Map<String, dynamic>> detailedMusicList = [];

        for (var music in musicList) {
          final authorResponse = await supabase
              .from('usuario')
              .select('nome')
              .eq('id', music.id_usuario)
              .single();

          final authorName = authorResponse.isNotEmpty
              ? authorResponse['nome']
              : 'Autor Desconhecido';

          detailedMusicList.add({
            'music': music,
            'authorName': authorName,
          });
        }

        return detailedMusicList;
      } else {
        print('Nenhuma música encontrada para a categoria $category');
      }
    } catch (e) {
      print('Erro ao buscar músicas da categoria $category: $e');
    }
    return [];
  }

  Widget buildCategoryRow(String category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMusicByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar músicas.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma música disponível.'));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: snapshot.data!.map((item) {
                      final music = item['music'] as Music;
                      final authorName = item['authorName'] as String;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: MusicRowCard(
                          imageUrl: music.imageUrl,
                          title: music.title,
                          authorName:
                              authorName, // Substitua 'author' por 'authorName'
                          price: music.price,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerMusicPage(
                                  userId: widget.userId,
                                  musicId: music.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135.0),
        child: AppBar(
          backgroundColor: Colors.black,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.black],
                stops: [0.0, 0.9],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 75.0,
                        height: 75.0,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: photoUrl != null
                            ? Image.network(photoUrl!, fit: BoxFit.cover)
                            : Image.network(defaultProfileImageUrl,
                                fit: BoxFit.cover),
                      ),
                      SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            userName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter Tight',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.add, color: Colors.white, size: 30.0),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UploadSongPage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCategoryCard(
                      context,
                      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/favoritas.jpg',
                      'Favoritas'),
                  _buildCategoryCard(
                      context,
                      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/Musicas.png',
                      'Músicas'),
                  _buildCategoryCard(
                      context,
                      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/Beats.png',
                      'Beats'),
                  _buildCategoryCard(
                      context,
                      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png',
                      'Assinatura'),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildCategoryRow('Gospel'),
                  buildCategoryRow('Pop'),
                  buildCategoryRow('Rap'),
                  buildCategoryRow('Rock'),
                  buildCategoryRow('Beat'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String imageUrl, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Favoritas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoritosPage(userId: widget.userId),
            ),
          );
        } else if (label == 'Músicas') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatBotPage(),
            ),
          );
        } else if (label == 'Beats') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatBotPage(),
            ),
          );
        } else if (label == 'Assinatura') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatBotPage(),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            color: const Color.fromARGB(62, 158, 158, 158),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    bottomLeft: Radius.circular(12.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
