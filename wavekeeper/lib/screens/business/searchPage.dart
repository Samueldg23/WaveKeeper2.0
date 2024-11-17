import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wavekeeper/screens/business/userProfilePage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _usuarios = [];

  Future<void> _searchUsers(String query) async {
    final supabase = Supabase.instance.client;

    try {
      if (query.isEmpty) {
        setState(() {
          _usuarios = [];
        });
        return;
      }

      final response = await supabase
          .from('usuario')
          .select('id, nome, nome_artistico, tipo, foto_perfil')
          .or('nome.ilike.%$query%,biografia.ilike.%$query%,nome_artistico.ilike.%$query%,telefone.ilike.%$query%,cidade.ilike.%$query%')
          .eq('ativo', true);

      List<dynamic> data = response;

      final List<Map<String, dynamic>> usuariosList = data.map((usuario) {
        return {
          'id': usuario['id'],
          'nome': usuario['nome'],
          'nome_artistico': usuario['nome_artistico'],
          'tipo': usuario['tipo'],
          'foto_perfil': usuario['foto_perfil'],
        };
      }).toList();

      setState(() {
        _usuarios = usuariosList;
      });
    } catch (e) {
      print('Erro ao buscar usuários: $e');
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
          'Pesquisa',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: TextStyle(color: Colors.purple), 
              decoration: InputDecoration(
                hintText: 'Digite sua pesquisa...',
                hintStyle: TextStyle(
                    color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              onChanged: (value) {
                _searchUsers(value);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = _usuarios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4.0,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(usuario['foto_perfil'] ?? ''),
                        radius: 30.0,
                      ),
                      title: Text(
                        usuario['nome'] ?? '',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${usuario['nome_artistico'] ?? ''} | ${usuario['tipo'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfilePage(userId: usuario['id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
