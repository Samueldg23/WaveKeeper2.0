import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/entity/music.dart';
import 'package:wavekeeper/navigation/botNavBar.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Map<String, dynamic>? userProfile;
  late Future<List<Music>> userSongsFuture;
  final String defaultProfileImageUrl =
      'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    userSongsFuture = _fetchUserSongs(widget.userId);
  }

  Future<void> _fetchUserProfile() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('usuario')
          .select(
              'id, nome, nome_artistico, tipo, foto_perfil, biografia, telefone, cidade')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userProfile = response;
      });
        } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<List<Music>> _fetchUserSongs(String userId) async {
    final supabase = Supabase.instance.client;

    try {
      final response =
          await supabase.from('obra').select().eq('id_usuario', userId);

      if (response.isNotEmpty) {
        return response.map<Music>((data) => Music.fromMap(data)).toList();
      }
    } catch (e) {
      print('Erro ao buscar músicas do usuário: $e');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 25.0),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomNavBar(
                  userId: widget.userId,
                  initialIndex: 0,
                ),
              ),
            );
          },
        ),
        title: const Text(
          'Perfil do Usuário',
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(
                        userProfile!['foto_perfil'] ?? defaultProfileImageUrl,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome: ${userProfile!['nome']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Nome Artístico: ${userProfile!['nome_artistico'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Tipo: ${userProfile!['tipo']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Biografia: ${userProfile!['biografia'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Telefone: ${userProfile!['telefone'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Cidade: ${userProfile!['cidade'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'Obras:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    FutureBuilder<List<Music>>(
                      future: userSongsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Erro ao carregar obras',
                            style: TextStyle(color: Colors.red),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                            'Nenhuma obra encontrada',
                            style: TextStyle(color: Colors.white70),
                          );
                        }

                        return Column(
                          children: snapshot.data!.map((music) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Card(
                                color: Colors.transparent,
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
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  music.imageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                music.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              Text(
                                                music.category,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                              Text(
                                                'R\$ ${music.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
