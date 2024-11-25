import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadSongPage extends StatefulWidget {
  final String userId;

  const UploadSongPage({Key? key, required this.userId});

  @override
  _UploadSongPageState createState() => _UploadSongPageState();
}

class _UploadSongPageState extends State<UploadSongPage> {
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
String? _selectedCategory;
  File? _selectedImage;
  File? _selectedAudio;
  String? _selectedAudioName;
  String? imageUrl;
  String? audioUrl;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
        _selectedAudioName = result.files.single.name;
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      await supabase.storage
          .from('wavekeeper/music_images')
          .upload(fileName, image);
      final urlResponse = supabase.storage
          .from('wavekeeper/music_images')
          .getPublicUrl(fileName);
      return urlResponse;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<String?> _uploadAudio(File audio) async {
    final supabase = Supabase.instance.client;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp3';

    try {
      await supabase.storage.from('wavekeeper/audio').upload(fileName, audio);
      final urlResponse =
          supabase.storage.from('wavekeeper/audio').getPublicUrl(fileName);
      return urlResponse;
    } catch (e) {
      print('Erro ao fazer upload do áudio: $e');
      return null;
    }
  }

  Future<void> _saveSong() async {
    print("User ID na tela de upload: ${widget.userId}");
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 3));

    final supabase = Supabase.instance.client;
    final String titulo = tituloController.text;
    final double? preco;
    final String categoria = _selectedCategory ?? 'Sem categoria';

    if (titulo.isEmpty || priceController.text.isEmpty || categoria.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    try {
      preco = double.parse(priceController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um preço válido.')),
      );
      return;
    }

    if (_selectedImage == null || _selectedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma imagem e um áudio.')),
      );
      return;
    }

    final uploadedImageUrl = await _uploadImage(_selectedImage!);
    final uploadedAudioUrl = await _uploadAudio(_selectedAudio!);

    if (uploadedImageUrl != null && uploadedAudioUrl != null) {

      if (widget.userId.isEmpty ||
          !RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(widget.userId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: ID de usuário inválido')),
        );
        return;
      }
 try {
   final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      // Inserir os dados da obra
      final obraResponse = await supabase.from('obra').insert({
        'id_usuario': widget.userId,
        'titulo': titulo,
        'preco': preco,
        'audio_url': uploadedAudioUrl,
        'capa_url': uploadedImageUrl,
        'categoria': categoria,
        'criada_em': now,
        'ativo': true,
      }).select('id, audio_url, capa_url, criada_em, id_usuario').single();

      final obraId = obraResponse['id'];
      final idUsuario = obraResponse['id_usuario'];

      // Buscar dados do usuário relacionado
      final usuarioData = await supabase
          .from('usuario')
          .select('nome, CPF')
          .eq('id', idUsuario)
          .single();

      // Criar comprovante de upload
      final String comprovante = '''
        Comprovante de Upload:
        Usuário: ${usuarioData['nome']}
        CPF: ${usuarioData['CPF']}
        Título: $titulo
        Preço: $preco
        Data de Criação: ${obraResponse['criada_em']}
        URL da Capa: ${obraResponse['capa_url']}
        URL do Áudio: ${obraResponse['audio_url']}
        Data de Upload: $now
      ''';

      // Atualizar a coluna comprovante na tabela obra
      await supabase.from('obra').update({
        'comprovante': comprovante,
      
      }).eq('id', obraId);

      print('Comprovante de upload salvo com sucesso!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comprovante de upload salvo com sucesso!')),
      );
    } catch (e) {
      print('Erro ao salvar o comprovante de upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o comprovante de upload: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao obter URLs de upload.')),
    );
  }
    setState(() {
      _isLoading = false;
    });
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: const Text('Upload de Música'),
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
    ),
    backgroundColor: Colors.black,
    body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Imagem da Música',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : const Center(
                        child: Text(
                          'Clique para adicionar uma imagem',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Áudio da Música',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickAudio,
              child: const Text('Upload de Áudio'),
            ),
            if (_selectedAudioName != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Arquivo selecionado: $_selectedAudioName',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: tituloController,
              decoration: InputDecoration(
                labelText: 'Título da Música',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Preço da Música',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                 ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
DropdownButtonFormField<String>(
  value: _selectedCategory, 
  onChanged: (String? newValue) {
    setState(() {
      _selectedCategory = newValue!;
    });
  },
  items: [
    'Gospel', 'Rap', 'Funk', 'Pop', 'Rock', 'Beat', 'Trap'
  ].map<DropdownMenuItem<String>>((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value,
      style: TextStyle(fontSize: 16, color: Colors.purple),),
    );
               
      }).toList(),
  decoration: InputDecoration(
    labelText: 'Categoria',
    labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
    filled: true,
    fillColor: Colors.grey[200],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
  ),
),
const SizedBox(height: 20),
Center(
  child: ElevatedButton(
    onPressed: _isLoading ? null : _saveSong,
    child: _isLoading
        ? const CircularProgressIndicator()
        : const Text('Salvar Música'),
  ),
),
const SizedBox(height: 20),
if (_isLoading) Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    ),
  );
}
}