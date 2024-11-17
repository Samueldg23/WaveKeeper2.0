class User {
  String? id;
  String nome;
  String email;
  String biografia; 
  String? fotoPerfil; 
  bool ativo;
  String nomeArtistico;
  String cpf;
  String telefone;
  String tipo;
  String cidade;

  User({
    this.id,
    required this.nome,
    required this.email,
    required this.biografia,
    required this.nomeArtistico,
    required this.cpf,
    required this.telefone,
    required this.tipo,
    required this.cidade,
    this.fotoPerfil,
    this.ativo = true,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'biografia': biografia, 
      'foto_perfil': fotoPerfil,
      'ativo': ativo,
      'nome_artistico': nomeArtistico,
      'CPF': cpf,
      'telefone': telefone,
      'tipo': tipo,
      'cidade': cidade,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      biografia: map['biografia'], 
      fotoPerfil: map['foto_perfil'],
      ativo: map['ativo'] ?? true,
      nomeArtistico: map ['nome_artistico'],
      cpf: map['CPF'],
      telefone: map['telefone'],
      tipo: map['tipo'],
      cidade: map['cidade'],
    );
  }
}
