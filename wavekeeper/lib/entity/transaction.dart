class Transacao {
  final int id;
  final bool status;
  final String idComprador;
  final int idObra;
  final String contrato;
  final DateTime realizadaEm;

  Transacao({
    required this.id,
    required this.status,
    required this.idComprador,
    required this.idObra,
    required this.contrato,
    required this.realizadaEm,
  });

  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      status: map['status'],
      idComprador: map['id_comprador'],
      idObra: map['id_obra'],
      contrato: map['contrato'],
      realizadaEm: DateTime.parse(map['realizada_em']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'id_comprador': idComprador,
      'id_obra': idObra,
      'contrato': contrato,
      'realizada_em': realizadaEm.toIso8601String(),
    };
  }
}
