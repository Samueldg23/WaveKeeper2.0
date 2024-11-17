class Music {
  final int id;
  final String imageUrl;
  final String audioUrl;
  final String title;
  final String category;
  final double price;
  final String id_usuario;
  final DateTime uploadSong;
  bool isProfileVisible;

  Music({
    required this.id,
    required this.imageUrl,
    required this.audioUrl,
    required this.title,
    required this.category,
    required this.price,
    required this.uploadSong,
    required this.isProfileVisible,
    required this.id_usuario,
  });

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      id: map['id'] ?? 0, 
      imageUrl: map['capa_url'] ?? 'https://utxoumffgexeferfarbj.supabase.co/storage/v1/object/public/wavekeeper/wave_images/logoWave.png',
      audioUrl: map['audio_url'] ?? '', 
      title: map['titulo'] ?? 'Sem título',
      category: map['categoria'] ?? 'Sem categoria',
      price: map['preco']?.toDouble() ?? 0.0,
      id_usuario: map['id_usuario'] ?? '0',
      uploadSong: DateTime.parse(map['criada_em'] ?? '2022-01-01'),
      isProfileVisible: map['ativo'] ?? true,
    );
  }
}
