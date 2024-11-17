import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  final String userId;

  const AccountPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<AccountPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? photoUrl;
  String userName = '';
  String artistName = '';
  String email = '';
  String biografia = '';
  String phone = '';
  String type = '';
  String city = '';

  final Map<String, TextEditingController> _controllers = {
    'Nome': TextEditingController(),
    'Nome Artístico': TextEditingController(),
    'E-mail': TextEditingController(),
    'Biografia': TextEditingController(),
    'Telefone': TextEditingController(),
    'Tipo': TextEditingController(),
    'Cidade': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    print("userId atual: ${widget.userId}");
    if (widget.userId.isEmpty ||
        !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.userId)) {
      print("Erro: userId inválido");
      return;
    }
    try {
      final response = await supabase
          .from('usuario')
          .select('nome, nome_artistico, email, biografia, foto_perfil, telefone, tipo, cidade')
          .eq('id', widget.userId)
          .single();

      setState(() {
        userName = response['nome'];
        artistName = response['nome_artistico'];
        email = response['email'];
        biografia = response['biografia'];
        photoUrl = response['foto_perfil'];
        phone = response['telefone'];
        type = response['tipo'];
        city = response['cidade'];

        _controllers['Nome']!.text = userName;
        _controllers['Nome Artístico']!.text = artistName;
        _controllers['E-mail']!.text = email;
        _controllers['Biografia']!.text = biografia;
        _controllers['Telefone']!.text = phone;
        _controllers['Tipo']!.text = type;
        _controllers['Cidade']!.text = city;
      });
        } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    final supabase = Supabase.instance.client;

    try {
      String? imageUrl = photoUrl;

      if (_imageFile != null) {
        final uploadedImageUrl = await _uploadImage(File(_imageFile!.path));
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        }
      }

      await supabase.from('usuario').update({
        'nome': _controllers['Nome']!.text,
        'nome_artistico': _controllers['Nome Artístico']!.text,
        'email': _controllers['E-mail']!.text,
        'biografia': _controllers['Biografia']!.text,
        'foto_perfil': imageUrl,
        'telefone': _controllers['Telefone']!.text,
        'tipo': _controllers['Tipo']!.text,
        'cidade': _controllers['Cidade']!.text,
      }).eq('id', widget.userId);

      print('Perfil atualizado com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    } catch (e) {
      print('Erro ao atualizar o perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar o perfil.')),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';

    try {
      await supabase.storage
          .from('wavekeeper/users_images')
          .upload(fileName, image);
      final urlResponse = supabase.storage
          .from('wavekeeper/users_images')
          .getPublicUrl(fileName);
      return urlResponse;
    } catch (e) {
      print('Erro durante o upload da imagem: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          'Editar Perfil',
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
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: InkWell(
                      splashColor: Colors.white,
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(File(_imageFile!.path))
                            : (photoUrl != null
                                    ? NetworkImage(photoUrl!)
                                    : AssetImage('assets/logoWave.png'))
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var key in _controllers.keys)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                        controller: _controllers[key],
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.purple,
                        decoration: InputDecoration(
                          labelText: key,
                          labelStyle: const TextStyle(
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.purple),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
