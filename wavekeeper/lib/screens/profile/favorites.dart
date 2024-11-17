import 'package:flutter/material.dart';
import 'package:wavekeeper/models/cardSearch.dart';
import 'package:wavekeeper/entity/music.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/home/playerMusic.dart';

class FavoritosPage extends StatefulWidget {
  final String userId;

  const FavoritosPage({Key? key, required this.userId}) : super(key: key);

  @override
  _FavoritosPageState createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  List<Music> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoritos();
  }

 Future<void> _fetchFavoritos() async {
  final supabase = Supabase.instance.client;

  try {
    final response = await supabase
        .from('favoritos')
        .select('id_obra')
        .eq('id_usuario', widget.userId);

    List<dynamic> data = response; 

    final List<Music> favoritosList = [];

    for (var item in data) {
      final obraResponse = await supabase
  .from('obra')
  .select('id, titulo, capa_url, categoria, preco') 
  .eq('id', item['id_obra'])
  .single();


      favoritosList.add(Music.fromMap(obraResponse));
        }

    setState(() {
      _favoritos = favoritosList;
      _isLoading = false;
    });
    } catch (e) {
    print('Erro ao carregar favoritos: $e');
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
          'Favoritos',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoritos.isEmpty
              ? const Center(child: Text('Você ainda não tem favoritos!'))
              : ListView.builder(
                  itemCount: _favoritos.length,
                  itemBuilder: (context, index) {
                    final music = _favoritos[index];
                    return GestureDetector(
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
                      child: SearchMusicCard(
                        id: music.id,
                        imageUrl: music.imageUrl,
                        title: music.title,
                        category: music.category,
                        price: music.price,
                      ),
                    );
                  },
                ),
    );
  }
}
