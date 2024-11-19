import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/entity/music.dart';
import 'package:wavekeeper/models/cardUser.dart';
import 'package:url_launcher/url_launcher.dart';

class MyMusicPage extends StatefulWidget {
  final String userId;

  const MyMusicPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<MyMusicPage> createState() => _MyMusicPageState();
}

class _MyMusicPageState extends State<MyMusicPage> {
  late Future<List<Music>> _futureSongs;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  void _loadSongs() {
    setState(() {
      _futureSongs = _fetchUserSongs(widget.userId);
    });
  }

  Future<List<Music>> _fetchUserSongs(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('obra').select().eq('id_usuario', userId);

      if (response.isNotEmpty) {
        return response.map<Music>((data) => Music.fromMap(data)).toList();
      }
    } catch (e) {
      print('Erro ao buscar dados: $e');
    }

    return [];
  }

  void _toggleMusicVisibility(Music music) async {
    final supabase = Supabase.instance.client;
    final newVisibility = !music.isProfileVisible;

    try {
      await supabase.from('obra').update({'ativo': newVisibility}).eq('id', music.id);

      setState(() {
        music.isProfileVisible = newVisibility; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newVisibility ? 'Visibilidade ativada!' : 'Visibilidade desativada!'),
        ),
      );
    } catch (e) {
      print('Erro ao atualizar visibilidade: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar visibilidade.')),
      );
    }
  }

  void _deleteMusic(int musicId) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('obra').delete().eq('id', musicId);
      setState(() {
        _futureSongs = _fetchUserSongs(widget.userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Música excluída com sucesso!')),
      );
    } catch (e) {
      print('Erro ao deletar música: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir música.')),
      );
    }
  }

  void _downloadPdf(int musicId) async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('obra')
          .select('comprovante')
          .eq('id', musicId)
          .single();

      if (response['comprovante'] != null) {
        final url = response['comprovante'];
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Não foi possível abrir o PDF';
        }
      }
    } catch (e) {
      print('Erro ao baixar o PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao baixar o PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
          'Suas músicas',
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
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          height: 800.0,
          width: double.infinity,
          child: FutureBuilder<List<Music>>(
            future: _futureSongs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Erro ao carregar músicas');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nenhuma música encontrada');
              } else {
                final songs = snapshot.data!;
                return ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final music = songs[index];
                    return UserMusicCard(
                      id: music.id,
                      imageUrl: music.imageUrl,
                      title: music.title,
                      category: music.category,
                      price: music.price,
                      isProfileVisible: music.isProfileVisible,
                      onToggleVisibility: () => _toggleMusicVisibility(music),
                      onDelete: () => _deleteMusic(music.id),
                      onDownload: () => _downloadPdf(music.id),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );

    
  }
}


