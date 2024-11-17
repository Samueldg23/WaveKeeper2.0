import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wavekeeper/entity/music.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerMusicPage extends StatefulWidget {
  final String userId;
  final int musicId;

  const PlayerMusicPage({Key? key, required this.userId, required this.musicId})
      : super(key: key);

  @override
  _PlayerMusicPageState createState() => _PlayerMusicPageState();
}

class _PlayerMusicPageState extends State<PlayerMusicPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  Music? _music;
  bool _isLoading = true;
  bool _isPlaying = true;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
     _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _colorAnimation = ColorTween(begin: Colors.purple, end: Colors.black)
        .animate(_controller);
    _fetchMusicDetails();
    _checkIfFavorited();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
     _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMusicDetails() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('obra')
          .select()
          .eq('id', widget.musicId)
          .single();

      setState(() {
        _music = Music.fromMap(response);
        _isLoading = false;
      });
      await _audioPlayer.play(UrlSource(_music!.audioUrl));
      _controller.repeat(reverse: true);
        } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar a música: $e');
    }
  }

  Future<void> _checkIfFavorited() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('favoritos')
          .select()
          .eq('id_usuario', widget.userId)
          .eq('id_obra', widget.musicId)
          .single();

      setState(() {
        // ignore: unnecessary_null_comparison
        _isFavorited = response != null;
      });
    } catch (e) {
      print('Erro ao verificar favorito: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final supabase = Supabase.instance.client;

    try {
      if (_isFavorited) {
        await supabase
            .from('favoritos')
            .delete()
            .eq('id_usuario', widget.userId)
            .eq('id_obra', widget.musicId);
        setState(() {
          _isFavorited = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Música removida dos favoritos')));
      } else {
        await supabase.from('favoritos').insert({
          'id_obra': widget.musicId,
          'id_usuario': widget.userId,
        });
        setState(() {
          _isFavorited = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Música adicionada aos favoritos')));
      }
    } catch (e) {
      print('Erro ao atualizar favoritos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar favoritos')));
    }
  }

 void _playPauseAudio() async {
  if (_isPlaying) {
    await _audioPlayer.pause();
    _controller.stop();  
  } else {
    await _audioPlayer.resume();
    _controller.repeat(reverse: true); 
  }

  setState(() {
    _isPlaying = !_isPlaying;
  });
}


  Future<void> registrarTransacao(int musicId, String compradorId) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('transacao').insert({
        'status': false,
        'id_comprador': compradorId,
        'id_obra': musicId,
      });

      print('Transação registrada com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Transação iniciada. Confirme a compra na seção de negócios.')),
      );
    } catch (e) {
      print('Erro ao registrar transação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao iniciar a transação')),
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
        title: Text(
          _music?.title ?? 'Carregando...',
          style: const TextStyle(
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        _colorAnimation.value ?? Colors.purple
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: _buildPlayer(),
                );
              },
            ),
    );
  }

  Widget _buildPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_music != null)
          Column(
            children: [
              Image.network(
                _music!.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                _music!.title,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                '\$${_music!.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.purple, fontSize: 18),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited ? Colors.purple : Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 80,
                    ),
                    onPressed: _playPauseAudio,
                  ),
                  IconButton(
                    icon: const Icon(Icons.business_center_outlined,
                        color: Colors.white),
                    onPressed: () {
                      registrarTransacao(widget.musicId, widget.userId);
                    },
                  )
                ],
              ),
            ],
          ),
      ],
    );
  }
}
